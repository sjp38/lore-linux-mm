Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 803456B002B
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 07:39:55 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id l22so6489244vbn.14
        for <linux-mm@kvack.org>; Sun, 16 Dec 2012 04:39:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2e91ea19fbd30fa17718cb293473ae207ee8fd0f.1355536006.git.luto@amacapital.net>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
	<2e91ea19fbd30fa17718cb293473ae207ee8fd0f.1355536006.git.luto@amacapital.net>
Date: Sun, 16 Dec 2012 04:39:54 -0800
Message-ID: <CANN689HG3tYAjijoeU0fMZW+sxGFyKFtzgycLMubT-rEPQhrRw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Downgrade mmap_sem before locking or populating on mmap
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Dec 14, 2012 at 6:17 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> This is a serious cause of mmap_sem contention.  MAP_POPULATE
> and MCL_FUTURE, in particular, are disastrous in multithreaded programs.
>
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
>
> Changes from v1:
>
> The non-unlocking versions of do_mmap_pgoff and mmap_region are still
> available for aio_setup_ring's benefit.  In theory, aio_setup_ring
> would do better with a lock-downgrading version, but that would be
> somewhat ugly and doesn't help my workload.

Hi Andy,

I agree that the long mmap_sem hold times when using MAP_POPULATE,
MAP_LOCKED or MCL_FUTURE are a problem. However, I'm not entirely
happy with your proposed solution.

My main concern is that just downgrading the mmap_sem only hides the
problem: as soon as a writer gets queued on that mmap_sem,
reader/writer fairness kicks in and blocks any new readers, which
makes the problem reappear. So in order to completely fix the issue,
we should look for a way that doesn't require holding the mmap_sem
(even in read mode) for the entire duration of the populate or mlock
operation.

I think this could be done by extending the mlock work I did as part
of v2.6.38-rc1. The commit message for
fed067da46ad3b9acedaf794a5f05d0bc153280b explains the idea; basically
mlock() was split into do_mlock() which just sets the VM_LOCKED flag
on vmas as needed, and do_mlock_pages() which goes through a range of
addresses and actually populates/mlocks each individual page that is
part of a VM_LOCKED vma.

This could be easily extended for mlocks that happen in mmap_region()
due to MAP_LOCKED or MCL_FUTURE: mmap_region() would just set the
VM_LOCKED flag and defer the work of actually populating/mlocking the
individual pages. I think the only constraint here is that the pages
must be locked before returning to userspace, so we may be able to use
the task_work mechanism to achieve that. Later on (but before
returning to userspace) we would notice we have some mlock work to do
and call do_mlock_pages() to achieve that.

I think the benefits of this approach would be:
- no mmap_sem locking changes around mmap_region() - which also means
that all code paths to mmap_region() can instantly benefit
- do_mlock_pages() doesn't need to hold a read lock on mmap_sem for
the entire duration of the operation, so we can fully solve the
problem instead of just making it harder to trigger

Now for handling MAP_POPULATE, we would probably want to use a similar
mechanism as well, so that we don't need to hold the mmap_sem for the
entire duration of the populate. This is similar in principle to the
MAP_LOCKED case; however this may require the introduction of a new
VM_POPULATE vma flag in order to avoid the possibility of a race where
someone replaces our vma with another before we get a chance to
populate it.

I don't have an implementation for this idea yet; however I'm hoping
to come up with one before xmas. Before then, any comments on the idea
?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

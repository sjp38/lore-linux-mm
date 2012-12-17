Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id AFE916B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 17:01:26 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id l22so8468735vbn.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 14:01:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANN689GKp-9Bfn6HENeSXe=PZ0Qy5uOP6ju5gosMFKFDPC0D8w@mail.gmail.com>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
 <2e91ea19fbd30fa17718cb293473ae207ee8fd0f.1355536006.git.luto@amacapital.net>
 <CANN689HG3tYAjijoeU0fMZW+sxGFyKFtzgycLMubT-rEPQhrRw@mail.gmail.com>
 <CALCETrW58pb2w_r0gUDmMVSqi8PBQRdR1dRj2HX0ymq+qnz8XA@mail.gmail.com> <CANN689GKp-9Bfn6HENeSXe=PZ0Qy5uOP6ju5gosMFKFDPC0D8w@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 17 Dec 2012 14:01:05 -0800
Message-ID: <CALCETrV_t109YwEA_ue8jYOFXLzDL55zwguKHVL09WDEJTJfRg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Downgrade mmap_sem before locking or populating on mmap
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Dec 16, 2012 at 7:29 PM, Michel Lespinasse <walken@google.com> wrote:
> On Sun, Dec 16, 2012 at 10:05 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Sun, Dec 16, 2012 at 4:39 AM, Michel Lespinasse <walken@google.com> wrote:
>>> I think this could be done by extending the mlock work I did as part
>>> of v2.6.38-rc1. The commit message for
>>> c explains the idea; basically
>>> mlock() was split into do_mlock() which just sets the VM_LOCKED flag
>>> on vmas as needed, and do_mlock_pages() which goes through a range of
>>> addresses and actually populates/mlocks each individual page that is
>>> part of a VM_LOCKED vma.
>>
>> Doesn't this have the same problem?  It holds mmap_sem for read for a
>> long time, and if another writer comes in then r/w starvation
>> prevention will kick in.
>
> Well, my point is that do_mlock_pages() doesn't need to hold the
> mmap_sem read side for a long time. It currently releases it when
> faulting a page requires a disk read, and could conceptually release
> it more often if needed.

I can't find this code.  It looks like do_mlock_pages calls
__mlock_vma_pages_range, which calls __get_user_pages, which makes its
way to __do_fault, which doesn't seem to drop mmap_sem.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

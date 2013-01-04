Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 9FB176B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 13:16:43 -0500 (EST)
Received: by mail-vc0-f173.google.com with SMTP id f13so17055516vcb.32
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 10:16:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1356050997-2688-1-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 4 Jan 2013 10:16:21 -0800
Message-ID: <CALCETrVGvfm2VHUaVNDg40U4dbsRmriW7GfRnfpHGihG9v1=Uw@mail.gmail.com>
Subject: Re: [PATCH 0/9] Avoid populating unbounded num of ptes with mmap_sem held
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2012 at 4:49 PM, Michel Lespinasse <walken@google.com> wrote:
> We have many vma manipulation functions that are fast in the typical case,
> but can optionally be instructed to populate an unbounded number of ptes
> within the region they work on:
> - mmap with MAP_POPULATE or MAP_LOCKED flags;
> - remap_file_pages() with MAP_NONBLOCK not set or when working on a
>   VM_LOCKED vma;
> - mmap_region() and all its wrappers when mlock(MCL_FUTURE) is in effect;
> - brk() when mlock(MCL_FUTURE) is in effect.
>
> Current code handles these pte operations locally, while the sourrounding
> code has to hold the mmap_sem write side since it's manipulating vmas.
> This means we're doing an unbounded amount of pte population work with
> mmap_sem held, and this causes problems as Andy Lutomirski reported
> (we've hit this at Google as well, though it's not entirely clear why
> people keep trying to use mlock(MCL_FUTURE) in the first place).
>
> I propose introducing a new mm_populate() function to do this pte
> population work after the mmap_sem has been released. mm_populate()
> does need to acquire the mmap_sem read side, but critically, it
> doesn't need to hold continuously for the entire duration of the
> operation - it can drop it whenever things take too long (such as when
> hitting disk for a file read) and re-acquire it later on.
>

I still have quite a few instances of 2-6 ms of latency due to
"call_rwsem_down_read_failed __do_page_fault do_page_fault
page_fault".  Any idea why?  I don't know any great way to figure out
who is holding mmap_sem at the time.  Given what my code is doing, I
suspect the contention is due to mmap or munmap on a file.  MCL_FUTURE
is set, and MAP_POPULATE is not set.

It could be the other thread calling mmap and getting preempted (or
otherwise calling schedule()).  Grr.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

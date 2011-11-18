Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 459B16B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 21:17:23 -0500 (EST)
Date: Fri, 18 Nov 2011 03:17:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111118021714.GP3306@redhat.com>
References: <20111105013317.GU18879@redhat.com>
 <CAPQyPG5Y1e2dac38OLwZAinWb6xpPMWCya2vTaWLPi9+vp1JXQ@mail.gmail.com>
 <20111107131413.GA18279@suse.de>
 <20111107154235.GE3249@redhat.com>
 <20111107162808.GA3083@suse.de>
 <20111109012542.GC5075@redhat.com>
 <20111116140042.GD3306@redhat.com>
 <alpine.LSU.2.00.1111161540060.1861@sister.anvils>
 <20111117184252.GK3306@redhat.com>
 <CAPQyPG7MvO8Qw3jrOMShQcG5Z-RwbzpKnu-AheoS6aRYNhW14w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPQyPG7MvO8Qw3jrOMShQcG5Z-RwbzpKnu-AheoS6aRYNhW14w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Nov 18, 2011 at 09:42:05AM +0800, Nai Xia wrote:
> First of all, I believe that at the POSIX level, it's ok for
> truncate_inode_page()
> not scanning  COWed pages, since basically we does not provide any guarantee
> for privately mapped file pages for this behavior. But missing a file
> mapped pte after its
> cache page is already removed from the the page cache is a

I also exclude there is a case that would break, but it's safer to
keep things as is, in case somebody depends on segfault trapping.

> fundermental malfuntion for
> a shared mapping when some threads see the file cache page is gone
> while some thread
> is still r/w from/to it! No matter how short the gap between
> truncate_inode_page() and
> the second loop, this is wrong.

Truncate will destroy the info on disk too... so if somebody is
writing to a mapping which points beyond the end of the i_size
concurrently with truncate, the result is undefined. The write may
well reach the page but then the page is discared. Or you may get
SIGBUS before the write.

> Second, even if the we don't care about this POSIX flaw that may
> introduce, a pte can still
> missed by the second loop. mremap can happen serveral times during
> these non-atomic
> firstpass-trunc-secondpass operations, a proper events can happily
> make the wrong order
> for every scan, and miss them all -- That's just what in Hugh's mind
> in the post you just
> replied. Without lock and proper ordering( which patial mremap cannot provide),
> this *will* happen.

There won't be more than one mremap running concurrently from the same
process (we must enforce it by making sure anon_vma lock and
i_mmap_lock are both taken at least once in copy_vma, they're already
both taken in fork, they should already be taken in all common cases
in copy_vma so for all cases it's going to be a L1 exclusive cacheline
already). I don't exclude there may be some case that won't take the
locks in vma_adjust though, we should check it, if we decide to relay
on the double loop, but it'd be a simple addition if needed.

I'm more concerned about the pte pointing to the orphaned pagecache
that would materialize for a little while because of
unmap+truncate+unmap instead of unmap+unmap+truncate (but the latter
order is needed for the COWs).

> You may disagree with me and have that locking removed, and I am
> already have that
> one line patch prepared waiting fora bug bumpping up again, what a
> cheap patch submission!

Well I'm not yet sure it's good idea to remove the i_mmap_mutex, or if
we should just add the anon_vma lock in mremap and add the i_mmap_lock
in fork (to avoid the orphaned pagecache left mapped in the child
which already may happen unless there's some i_mmap_lock belonging to
the same inode taken after copy_page_range returns until we return to
userland and child can run, and I don't think we can relay on the
order of the prio tree in fork. Fork is safe for anon pages because
there we can relay on the order of the same_anon_vma list.

I think clearing up if this orphaned pagecache is dangerous would be a
good start. If too complex we just add the i_mmap_lock around
copy_page_range in fork if vma->vm_file is set. If you instead think
we can deal with the orphaned pagecache we can add a dummy lock/unlock
of i_mmap_mutex in copy_vma vma_merge succeeding case (short critical
section and not common common case) and remove the i_mmap_mutex around
move_page_tables (common case) overall speeding up mremap and not
degrading fork.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

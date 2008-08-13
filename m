Date: Wed, 13 Aug 2008 17:36:12 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH for -mm 5/5] fix mlock return value for mm
In-Reply-To: <1218573014.6360.131.camel@lts-notebook>
References: <20080811163121.9468.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1218573014.6360.131.camel@lts-notebook>
Message-Id: <20080813171025.E773.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> > > Now, __mlock_vma_pages_range() ignore return value of __get_user_pages().
> > > We shouldn't do that.
> > 
> > Oops, sorry.
> > I sent older version, I resend it.
> > 
> > Definitly, I should learn an correct operation of quilt ;)
> > 
> > 
> > --------------------------------------------------------------
> > Now, __mlock_vma_pages_range() ignore return value of __get_user_pages().
> > We shouldn't do that.
> 
> Could you explain, in comments or patch description, why, after patching
> __mlock_vma_pages_range() top return mlock() appropriate values for
> __get_user_pages() failures, you then ignore the return value of
> __mlock_vma_pages_range() in mlock_vma_pages_range() [last 4 hunks]?  Is
> it because mlock_vma_pages_range() is called from mmap(), mremap(), etc,
> and not from mlock()?

Ah, OK.
I agreed with my patch description is too short.

in linus-tree code, make_pages_present called from seven points
 - sys_remap_file_pages
 - mlock_fixup
 - mmap_region
 - find_extend_vma
 - do_brk
 - move_vma
 - do_mremap

and, only mlock_fixup treat return value of it.
IOW, linus-tree policy is

mmap, brk, mremap	ignore error of page population
mlock			treat error of page population


In the other hand, __mlock_vma_pages_range() called from seven points.
 - sys_remap_file_pages (via mlock_vma_pages_range)
 - mmap_region (via mlock_vma_pages_range)
 - find_extend_vma (via mlock_vma_pages_range)
 - do_brk (via mlock_vma_pages_range)
 - move_vma (via mlock_vma_pages_range)
 - do_mremap (via mlock_vma_pages_range)
 - mlock_fixup

this is not a coincidence.
__mlock_vma_pages_range() aimed at unevictable lru aware make_pages_present().


So, mlock_fixup shouldn't ignore get_user_pages() in __mlock_vma_pages_range().
but others should ignore it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

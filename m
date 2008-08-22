From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 22 Aug 2008 17:10:28 -0400
Message-Id: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
Subject: [Patch 0/7] Mlock:  doc, patch grouping and error return cleanups
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

The six patches introduced by this message are against:

	2.6.27-rc3-mmotm-080821-0003

These patches replace the series of 6 patches posted by
/me at:

	http://marc.info/?l=linux-mm&m=121917996115763&w=4

those patches themselves replace the series of 5 RFC patches
posted by Kosaki Motohiro at:

	http://marc.info/?l=linux-mm&m=121843816412096&w=4


Patch 1/7 is a rework of KM's cleanup of the __mlock_vma_pages_range()
comment block.  I tried to follow kerneldoc format.  Randy will tell me if
I made a mistake :)

Patch 2/7 is a rework of KM's patch to remove the locked_vm 
adjustments for "special vmas" during mmap() processing.  Kosaki-san
wanted to "kill" this adjustment.  After discussion, he requested that
it be resubmitted as a separate patch.  This is the first step in providing
the separate patch [even tho' I consider this part of correctly "handling
mlocked pages during mmap()..."].

Patch 3/7 resubmits the locked_vm adjustment during mmap(MAP_LOCKED)) to
match the explicit mlock() behavior.

Patch 4/7 is KM's patch to change the error return for mlock
when, after downgrading the mmap semaphore to read during population of
the vma and switching back to write lock as our callers expect, the 
vma that we just locked no longer covers the range we expected.  See
the description.

Patch 5/7 is a new patch to ensure that locked_vm is updated correctly
when munmap()ing an mlocked region.

Patch 6/7 backs out a mainline patch to make_pages_present() to adjust
the error return to match the Posix specification for mlock error
returns.  make_pages_present() is used by other than mlock, so this
isn't really the appropriate place to make the change, even tho'
apparently only mlock() looks at the return value from make_pages_present().

Patch 7/7 fixes the mlock error return to be Posixly Correct in the
appropriate [IMO] paths in mlock.c.  Reworked in this version to
hide pte population errors [get_user_pages()] during mlock from mmap()
and related callers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

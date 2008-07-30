From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 30 Jul 2008 16:06:18 -0400
Message-Id: <20080730200618.24272.31756.sendpatchset@lts-notebook>
Subject: [PATCH 0/7] mmotm - unevictable lru/mlocked pages fixes/cleanup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@surriel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Eric.Whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Here are a set of fixes and cleanup to the unevictable lru and
mlocked pages patches against 27-rc1+mmotm-080730-0356.  In
addition to the patches, I have a few suggestions for fixing up
a few patch descriptions, and other potential cleanups, below.

The following patch names are the file names I'm using in my tree.
The names indicate where in the series the patch goes.  I've also
mentioned in the patch descriptions which patch each one fixes.


unevictable-lru-infrastructure-putback-fix1.patch

	I noticed that putback_lru_page() would forget the active
	state of a page in the event of a "redo".  [Note:  I added
	a vm event to record any redos.  I've never seen any redos
	in any of my stress testing since Kamezawa-san reworked
	putback_lru_pages().]  This patch remembers the page's
	incoming PageActive state.  Not sure this is required.

	Can be folded with unevictable-lru-infrastructure.patch

unevictable-lru-infrastructure-putback-fix2.patch

	Remove the unevictable page vm event counting from
	putback_lru_page(), as this breaks a bisect.  The necessary
	vmstat events have not been defined until later in the
	series.  Subsequent patches will add back in the event
	counting at appropriate places

	Can be folded with unevictable-lru-infrastructure.patch

unevictable-lru-page-statistics-add-events.patch

	Define the vmstat events for the unevictable lru
	infrastructure and count them here, separately from
	the mlocked pages stats.

	Renames the NORECL/noreclaim vmstat events to
	UNEVICTABLE/unevictable ...

	This patch may be folded with the
		unevictable-lru-page-statistics.patch

shm_locked-pages-are-unevictable-add-vm-events.patch

	Add unevictable lru event counting to scan of the
	unevictable lru list[s] for a mapping's pages.
	May be folded with shm_locked-pages-are-unevictable.patch

vmstat-mlocked-pages-statistics-add-vm-events.patch

	Add mlocked pages related vm event definitions and counting.
	May be folded with vmstat-mlocked-pages-statistics.patch

mlock-count-attempts-to-free-mlocked-page.patch

	REPLACE the existing patch of this name with this one.
	It resolves patch conflicts resulting from the renaming of
	the events and handles the renaming in unconflicted hunks.

vmstat-unevictable-and-mlocked-pages-vm-events.patch

	REMOVE this patch from the series.  It is superceeded by
	the preceeding patches that define the vm events with the
	appropriate statistics patch.

Other notes and patch description updates:

1) Kosaki-san's munlock rework patch [removal of page table walker]
   has been folded with:
	 mmap-handle-mlocked-pages-during-map-remap-unmap.patch
   Technically, it should be part of:
	 mlock-mlocked-pages-are-unevictable.patch
   where it would have just removed/replaced the patch chunks that
   added the page table walker.

2) Patch description of ramfs-and-ram-disk-pages-are-unevictable.patch
   is stale, since the brd driver replaced rd--ram disk pages are no
   longer on the lru.  I'll send a suggested replacement description as
   part of this series.

3) Since the putback_lru_page() rework, the patch description of
   shm_locked-pages-are-unevictable.patch is stale.  Suggest:

   Remove the text from the last paragraph of the description, starting with:
	"Note that scan_mapping_unevictable_page() must be able to sleep..."

4) Kosaki-san's munlock rework obsolete's note 5 in the description for
   mlock-mlocked-pages-are-unevictable.patch.

   Could just make a note to this effect with the folded "introduce
   __get_user_pages()" patch description.

5) The putback_lru_page() and munlock() rework requires update of the
   unevictable-lru.txt in Documentation.  I'll send an update patch [later].



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

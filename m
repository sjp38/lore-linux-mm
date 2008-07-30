From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 30 Jul 2008 16:07:02 -0400
Message-Id: <20080730200702.24272.12495.sendpatchset@lts-notebook>
In-Reply-To: <20080730200618.24272.31756.sendpatchset@lts-notebook>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
Subject: [PATCH/DESCRIPTION 7/7] unevictable lru:  replace patch description
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Not really a patch, per se:

Suggested patch description replacement for:
	ramfs-and-ram-disk-pages-are-unevictable.patch
in 27-rc1-mmotm-080730...

---

Christoph Lameter pointed out that ram disk pages also clutter the LRU
lists.  When vmscan finds them dirty and tries to clean them, the ram disk
writeback function just redirties the page so that it goes back onto the
active list.  Round and round she goes...

With the ram disk driver [rd.c] replaced by the newer 'brd.c', this is
no longer the case, as ram disk pages are no longer maintained on the
lru.  [This makes them unmigratable for defrag or memory hot remove,
but that can be addressed by a separate patch series.]  However, the
ramfs pages behave like ram disk pages used to, so:

Define new address_space flag [shares address_space flags member with
mapping's gfp mask] to indicate that the address space contains all
unevictable pages.  This will provide for efficient testing of ramfs
pages in page_evictable().

Also provide wrapper functions to set/test the unevictable state to
minimize #ifdefs in ramfs driver and any other users of this facility.

Set the unevictable state on address_space structures for new ramfs
inodes.  Test the unevictable state in page_evictable() to cull
unevictable pages.

These changes depend on [CONFIG_]UNEVICTABLE_LRU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

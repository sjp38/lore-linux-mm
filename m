Date: Fri, 28 Apr 2006 17:14:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/7] page migration: Reorder functions in migrate.c
In-Reply-To: <20060428161830.7af8c3f0.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0604281712210.4170@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
 <20060428150806.057b0bac.akpm@osdl.org> <Pine.LNX.4.64.0604281556220.3412@schroedinger.engr.sgi.com>
 <20060428161830.7af8c3f0.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, lee.schermerhorn@hp.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Apr 2006, Andrew Morton wrote:

> Patches against mainline would probably suit - I don't think there's much
> overlapping stuff going on, if any.

Ok. Here is the most important fix that also needs to go into 2.6.17. The 
rest will follow:


page migration: Fix fallback behavior for dirty pages.

Currently we check PageDirty() in order to make the decision to
swap out the page. However, the dirty information may be only be
contained in the ptes pointing to the page. We need to first unmap
the ptes before checking for PageDirty(). If unmap is successful then
the page count of the page will also be decreased so that pageout() works
properly.

This is a fix necessary for 2.6.17. Without this fix we may migrate
dirty pages for filesystems without migration functions. Filesystems
may keep pointers to dirty pages. Migration of dirty pages can
result in the filesystem keeping pointers to freed pages.

Unmapping is currently not be separated out from removing all the
references to a page and moving the mapping. Therefore try_to_unmap will
be called again in migrate_page() if the writeout is successful. However,
it wont do anything since the ptes are already removed.

The coming updates to the page migration code will restructure the code
so that this is no longer necessary.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-26 19:19:25.000000000 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 17:11:42.779439413 -0700
@@ -439,6 +439,17 @@
 			goto unlock_both;
                 }
 
+		/* Make sure the dirty bit is up to date */
+		if (try_to_unmap(page, 1) == SWAP_FAIL) {
+			rc = -EPERM;
+			goto unlock_both;
+		}
+
+		if (page_mapcount(page)) {
+			rc = -EAGAIN;
+			goto unlock_both;
+		}
+
 		/*
 		 * Default handling if a filesystem does not provide
 		 * a migration function. We can only migrate clean

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

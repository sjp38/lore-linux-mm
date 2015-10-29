Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1FAF682F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 14:44:06 -0400 (EDT)
Received: by obcqt19 with SMTP id qt19so24996074obc.3
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 11:44:05 -0700 (PDT)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id q126si1911590oia.45.2015.10.29.11.44.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 11:44:05 -0700 (PDT)
Received: by obbwb3 with SMTP id wb3so25222327obb.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 11:44:05 -0700 (PDT)
Date: Thu, 29 Oct 2015 11:43:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] osd fs: __r4w_get_page rely on PageUptodate for uptodate
Message-ID: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <ooo@electrozaur.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benny Halevy <bhalevy@primarydata.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, osd-dev@open-osd.org

Patch "mm: migrate dirty page without clear_page_dirty_for_io etc",
presently staged in mmotm and linux-next, simplifies the migration of
a PageDirty pagecache page: one stat needs moving from zone to zone
and that's about all.

It's convenient and safest for it to shift the PageDirty bit from old
page to new, just before updating the zone stats: before copying data
and marking the new PageUptodate.  This is all done while both pages
are isolated and locked, just as before; and just as before, there's
a moment when the new page is visible in the radix_tree, but not yet
PageUptodate.  What's new is that it may now be briefly visible as
PageDirty before it is PageUptodate.

When I scoured the tree to see if this could cause a problem anywhere,
the only places I found were in two similar functions __r4w_get_page():
which look up a page with find_get_page() (not using page lock), then
claim it's uptodate if it's PageDirty or PageWriteback or PageUptodate.

I'm not sure whether that was right before, but now it might be wrong
(on rare occasions): only claim the page is uptodate if PageUptodate.
Or perhaps the page in question could never be migratable anyway?

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 fs/exofs/inode.c             |    5 +----
 fs/nfs/objlayout/objio_osd.c |    5 +----
 2 files changed, 2 insertions(+), 8 deletions(-)

--- 4.3-next/fs/exofs/inode.c	2015-08-30 11:34:09.000000000 -0700
+++ linux/fs/exofs/inode.c	2015-10-28 16:55:18.795554294 -0700
@@ -592,10 +592,7 @@ static struct page *__r4w_get_page(void
 			}
 			unlock_page(page);
 		}
-		if (PageDirty(page) || PageWriteback(page))
-			*uptodate = true;
-		else
-			*uptodate = PageUptodate(page);
+		*uptodate = PageUptodate(page);
 		EXOFS_DBGMSG2("index=0x%lx uptodate=%d\n", index, *uptodate);
 		return page;
 	} else {
--- 4.3-next/fs/nfs/objlayout/objio_osd.c	2015-10-21 18:35:07.620645439 -0700
+++ linux/fs/nfs/objlayout/objio_osd.c	2015-10-28 16:53:55.083686639 -0700
@@ -476,10 +476,7 @@ static struct page *__r4w_get_page(void
 		}
 		unlock_page(page);
 	}
-	if (PageDirty(page) || PageWriteback(page))
-		*uptodate = true;
-	else
-		*uptodate = PageUptodate(page);
+	*uptodate = PageUptodate(page);
 	dprintk("%s: index=0x%lx uptodate=%d\n", __func__, index, *uptodate);
 	return page;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

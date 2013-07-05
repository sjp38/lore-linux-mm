Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 3EE6F6B0036
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 13:29:30 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so2350786pbb.14
        for <linux-mm@kvack.org>; Fri, 05 Jul 2013 10:29:29 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V4 2/6] fs/ceph: vfs __set_page_dirty_nobuffers interface instead of doing it inside filesystem
Date: Sat,  6 Jul 2013 01:26:24 +0800
Message-Id: <1373045184-27568-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: sage@inktank.com, mhocko@suse.cz, gthelen@google.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, fengguang.wu@intel.com, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Following we will begin to add memcg dirty page accounting around __set_page_dirty_
{buffers,nobuffers} in vfs layer, so we'd better use vfs interface to avoid exporting
those details to filesystems.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
cc: Sage Weil <sage@inktank.com>
cc: Michal Hocko <mhocko@suse.cz>
cc: Greg Thelen <gthelen@google.com>
cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
cc: Andrew Morton <akpm@linux-foundation.org>
cc: Fengguang Wu <fengguang.wu@intel.com>
cc: Mel Gorman <mgorman@suse.de>

---
 fs/ceph/addr.c |   13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 3e68ac1..1445bf1 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -76,7 +76,7 @@ static int ceph_set_page_dirty(struct page *page)
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
 
-	if (TestSetPageDirty(page)) {
+	if (!__set_page_dirty_nobuffers(page)) {
 		dout("%p set_page_dirty %p idx %lu -- already dirty\n",
 		     mapping->host, page, page->index);
 		return 0;
@@ -107,14 +107,7 @@ static int ceph_set_page_dirty(struct page *page)
 	     snapc, snapc->seq, snapc->num_snaps);
 	spin_unlock(&ci->i_ceph_lock);
 
-	/* now adjust page */
-	spin_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
-		WARN_ON_ONCE(!PageUptodate(page));
-		account_page_dirtied(page, page->mapping);
-		radix_tree_tag_set(&mapping->page_tree,
-				page_index(page), PAGECACHE_TAG_DIRTY);
-
 		/*
 		 * Reference snap context in page->private.  Also set
 		 * PagePrivate so that we get invalidatepage callback.
@@ -126,14 +119,10 @@ static int ceph_set_page_dirty(struct page *page)
 		undo = 1;
 	}
 
-	spin_unlock_irq(&mapping->tree_lock);
-
 	if (undo)
 		/* whoops, we failed to dirty the page */
 		ceph_put_wrbuffer_cap_refs(ci, 1, snapc);
 
-	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-
 	BUG_ON(!PageDirty(page));
 	return 1;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

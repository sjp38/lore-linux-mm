Date: Mon, 10 Sep 2007 18:49:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [5/35] changes in AFS
Message-Id: <20070910184909.9644ee8c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: dhowells@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Use page->mapping interface in AFS

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/afs/file.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/afs/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/afs/file.c
+++ test-2.6.23-rc4-mm1/fs/afs/file.c
@@ -145,7 +145,7 @@ static int afs_readpage(struct file *fil
 	off_t offset;
 	int ret;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 
 	ASSERT(file != NULL);
 	key = file->private_data;
@@ -253,8 +253,7 @@ static void afs_invalidatepage(struct pa
 
 			ret = 0;
 			if (!PageWriteback(page))
-				ret = page->mapping->a_ops->releasepage(page,
-									0);
+				ret = page_mapping_cache(page)->a_ops->releasepage(page, 0);
 			/* possibly should BUG_ON(!ret); - neilb */
 		}
 	}
@@ -277,7 +276,7 @@ static int afs_launder_page(struct page 
  */
 static int afs_releasepage(struct page *page, gfp_t gfp_flags)
 {
-	struct afs_vnode *vnode = AFS_FS_I(page->mapping->host);
+	struct afs_vnode *vnode = AFS_FS_I(page_inode(page));
 	struct afs_writeback *wb;
 
 	_enter("{{%x:%u}[%lu],%lx},%x",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

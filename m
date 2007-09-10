Date: Mon, 10 Sep 2007 19:17:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [23/35] changes in JFS
Message-Id: <20070910191756.08ae2b94.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: shaggy@austin.ibm.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in JFS

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/jfs/jfs_metapage.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/jfs/jfs_metapage.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/jfs/jfs_metapage.c
+++ test-2.6.23-rc4-mm1/fs/jfs/jfs_metapage.c
@@ -113,7 +113,7 @@ static inline int insert_metapage(struct
 	}
 
 	if (mp) {
-		l2mp_blocks = L2PSIZE - page->mapping->host->i_blkbits;
+		l2mp_blocks = L2PSIZE - page_inode(page)->i_blkbits;
 		index = (mp->index >> l2mp_blocks) & (MPS_PER_PAGE - 1);
 		a->mp_count++;
 		a->mp[index] = mp;
@@ -125,7 +125,7 @@ static inline int insert_metapage(struct
 static inline void remove_metapage(struct page *page, struct metapage *mp)
 {
 	struct meta_anchor *a = mp_anchor(page);
-	int l2mp_blocks = L2PSIZE - page->mapping->host->i_blkbits;
+	int l2mp_blocks = L2PSIZE - page_inode(page)->i_blkbits;
 	int index;
 
 	index = (mp->index >> l2mp_blocks) & (MPS_PER_PAGE - 1);
@@ -364,7 +364,7 @@ static int metapage_writepage(struct pag
 {
 	struct bio *bio = NULL;
 	unsigned int block_offset;	/* block offset of mp within page */
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	unsigned int blocks_per_mp = JFS_SBI(inode->i_sb)->nbperpage;
 	unsigned int len;
 	unsigned int xlen;
@@ -484,7 +484,7 @@ skip:
 
 static int metapage_readpage(struct file *fp, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct bio *bio = NULL;
 	unsigned int block_offset;
 	unsigned int blocks_per_page = PAGE_CACHE_SIZE >> inode->i_blkbits;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

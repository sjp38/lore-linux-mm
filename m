From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 21/26] FS: Slab defrag: Reiserfs support
Date: Fri, 31 Aug 2007 18:41:28 -0700
Message-ID: <20070901014224.140616098@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0021-slab_defrag_reiserfs.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Slab defragmentation: Support reiserfs inode defragmentation

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/reiserfs/super.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/reiserfs/super.c b/fs/reiserfs/super.c
index 5b68dd3..0344be9 100644
--- a/fs/reiserfs/super.c
+++ b/fs/reiserfs/super.c
@@ -520,6 +520,12 @@ static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags
 #endif
 }
 
+static void *reiserfs_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+		offsetof(struct reiserfs_inode_info, vfs_inode));
+}
+
 static int init_inodecache(void)
 {
 	reiserfs_inode_cachep = kmem_cache_create("reiser_inode_cache",
@@ -530,6 +536,8 @@ static int init_inodecache(void)
 						  init_once);
 	if (reiserfs_inode_cachep == NULL)
 		return -ENOMEM;
+	kmem_cache_setup_defrag(reiserfs_inode_cachep,
+			reiserfs_get_inodes, kick_inodes);
 	return 0;
 }
 
-- 
1.5.2.4

-- 

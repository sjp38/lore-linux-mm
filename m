Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3D70F6B0362
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 17:49:27 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y13so9162353pdi.12
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:49:26 -0700 (PDT)
Received: from psmtp.com ([74.125.245.178])
        by mx.google.com with SMTP id ud7si10208853pac.236.2013.10.21.14.49.25
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 14:49:26 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so7627253pbc.12
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:49:24 -0700 (PDT)
Date: Mon, 21 Oct 2013 14:49:20 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCHv2 12/13] mm, thp, tmpfs: enable thp page cache in tmpfs
Message-ID: <20131021214920.GM29870@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>, Ning Qu <quning@gmail.com>

>From inode, mark to enable thp in the page cache for tmpfs

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/Kconfig | 4 ++--
 mm/shmem.c | 5 +++++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 562f12f..4d2f90f 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -428,8 +428,8 @@ config TRANSPARENT_HUGEPAGE_PAGECACHE
        help
          Enabling the option adds support hugepages for file-backed
          mappings. It requires transparent hugepage support from
-         filesystem side. For now, the only filesystem which supports
-         hugepages is ramfs.
+         filesystem side. For now, the filesystems which support
+         hugepages are: ramfs and tmpfs.

 config CROSS_MEMORY_ATTACH
        bool "Cross Memory Support"
diff --git a/mm/shmem.c b/mm/shmem.c
index c42331a..391c4eb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1655,6 +1655,11 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
                        break;
                case S_IFREG:
                        inode->i_mapping->a_ops = &shmem_aops;
+                       /*
+                        * TODO: make tmpfs pages movable
+                        */
+                       mapping_set_gfp_mask(inode->i_mapping,
+                                            GFP_TRANSHUGE);
                        inode->i_op = &shmem_inode_operations;
                        inode->i_fop = &shmem_file_operations;
                        mpol_shared_policy_init(&info->policy,
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

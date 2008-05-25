Message-Id: <20080525143453.921204000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:34 +1000
From: npiggin@suse.de
Subject: [patch 17/23] hugetlb: do not always register default HPAGE_SIZE huge page size
Content-Disposition: inline; filename=hugetlb-non-default-hstate.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Allow configurations without the default HPAGE_SIZE size (mainly useful for
testing -- the final form of the userspace API / cmdline is not quite
nailed down).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 fs/hugetlbfs/inode.c |    2 ++
 mm/hugetlb.c         |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -667,7 +667,7 @@ static int __init hugetlb_init(void)
 {
 	BUILD_BUG_ON(HPAGE_SHIFT == 0);
 
-	if (!size_to_hstate(HPAGE_SIZE)) {
+	if (!max_hstate) {
 		hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
 		parsed_hstate->max_huge_pages = default_hstate_max_huge_pages;
 	}
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c
+++ linux-2.6/fs/hugetlbfs/inode.c
@@ -858,6 +858,8 @@ hugetlbfs_fill_super(struct super_block 
 	config.gid = current->fsgid;
 	config.mode = 0755;
 	config.hstate = size_to_hstate(HPAGE_SIZE);
+	if (!config.hstate)
+		config.hstate = &hstates[0];
 	ret = hugetlbfs_parse_options(data, &config);
 	if (ret)
 		return ret;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

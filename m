Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5836A6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 14:00:09 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x86so61726720ioe.5
        for <linux-mm@kvack.org>; Mon, 01 May 2017 11:00:09 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 98si14929165iot.39.2017.05.01.11.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 11:00:08 -0700 (PDT)
Subject: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
Date: Mon, 1 May 2017 11:00:09 -0700
MIME-Version: 1.0
In-Reply-To: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Some applications like a database use hugetblfs for performance
reasons. Files on hugetlbfs filesystem are created and huge pages
allocated using fallocate() API. Pages are deallocated/freed using
fallocate() hole punching support that has been added to hugetlbfs.
These files are mmapped and accessed by many processes as shared memory.
Such applications keep track of which offsets in the hugetlbfs file have
pages allocated.

Any access to mapped address over holes in the file, which can occur due
to bugs in the application, is considered invalid and expect the process
to simply receive a SIGBUS.  However, currently when a hole in the file is
accessed via the mapped address, kernel/mm attempts to automatically
allocate a page at page fault time, resulting in implicitly filling the hole
in the file. This may not be the desired behavior for applications like the
database that want to explicitly manage page allocations of hugetlbfs files.

This patch adds a new hugetlbfs mount option 'noautofill', to indicate that
pages should not be allocated at page fault time when accessed thru mmapped
address.

Signed-off-by: Prakash <prakash.sangappa@oracle.com>
---
fs/hugetlbfs/inode.c    | 11 ++++++++++-
  include/linux/hugetlb.h |  1 +
  mm/hugetlb.c            |  5 +++++
  3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 8f96461..8342ee9 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -53,6 +53,7 @@ struct hugetlbfs_config {
      long    nr_inodes;
      struct hstate *hstate;
      long    min_hpages;
+    long    noautofill;
  };

  struct hugetlbfs_inode_info {
@@ -71,7 +72,7 @@ enum {
      Opt_size, Opt_nr_inodes,
      Opt_mode, Opt_uid, Opt_gid,
      Opt_pagesize, Opt_min_size,
-    Opt_err,
+    Opt_noautofill, Opt_err,
  };

  static const match_table_t tokens = {
@@ -82,6 +83,7 @@ static const match_table_t tokens = {
      {Opt_gid,    "gid=%u"},
      {Opt_pagesize,    "pagesize=%s"},
      {Opt_min_size,    "min_size=%s"},
+    {Opt_noautofill,    "noautofill"},
      {Opt_err,    NULL},
  };

@@ -1109,6 +1111,11 @@ hugetlbfs_parse_options(char *options, struct
hugetlbfs_config *pconfig)
              break;
          }

+        case Opt_noautofill: {
+            pconfig->noautofill = 1;
+            break;
+        }
+
          default:
              pr_err("Bad mount option: \"%s\"\n", p);
              return -EINVAL;
@@ -1157,6 +1164,7 @@ hugetlbfs_fill_super(struct super_block *sb, void
*data, int silent)
      config.mode = 0755;
      config.hstate = &default_hstate;
      config.min_hpages = -1; /* No default minimum size */
+    config.noautofill = 0;
      ret = hugetlbfs_parse_options(data, &config);
      if (ret)
          return ret;
@@ -1170,6 +1178,7 @@ hugetlbfs_fill_super(struct super_block *sb, void
*data, int silent)
      sbinfo->max_inodes = config.nr_inodes;
      sbinfo->free_inodes = config.nr_inodes;
      sbinfo->spool = NULL;
+    sbinfo->noautofill = config.noautofill;
      /*
       * Allocate and initialize subpool if maximum or minimum size is
       * specified.  Any needed reservations (for minimim size) are taken
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 503099d..2f37e0c 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -259,6 +259,7 @@ struct hugetlbfs_sb_info {
      spinlock_t    stat_lock;
      struct hstate *hstate;
      struct hugepage_subpool *spool;
+    int    noautofill; /* don't allocate page to fill hole at fault time */
  };

  static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct
super_block *sb)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a7aa811..11655ef 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3715,6 +3715,11 @@ static int hugetlb_no_page(struct mm_struct *mm,
struct vm_area_struct *vma,
              goto out;
          }

+        if (HUGETLBFS_SB(mapping->host->i_sb)->noautofill) {
+            ret = VM_FAULT_SIGBUS;
+            goto out;
+        }
+
          page = alloc_huge_page(vma, address, 0);
          if (IS_ERR(page)) {
              ret = PTR_ERR(page);
-- 
2.7.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

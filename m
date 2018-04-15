Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 029486B0006
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 14:22:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k44so10643132wrc.3
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 11:22:03 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 63si2229354edn.304.2018.04.15.11.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Apr 2018 11:22:02 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v4 1/3] mm/shmem: add __rcu annotations and properly deref radix entry
Date: Sun, 15 Apr 2018 11:21:17 -0700
Message-Id: <20180415182119.4517-2-mike.kravetz@oracle.com>
In-Reply-To: <20180415182119.4517-1-mike.kravetz@oracle.com>
References: <20180415182119.4517-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

In preparation for memfd code restucture, clean up sparse warnings.
Most changes required adding __rcu annotations.  The routine
find_swap_entry was modified to properly deference radix tree
entries.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/shmem.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index b85919243399..c7bad16fe884 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -327,7 +327,7 @@ static int shmem_radix_tree_replace(struct address_space *mapping,
 			pgoff_t index, void *expected, void *replacement)
 {
 	struct radix_tree_node *node;
-	void **pslot;
+	void __rcu **pslot;
 	void *item;
 
 	VM_BUG_ON(!expected);
@@ -395,7 +395,7 @@ static bool shmem_confirm_swap(struct address_space *mapping,
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 /* ifdef here to avoid bloating shmem.o when not necessary */
 
-int shmem_huge __read_mostly;
+static int shmem_huge __read_mostly;
 
 #if defined(CONFIG_SYSFS) || defined(CONFIG_TMPFS)
 static int shmem_parse_huge(const char *str)
@@ -682,7 +682,7 @@ unsigned long shmem_partial_swap_usage(struct address_space *mapping,
 						pgoff_t start, pgoff_t end)
 {
 	struct radix_tree_iter iter;
-	void **slot;
+	void __rcu **slot;
 	struct page *page;
 	unsigned long swapped = 0;
 
@@ -1098,13 +1098,19 @@ static void shmem_evict_inode(struct inode *inode)
 static unsigned long find_swap_entry(struct radix_tree_root *root, void *item)
 {
 	struct radix_tree_iter iter;
-	void **slot;
+	void __rcu **slot;
 	unsigned long found = -1;
 	unsigned int checked = 0;
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, root, &iter, 0) {
-		if (*slot == item) {
+		void *entry = radix_tree_deref_slot(slot);
+
+		if (radix_tree_deref_retry(entry)) {
+			slot = radix_tree_iter_retry(&iter);
+			continue;
+		}
+		if (entry == item) {
 			found = iter.index;
 			break;
 		}
@@ -2623,7 +2629,7 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 static void shmem_tag_pins(struct address_space *mapping)
 {
 	struct radix_tree_iter iter;
-	void **slot;
+	void __rcu **slot;
 	pgoff_t start;
 	struct page *page;
 
@@ -2665,7 +2671,7 @@ static void shmem_tag_pins(struct address_space *mapping)
 static int shmem_wait_for_pins(struct address_space *mapping)
 {
 	struct radix_tree_iter iter;
-	void **slot;
+	void __rcu **slot;
 	pgoff_t start;
 	struct page *page;
 	int error, scan;
-- 
2.13.6

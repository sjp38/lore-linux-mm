Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D16038D0043
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:02 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 04/24] sys_swapon: separate swap_info allocation
Date: Tue,  1 Mar 2011 20:28:28 -0300
Message-Id: <1299022128-6239-5-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

Move the swap_info allocation to its own function. Only code movement,
no functional changes.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |   57 +++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 37 insertions(+), 20 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3ef2d67..91ca0f0 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1844,33 +1844,15 @@ static int __init max_swapfiles_check(void)
 late_initcall(max_swapfiles_check);
 #endif
 
-SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
+static struct swap_info_struct *alloc_swap_info(void)
 {
 	struct swap_info_struct *p;
-	char *name = NULL;
-	struct block_device *bdev = NULL;
-	struct file *swap_file = NULL;
-	struct address_space *mapping;
 	unsigned int type;
-	int i, prev;
 	int error;
-	union swap_header *swap_header;
-	unsigned int nr_good_pages;
-	int nr_extents = 0;
-	sector_t span;
-	unsigned long maxpages;
-	unsigned long swapfilepages;
-	unsigned char *swap_map = NULL;
-	struct page *page = NULL;
-	struct inode *inode = NULL;
-	int did_down = 0;
-
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
 
 	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (!p)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	spin_lock(&swap_lock);
 	for (type = 0; type < nr_swapfiles; type++) {
@@ -1906,6 +1888,41 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	p->next = -1;
 	spin_unlock(&swap_lock);
 
+	return p;
+
+out:
+	return ERR_PTR(error);
+}
+
+SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
+{
+	struct swap_info_struct *p;
+	char *name = NULL;
+	struct block_device *bdev = NULL;
+	struct file *swap_file = NULL;
+	struct address_space *mapping;
+	int i, prev;
+	int error;
+	union swap_header *swap_header;
+	unsigned int nr_good_pages;
+	int nr_extents = 0;
+	sector_t span;
+	unsigned long maxpages;
+	unsigned long swapfilepages;
+	unsigned char *swap_map = NULL;
+	struct page *page = NULL;
+	struct inode *inode = NULL;
+	int did_down = 0;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	p = alloc_swap_info();
+	if (IS_ERR(p)) {
+		error = PTR_ERR(p);
+		goto out;
+	}
+
 	name = getname(specialfile);
 	error = PTR_ERR(name);
 	if (IS_ERR(name)) {
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

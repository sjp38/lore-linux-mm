Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 794ED8D0039
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:46 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:42 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 04/24] sys_swapon: separate swap_info allocation
Date: Sat, 12 Feb 2011 16:49:05 -0200
Message-Id: <1297536565-8059-4-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

Move the swap_info allocation to its own function. Only code movement,
no functional changes.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |   57 +++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 37 insertions(+), 20 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index f0fc4c0..837e40f 100644
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

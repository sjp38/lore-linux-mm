Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0R7I2Nb026614
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 23:18:03 -0800 (PST)
From: pmeda@akamai.com
Date: Wed, 26 Jan 2005 23:22:39 -0800
Message-Id: <200501270722.XAA10830@allur.sanmateo.akamai.com>
Subject: [patch] ext2: Apply Jack's ext3 speedups
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Apply ext3 speedups added by Jan Kara to ext2.
Reference: http://linus.bkbits.net:8080/linux-2.5/gnupatch@41f127f2jwYahmKm0eWTJNpYcSyhPw

Signed-off-by: Prasanna Meda <pmeda@akamai.com>

--- a/fs/ext2/balloc.c	Wed Jan 26 23:04:10 2005
+++ b/fs/ext2/balloc.c	Wed Jan 26 23:04:28 2005
@@ -53,8 +53,8 @@ struct ext2_group_desc * ext2_get_group_
 		return NULL;
 	}
 	
-	group_desc = block_group / EXT2_DESC_PER_BLOCK(sb);
-	offset = block_group % EXT2_DESC_PER_BLOCK(sb);
+	group_desc = block_group >> EXT2_DESC_PER_BLOCK_BITS(sb);
+	offset = block_group & (EXT2_DESC_PER_BLOCK(sb) - 1);
 	if (!sbi->s_group_desc[group_desc]) {
 		ext2_error (sb, "ext2_get_group_desc",
 			    "Group descriptor not loaded - "
@@ -575,19 +575,17 @@ block_in_use(unsigned long block, struct
 
 static inline int test_root(int a, int b)
 {
-	if (a == 0)
-		return 1;
-	while (1) {
-		if (a == 1)
-			return 1;
-		if (a % b)
-			return 0;
-		a = a / b;
-	}
+	int num = b;
+
+	while (a > num)
+		num *= b;
+	return num == a;
 }
 
 static int ext2_group_sparse(int group)
 {
+	if (group <= 0)
+		return 1;
 	return (test_root(group, 3) || test_root(group, 5) ||
 		test_root(group, 7));
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

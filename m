Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DA7AB6B02A6
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:40:21 -0400 (EDT)
Received: by ewy28 with SMTP id 28so2356730ewy.14
        for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:40:19 -0700 (PDT)
From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 05/10] mm: check kmalloc() return value
Date: Wed, 28 Jul 2010 20:40:03 +0400
Message-Id: <1280335203-23305-1-git-send-email-segooon@gmail.com>
Sender: owner-linux-mm@kvack.org
To: kernel-janitors@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jan Beulich <jbeulich@novell.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kmalloc() may fail, if so return -ENOMEM.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 mm/vmalloc.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b7e314b..f63684a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2437,8 +2437,11 @@ static int vmalloc_open(struct inode *inode, struct file *file)
 	unsigned int *ptr = NULL;
 	int ret;
 
-	if (NUMA_BUILD)
+	if (NUMA_BUILD) {
 		ptr = kmalloc(nr_node_ids * sizeof(unsigned int), GFP_KERNEL);
+		if (ptr == NULL)
+			return -ENOMEM;
+	}
 	ret = seq_open(file, &vmalloc_op);
 	if (!ret) {
 		struct seq_file *m = file->private_data;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 806226B0104
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 04:11:54 -0400 (EDT)
From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 4/4] mm: introduce no_ksm to disable totally KSM
Date: Tue, 21 Jun 2011 16:10:45 +0800
Message-Id: <1308643849-3325-4-git-send-email-amwang@redhat.com>
In-Reply-To: <1308643849-3325-1-git-send-email-amwang@redhat.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Amerigo Wang <amwang@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org

Introduce a new kernel parameter "no_ksm" to totally disable KSM.

Signed-off-by: WANG Cong <amwang@redhat.com>
---
 mm/ksm.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 9a68b0c..eeb45a2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1984,11 +1984,24 @@ static struct attribute_group ksm_attr_group = {
 };
 #endif /* CONFIG_SYSFS */
 
+static int no_ksm;
+static int __init setup_ksm(char *str)
+{
+	no_ksm = 1;
+	return 0;
+}
+__setup("no_ksm", setup_ksm);
+
 static int __init ksm_init(void)
 {
 	struct task_struct *ksm_thread;
 	int err;
 
+	if (no_ksm) {
+		printk(KERN_INFO "ksm: disabled by cmdline\n");
+		return 0;
+	}
+
 	err = ksm_slab_init();
 	if (err)
 		goto out;
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

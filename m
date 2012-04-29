Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A0CE46B00E7
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:46:00 -0400 (EDT)
Received: by mail-pz0-f49.google.com with SMTP id q36so2826975dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 23:46:00 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 12/14] mm compaction,sysctl: remove proc input checks out of sysctl handlers
Date: Sun, 29 Apr 2012 08:45:35 +0200
Message-Id: <1335681937-3715-12-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, ebiederm@xmission.com, akpm@linux-foundation.org, tglx@linutronix.de
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Simplify sysctl handler by removing user input checks and using the callback
provided by the sysctl table.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/compaction.h |    2 --
 kernel/sysctl.c            |    2 +-
 mm/compaction.c            |    8 --------
 3 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 51a90b7..35788e4 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -16,8 +16,6 @@ extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos);
 extern int sysctl_extfrag_threshold;
-extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
-			void __user *buffer, size_t *length, loff_t *ppos);
 
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index dacece7..f9ce79b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1196,7 +1196,7 @@ static struct ctl_table vm_table[] = {
 		.data		= &sysctl_extfrag_threshold,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= sysctl_extfrag_handler,
+		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &min_extfrag_threshold,
 		.extra2		= &max_extfrag_threshold,
 	},
diff --git a/mm/compaction.c b/mm/compaction.c
index 58f7a93..74c44f2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -863,14 +863,6 @@ int sysctl_compaction_handler(struct ctl_table *table, int write,
 	return 0;
 }
 
-int sysctl_extfrag_handler(struct ctl_table *table, int write,
-			void __user *buffer, size_t *length, loff_t *ppos)
-{
-	proc_dointvec_minmax(table, write, buffer, length, ppos);
-
-	return 0;
-}
-
 #if defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
 ssize_t sysfs_compact_node(struct device *dev,
 			struct device_attribute *attr,
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 86B4E900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:12:38 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so628537ieb.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:12:38 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id o19si3609933igs.5.2015.06.04.06.12.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:12:38 -0700 (PDT)
Message-ID: <55704C79.5060608@huawei.com>
Date: Thu, 4 Jun 2015 21:02:49 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 08/12] mm: use mirrorable to switch allocate mirrored
 memory
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add a new interface in path /proc/sys/vm/mirrorable. When set to 1, it means
we should allocate mirrored memory for both user and kernel processes.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/mmzone.h | 1 +
 kernel/sysctl.c        | 9 +++++++++
 mm/page_alloc.c        | 1 +
 3 files changed, 11 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f82e3ae..20888dd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -85,6 +85,7 @@ struct mirror_info {
 };
 
 extern struct mirror_info mirror_info;
+extern int sysctl_mirrorable;
 #  define is_migrate_mirror(migratetype) unlikely((migratetype) == MIGRATE_MIRROR)
 #else
 #  define is_migrate_mirror(migratetype) false
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 2082b1a..dc2625e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1514,6 +1514,15 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+#ifdef CONFIG_MEMORY_MIRROR
+	{
+		.procname	= "mirrorable",
+		.data		= &sysctl_mirrorable,
+		.maxlen		= sizeof(sysctl_mirrorable),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+#endif
 	{
 		.procname	= "user_reserve_kbytes",
 		.data		= &sysctl_user_reserve_kbytes,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 249a8f6..63b90ca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -212,6 +212,7 @@ int user_min_free_kbytes = -1;
 
 #ifdef CONFIG_MEMORY_MIRROR
 struct mirror_info mirror_info;
+int sysctl_mirrorable = 0;
 #endif
 
 static unsigned long __meminitdata nr_kernel_pages;
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

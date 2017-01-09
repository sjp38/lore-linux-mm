Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 150F16B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 06:16:33 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so14332369wms.7
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 03:16:33 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id q9si7988079wrd.130.2017.01.09.03.16.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 03:16:31 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] stable-fixup: hotplug: fix unused function warning
Date: Mon,  9 Jan 2017 11:47:50 +0100
Message-Id: <20170109104811.1453295-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Yu Zhao <yuzhao@google.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org

The backport of upstream commit 777c6e0daebb ("hotplug: Make
register and unregister notifier API symmetric") to linux-4.4.y
introduced a harmless warning in 'allnoconfig' builds as spotted by
kernelci.org:

kernel/cpu.c:226:13: warning: 'cpu_notify_nofail' defined but not used [-Wunused-function]

So far, this is the only stable tree that is affected, as linux-4.6 and
higher contain commit 984581728eb4 ("cpu/hotplug: Split out cpu down functions")
that makes the function used in all configurations, while older longterm
releases so far don't seem to have a backport of 777c6e0daebb.

The fix for the warning is trivial: move the unused function back
into the #ifdef section where it was before.

Link: https://kernelci.org/build/id/586fcacb59b514049ef6c3aa/logs/
Fixes: 1c0f4e0ebb79 ("hotplug: Make register and unregister notifier API symmetric") in v4.4.y
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 kernel/cpu.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/cpu.c b/kernel/cpu.c
index cd6d1258554e..40d20bf5de28 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -223,10 +223,6 @@ static int cpu_notify(unsigned long val, void *v)
 	return __cpu_notify(val, v, -1, NULL);
 }
 
-static void cpu_notify_nofail(unsigned long val, void *v)
-{
-	BUG_ON(cpu_notify(val, v));
-}
 EXPORT_SYMBOL(register_cpu_notifier);
 EXPORT_SYMBOL(__register_cpu_notifier);
 
@@ -245,6 +241,11 @@ void __unregister_cpu_notifier(struct notifier_block *nb)
 EXPORT_SYMBOL(__unregister_cpu_notifier);
 
 #ifdef CONFIG_HOTPLUG_CPU
+static void cpu_notify_nofail(unsigned long val, void *v)
+{
+	BUG_ON(cpu_notify(val, v));
+}
+
 /**
  * clear_tasks_mm_cpumask - Safely clear tasks' mm_cpumask for a CPU
  * @cpu: a CPU id
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

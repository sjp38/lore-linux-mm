Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 958446B0253
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:40:28 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id p65so119678770wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 14:40:28 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id gg9si29220536wjb.115.2016.03.14.14.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 14:40:27 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id l68so126953717wml.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 14:40:27 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v3 1/2] mm, vmstat: calculate particular vm event
Date: Mon, 14 Mar 2016 23:40:10 +0200
Message-Id: <1457991611-6211-2-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1457991611-6211-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1457991611-6211-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

Currently, vmstat can calculate specific vm event with all_vm_events()
however it allocates all vm events to stack. This patch introduces
a helper to sum value of a specific vm event over all cpu, without
loading all the events.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
Changes in v2:
 - this patch newly created in this version
 - create sum event function to
   calculate particular vm event (Kirill A. Shutemov)

Changes in v3:
 - add dummy definition of sum_vm_event
   when CONFIG_VM_EVENTS is not set
   (Kirill A. Shutemov)

 include/linux/vmstat.h |  6 ++++++
 mm/vmstat.c            | 12 ++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 73fae8c..e5ec287 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -53,6 +53,8 @@ static inline void count_vm_events(enum vm_event_item item, long delta)
 
 extern void all_vm_events(unsigned long *);
 
+extern unsigned long sum_vm_event(enum vm_event_item item);
+
 extern void vm_events_fold_cpu(int cpu);
 
 #else
@@ -73,6 +75,10 @@ static inline void __count_vm_events(enum vm_event_item item, long delta)
 static inline void all_vm_events(unsigned long *ret)
 {
 }
+static inline unsigned long sum_vm_event(enum vm_event_item item)
+{
+	return 0;
+}
 static inline void vm_events_fold_cpu(int cpu)
 {
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5e43004..b76d664 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -34,6 +34,18 @@
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
 EXPORT_PER_CPU_SYMBOL(vm_event_states);
 
+unsigned long sum_vm_event(enum vm_event_item item)
+{
+	int cpu;
+	unsigned long ret = 0;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu)
+		ret += per_cpu(vm_event_states, cpu).event[item];
+	put_online_cpus();
+	return ret;
+}
+
 static void sum_vm_events(unsigned long *ret)
 {
 	int cpu;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

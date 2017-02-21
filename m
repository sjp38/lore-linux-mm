Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 854EA6B0038
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 12:32:46 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w185so191080938ita.5
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 09:32:46 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f32si20771230ioj.67.2017.02.21.09.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 09:32:34 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LHNk5p089926
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 12:32:34 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28rm7t951w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 12:32:34 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Tue, 21 Feb 2017 12:32:33 -0500
Subject: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Tue, 21 Feb 2017 12:22:34 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20170221172234.8047.33382.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, vkuznets@redhat.com
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com

Commit 31bc3858e "add automatic onlining policy for the newly added memory"
provides the capability to have added memory automatically onlined
during add, but this appears to be slightly broken.

The current implementation uses walk_memory_range() to call
online_memory_block, which uses memory_block_change_state() to online
the memory. Instead I think we should be calling device_online()
for the memory block in online_memory_block. This would online
the memory (the memory bus online routine memory_subsys_online()
called from device_online calls memory_block_change_state()) and
properly update the device struct offline flag.

As a result of the current implementation, attempting to remove
a memory block after adding it using auto online fails. This is
because doing a remove, for instance
'echo offline > /sys/devices/system/memory/memoryXXX/state', uses
device_offline() which checks the dev->offline flag.

There is a workaround in that a user could online the memory or have
a udev rule to online the memory by using the sysfs interface. The
sysfs interface to online memory goes through device_online() which
should updated the dev->offline flag. I'm not sure that having kernel
memory hotplug rely on userspace actions is the correct way to go.

I have tried reading through the email threads when the origianl patch
was submitted and could not determine if this is the expected behavior.
The problem with the current behavior was found when trying to update
memory hotplug on powerpc to use auto online.

-Nathan Fontenot
---
 drivers/base/memory.c  |    2 +-
 include/linux/memory.h |    3 ---
 mm/memory_hotplug.c    |    2 +-
 3 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 8ab8ea1..ede46f3 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -249,7 +249,7 @@ static bool pages_correctly_reserved(unsigned long start_pfn)
 	return ret;
 }
 
-int memory_block_change_state(struct memory_block *mem,
+static int memory_block_change_state(struct memory_block *mem,
 		unsigned long to_state, unsigned long from_state_req)
 {
 	int ret = 0;
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 093607f..b723a68 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -109,9 +109,6 @@ static inline int memory_isolate_notify(unsigned long val, void *v)
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
 extern int register_new_memory(int, struct mem_section *);
-extern int memory_block_change_state(struct memory_block *mem,
-				     unsigned long to_state,
-				     unsigned long from_state_req);
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern int unregister_memory_section(struct mem_section *);
 #endif
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e43142c1..6f7a289 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1329,7 +1329,7 @@ int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
 
 static int online_memory_block(struct memory_block *mem, void *arg)
 {
-	return memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
+	return device_online(&mem->dev);
 }
 
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

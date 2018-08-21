Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D31686B1E4F
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 06:44:52 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j9-v6so15842745qtn.22
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 03:44:52 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l62-v6si4390933qkb.0.2018.08.21.03.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 03:44:52 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFCv2 5/6] powerpc/powernv: hold device_hotplug_lock in memtrace_offline_pages()
Date: Tue, 21 Aug 2018 12:44:17 +0200
Message-Id: <20180821104418.12710-6-david@redhat.com>
In-Reply-To: <20180821104418.12710-1-david@redhat.com>
References: <20180821104418.12710-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, David Hildenbrand <david@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Rashmica Gupta <rashmica.g@gmail.com>, Balbir Singh <bsingharora@gmail.com>, Michael Neuling <mikey@neuling.org>

Let's perform all checking + offlining + removing under
device_hotplug_lock, so nobody can mess with these devices via
sysfs concurrently.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Rashmica Gupta <rashmica.g@gmail.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Michael Neuling <mikey@neuling.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/powerpc/platforms/powernv/memtrace.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
index ef7181d4fe68..473e59842ec5 100644
--- a/arch/powerpc/platforms/powernv/memtrace.c
+++ b/arch/powerpc/platforms/powernv/memtrace.c
@@ -74,9 +74,13 @@ static bool memtrace_offline_pages(u32 nid, u64 start_pfn, u64 nr_pages)
 {
 	u64 end_pfn = start_pfn + nr_pages - 1;
 
+	lock_device_hotplug();
+
 	if (walk_memory_range(start_pfn, end_pfn, NULL,
-	    check_memblock_online))
+	    check_memblock_online)) {
+		unlock_device_hotplug();
 		return false;
+	}
 
 	walk_memory_range(start_pfn, end_pfn, (void *)MEM_GOING_OFFLINE,
 			  change_memblock_state);
@@ -84,14 +88,16 @@ static bool memtrace_offline_pages(u32 nid, u64 start_pfn, u64 nr_pages)
 	if (offline_pages(start_pfn, nr_pages)) {
 		walk_memory_range(start_pfn, end_pfn, (void *)MEM_ONLINE,
 				  change_memblock_state);
+		unlock_device_hotplug();
 		return false;
 	}
 
 	walk_memory_range(start_pfn, end_pfn, (void *)MEM_OFFLINE,
 			  change_memblock_state);
 
-	remove_memory(nid, start_pfn << PAGE_SHIFT, nr_pages << PAGE_SHIFT);
+	__remove_memory(nid, start_pfn << PAGE_SHIFT, nr_pages << PAGE_SHIFT);
 
+	unlock_device_hotplug();
 	return true;
 }
 
-- 
2.17.1

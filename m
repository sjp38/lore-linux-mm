Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 126AF6B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 06:42:55 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 1so127103781pgz.5
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 03:42:55 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l2si12482163pln.180.2017.02.26.03.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Feb 2017 03:42:54 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1QBdpNb064689
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 06:42:53 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28u88puemg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 06:42:53 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sebott@linux.vnet.ibm.com>;
	Sun, 26 Feb 2017 11:42:50 -0000
Date: Sun, 26 Feb 2017 12:42:44 +0100 (CET)
From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: [PATCH] mm, add_memory_resource: hold device_hotplug lock over
 mem_hotplug_{begin, done}
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Message-Id: <alpine.LFD.2.20.1702261231580.3067@schleppi.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>

With 4.10.0-10265-gc4f3f22 the following warning is triggered on s390:

WARNING: CPU: 6 PID: 1 at drivers/base/core.c:643 assert_held_device_hotplug+0x4a/0x58
[    5.731214] Call Trace:
[    5.731219] ([<000000000067b8b0>] assert_held_device_hotplug+0x40/0x58)
[    5.731225]  [<0000000000337914>] mem_hotplug_begin+0x34/0xc8
[    5.731231]  [<00000000008b897e>] add_memory_resource+0x7e/0x1f8
[    5.731236]  [<00000000008b8bd2>] add_memory+0xda/0x130
[    5.731243]  [<0000000000d7f0dc>] add_memory_merged+0x15c/0x178
[    5.731247]  [<0000000000d7f3a6>] sclp_detect_standby_memory+0x2ae/0x2f8
[    5.731252]  [<00000000001002ba>] do_one_initcall+0xa2/0x150
[    5.731258]  [<0000000000d3adc0>] kernel_init_freeable+0x228/0x2d8
[    5.731263]  [<00000000008b6572>] kernel_init+0x2a/0x140
[    5.731267]  [<00000000008c3972>] kernel_thread_starter+0x6/0xc
[    5.731272]  [<00000000008c396c>] kernel_thread_starter+0x0/0xc
[    5.731276] no locks held by swapper/0/1.
[    5.731280] Last Breaking-Event-Address:
[    5.731285]  [<000000000067b8b6>] assert_held_device_hotplug+0x46/0x58
[    5.731292] ---[ end trace 46480df21194c96a ]---


The following patch fixes that for me:

----->8
mm, add_memory_resource: hold device_hotplug lock over mem_hotplug_{begin, done}

With commit 3fc219241 ("mm: validate device_hotplug is held for memory hotplug")
a lock assertion was added to mem_hotplug_begin() which led to a warning
when add_memory() is called. Fix this by acquiring device_hotplug_lock in
add_memory_resource().

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1d3ed58..c633bbc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1361,6 +1361,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 		new_pgdat = !p;
 	}
 
+	lock_device_hotplug();
 	mem_hotplug_begin();
 
 	/*
@@ -1416,6 +1417,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 
 out:
 	mem_hotplug_done();
+	unlock_device_hotplug();
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory_resource);
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

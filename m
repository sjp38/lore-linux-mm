Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E12FD6B000C
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:24:20 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 5-v6so2337371qke.19
        for <linux-mm@kvack.org>; Wed, 23 May 2018 11:24:20 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j5-v6si2158014qvi.225.2018.05.23.11.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 11:24:20 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFCv2 3/4] s390: numa: implement memory_add_physaddr_to_nid()
Date: Wed, 23 May 2018 20:24:03 +0200
Message-Id: <20180523182404.11433-4-david@redhat.com>
In-Reply-To: <20180523182404.11433-1-david@redhat.com>
References: <20180523182404.11433-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-s390@vger.kernel.org

The common interface to be used with add_memory().

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-s390@vger.kernel.org
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/s390/numa/numa.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/s390/numa/numa.c b/arch/s390/numa/numa.c
index 06a80434cfe6..8902652ab3e5 100644
--- a/arch/s390/numa/numa.c
+++ b/arch/s390/numa/numa.c
@@ -44,6 +44,18 @@ int numa_pfn_to_nid(unsigned long pfn)
 	return mode->__pfn_to_nid ? mode->__pfn_to_nid(pfn) : 0;
 }
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+int memory_add_physaddr_to_nid(u64 addr)
+{
+	int nid = numa_pfn_to_nid(PFN_DOWN(addr));
+
+	if (nid < 0)
+		return 0;
+	return nid;
+}
+EXPORT_SYMBOL(memory_add_physaddr_to_nid);
+#endif
+
 void numa_update_cpu_topology(void)
 {
 	if (mode->update_cpu_topology)
-- 
2.17.0

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9496B7404
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:00:27 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y135-v6so8953656oie.11
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:00:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t196-v6si1682756oif.57.2018.09.05.09.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:00:26 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85FvaUe081493
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:00:25 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mah4g3qyr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:00:24 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:00:21 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 10/29] memblock: replace __alloc_bootmem_node_nopanic with memblock_alloc_try_nid_nopanic
Date: Wed,  5 Sep 2018 18:59:25 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-11-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The __alloc_bootmem_node_nopanic() is used only once, there is no reason to
add a wrapper for memblock_alloc_try_nid_nopanic for it.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/x86/kernel/setup_percpu.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
index ea554f8..67d48e26 100644
--- a/arch/x86/kernel/setup_percpu.c
+++ b/arch/x86/kernel/setup_percpu.c
@@ -112,8 +112,10 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
 		pr_debug("per cpu data for cpu%d %lu bytes at %016lx\n",
 			 cpu, size, __pa(ptr));
 	} else {
-		ptr = __alloc_bootmem_node_nopanic(NODE_DATA(node),
-						   size, align, goal);
+		ptr = memblock_alloc_try_nid_nopanic(size, align, goal,
+						     BOOTMEM_ALLOC_ACCESSIBLE,
+						     node);
+
 		pr_debug("per cpu data for cpu%d %lu bytes on node%d at %016lx\n",
 			 cpu, size, node, __pa(ptr));
 	}
-- 
2.7.4

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3696B0276
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 11:45:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p66so158036038pga.4
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 08:45:11 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q204si32549477pfq.242.2016.11.16.08.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 08:45:10 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAGGdNtB098118
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 11:45:09 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26rts31w05-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 11:45:09 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 16 Nov 2016 11:45:08 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH] powerpc/mm: allow memory hotplug into an offline node
Date: Wed, 16 Nov 2016 10:45:03 -0600
In-Reply-To: <20161116164057.mzlhfigsuwn53r72@arbab-laptop.austin.ibm.com>
References: <20161116164057.mzlhfigsuwn53r72@arbab-laptop.austin.ibm.com>
Message-Id: <1479314703-18989-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>

Relax the check preventing us from hotplugging into an offline node.

This limitation was added in commit 482ec7c403d2 ("[PATCH] powerpc numa:
Support sparse online node map") to prevent adding resources to an
uninitialized node.

These days, there is no harm in doing so. The addition will actually
cause the node to be initialized and onlined; add_memory_resource()
calls hotadd_new_pgdat() (if necessary) and node_set_online().

Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: John Allen <jallen@linux.vnet.ibm.com>
Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
This applies on top of "powerpc/mm: allow memory hotplug into a
memoryless node", currently in the -mm tree:
http://lkml.kernel.org/r/1479160961-25840-2-git-send-email-arbab@linux.vnet.ibm.com

 arch/powerpc/mm/numa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index d69f6f6..07620c9 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -1091,7 +1091,7 @@ int hot_add_scn_to_nid(unsigned long scn_addr)
 		nid = hot_add_node_scn_to_nid(scn_addr);
 	}
 
-	if (nid < 0 || !node_online(nid))
+	if (nid < 0 || !node_possible(nid))
 		nid = first_online_node;
 
 	return nid;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

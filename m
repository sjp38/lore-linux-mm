Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF8176B000D
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:16:30 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id c37so3958096wra.5
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:16:30 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id t8si2130052wmc.216.2018.02.20.08.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:16:29 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 3/6] powerpc: numa: Use the right #ifdef guards around functions
Date: Tue, 20 Feb 2018 17:14:21 +0100
Message-Id: <20180220161424.5421-4-j.neuschaefer@gmx.net>
In-Reply-To: <20180220161424.5421-1-j.neuschaefer@gmx.net>
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Michael Bringmann <mwb@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

of_node_to_nid and dump_numa_cpu_topology are declared inline in their
respective header files, if CONFIG_NUMA is not set. Thus it is only
valid to define these functions in numa.c if CONFIG_NUMA is set.
(numa.c, despite the name, isn't conditionalized on CONFIG_NUMA, but
CONFIG_NEED_MULTIPLE_NODES.)

Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
---
 arch/powerpc/mm/numa.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 0570bc2a0b13..df03a65b658f 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -254,6 +254,7 @@ static int of_node_to_nid_single(struct device_node *device)
 	return nid;
 }
 
+#ifdef CONFIG_NUMA
 /* Walk the device tree upwards, looking for an associativity id */
 int of_node_to_nid(struct device_node *device)
 {
@@ -272,6 +273,7 @@ int of_node_to_nid(struct device_node *device)
 	return nid;
 }
 EXPORT_SYMBOL(of_node_to_nid);
+#endif
 
 static int __init find_min_common_depth(void)
 {
@@ -744,6 +746,7 @@ static void __init setup_nonnuma(void)
 	}
 }
 
+#ifdef CONFIG_NUMA
 void __init dump_numa_cpu_topology(void)
 {
 	unsigned int node;
@@ -778,6 +781,7 @@ void __init dump_numa_cpu_topology(void)
 		pr_cont("\n");
 	}
 }
+#endif
 
 /* Initialize NODE_DATA for a node on the local memory */
 static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

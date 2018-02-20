Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A24CB6B0010
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:16:46 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 7so8256763wrd.22
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:16:46 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id y143si1259444wme.128.2018.02.20.08.16.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:16:45 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 5/6] powerpc: Implement DISCONTIGMEM and allow selection on PPC32
Date: Tue, 20 Feb 2018 17:14:23 +0100
Message-Id: <20180220161424.5421-6-j.neuschaefer@gmx.net>
In-Reply-To: <20180220161424.5421-1-j.neuschaefer@gmx.net>
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Michael Bringmann <mwb@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>

The implementation of pfn_to_nid and pfn_valid in mmzone.h is based on
arch/metag's implementation.

Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
---

NOTE: Checking NODE_DATA(nid) in pfn_to_nid appears to be uncommon.
Running up to MAX_NUMNODES instead of checking NODE_DATA(nid) would
require the node_data array to be filled with valid pointers.
---
 arch/powerpc/Kconfig              |  5 ++++-
 arch/powerpc/include/asm/mmzone.h | 21 +++++++++++++++++++++
 arch/powerpc/mm/numa.c            |  7 +++++++
 3 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 73ce5dd07642..c2633b7b8ed9 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -639,7 +639,6 @@ config HAVE_MEMORYLESS_NODES
 
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
-	depends on PPC64
 
 config ARCH_FLATMEM_ENABLE
 	def_bool y
@@ -654,6 +653,10 @@ config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
 	depends on PPC_BOOK3S_64
 
+config ARCH_DISCONTIGMEM_ENABLE
+	def_bool y
+	depends on PPC32
+
 config SYS_SUPPORTS_HUGETLBFS
 	bool
 
diff --git a/arch/powerpc/include/asm/mmzone.h b/arch/powerpc/include/asm/mmzone.h
index 91c69ff53a8a..1684a5c98d23 100644
--- a/arch/powerpc/include/asm/mmzone.h
+++ b/arch/powerpc/include/asm/mmzone.h
@@ -26,6 +26,27 @@ extern struct pglist_data *node_data[];
  */
 #define NODE_DATA(nid)		(node_data[nid])
 
+static inline int pfn_to_nid(unsigned long pfn)
+{
+	int nid;
+
+	for (nid = 0; nid < MAX_NUMNODES && NODE_DATA(nid); nid++)
+		if (pfn >= node_start_pfn(nid) && pfn <= node_end_pfn(nid))
+			return nid;
+
+	return -1;
+}
+
+static inline int pfn_valid(int pfn)
+{
+	int nid = pfn_to_nid(pfn);
+
+	if (nid >= 0)
+		return pfn < node_end_pfn(nid);
+
+	return 0;
+}
+
 /*
  * Following are specific to this numa platform.
  */
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index dfe279529463..ec47f1081509 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -744,6 +744,13 @@ static void __init setup_nonnuma(void)
 				  PFN_PHYS(end_pfn - start_pfn),
 				  &memblock.memory, nid);
 		node_set_online(nid);
+
+		/*
+		 * On DISCONTIGMEM systems, place different memory blocks into
+		 * different nodes.
+		 */
+		if (IS_ENABLED(CONFIG_DISCONTIGMEM) && nid < MAX_NUMNODES - 1)
+			nid++;
 	}
 }
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

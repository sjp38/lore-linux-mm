Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 562B66B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 13:35:09 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id 142so3369772ykq.2
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 10:35:09 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id f25si12384768yho.178.2014.01.28.10.35.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 10:35:08 -0800 (PST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 28 Jan 2014 11:35:07 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 89EDFC40002
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 11:35:03 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0SIZ3eL3604790
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 19:35:03 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0SIZ2io022993
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 11:35:03 -0700
Date: Tue, 28 Jan 2014 10:34:57 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH] powerpc: enable CONFIG_HAVE_MEMORYLESS_NODES
Message-ID: <20140128183457.GA9315@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Anton Blanchard <anton@samba.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Anton Blanchard found an issue with an LPAR that had no memory in Node
0. Christoph Lameter recommended, as one possible solution, to use
numa_mem_id() for locality of the nearest memory node-wise. However,
numa_mem_id() [and the other related APIs] are only useful if
CONFIG_HAVE_MEMORYLESS_NODES is set. This is only the case for ia64
currently, but clearly we can have memoryless nodes on ppc64. Add the
Kconfig option and define it to be the same value as CONFIG_NUMA.

On the LPAR in question, which was very inefficiently using slabs, this
took the slab consumption at boot from roughly 7GB to roughly 4GB.
    
---
Ben, the only question I have wrt this change is if it's appropriate to
change it for all powerpc configs (that have NUMA on)?

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 25493a0..bb2d5fe 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -447,6 +447,9 @@ config NODES_SHIFT
 	default "4"
 	depends on NEED_MULTIPLE_NODES
 
+config HAVE_MEMORYLESS_NODES
+	def_bool NUMA
+
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 	depends on PPC64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

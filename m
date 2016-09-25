Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBD1028026C
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:37:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c84so337812272pfj.2
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 11:37:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x68si20730922pfx.172.2016.09.25.11.37.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 11:37:14 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8PIXNGi143561
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:37:13 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25p6ahmhcv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:37:13 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Sun, 25 Sep 2016 12:37:12 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v3 5/5] mm: enable CONFIG_MOVABLE_NODE on powerpc
Date: Sun, 25 Sep 2016 13:36:56 -0500
In-Reply-To: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1474828616-16608-6-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

To create a movable node, we need to hotplug all of its memory into
ZONE_MOVABLE.

Note that to do this, auto_online_blocks should be off. Since the memory
will first be added to the default zone, we must explicitly use
online_movable to online.

Because such a node contains no normal memory, can_online_high_movable()
will only allow us to do the onlining if CONFIG_MOVABLE_NODE is set.
Enable the use of this config option on PPC64 platforms.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 Documentation/kernel-parameters.txt | 2 +-
 mm/Kconfig                          | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index a4f4d69..3d8460d 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2344,7 +2344,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
-	movable_node	[KNL,X86] Boot-time switch to enable the effects
+	movable_node	[KNL,X86,PPC] Boot-time switch to enable the effects
 			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
 
 	MTD_Partition=	[MTD]
diff --git a/mm/Kconfig b/mm/Kconfig
index be0ee11..4b19cd3 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -153,7 +153,7 @@ config MOVABLE_NODE
 	bool "Enable to assign a node which has only movable memory"
 	depends on HAVE_MEMBLOCK
 	depends on NO_BOOTMEM
-	depends on X86_64
+	depends on X86_64 || PPC64
 	depends on NUMA
 	default n
 	help
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

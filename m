Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88579280266
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:37:07 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g67so62829128qkd.0
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 11:37:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v8si12145995qkv.36.2016.09.25.11.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 11:37:06 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8PIXMdI036249
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:37:06 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25p6u0unt1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:37:06 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Sun, 25 Sep 2016 12:37:05 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v3 4/5] powerpc/mm: restore top-down allocation when using movable_node
Date: Sun, 25 Sep 2016 13:36:55 -0500
In-Reply-To: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1474828616-16608-5-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

At boot, the movable_node option sets bottom-up memblock allocation.

This reduces the chance that, in the window before movable memory has
been identified, an allocation for the kernel might come from a movable
node. By going bottom-up, early allocations will most likely come from
the same node as the kernel image, which is necessarily in a nonmovable
node.

Then, once any known hotplug memory has been marked, allocation can be
reset back to top-down. On x86, this is done in numa_init(). This patch
does the same on power, in numa initmem_init().

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 arch/powerpc/mm/numa.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index d7ac419..fdf1e69 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -945,6 +945,9 @@ void __init initmem_init(void)
 	max_low_pfn = memblock_end_of_DRAM() >> PAGE_SHIFT;
 	max_pfn = max_low_pfn;
 
+	/* bottom-up allocation may have been set by movable_node */
+	memblock_set_bottom_up(false);
+
 	if (parse_numa_properties())
 		setup_nonnuma();
 	else
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

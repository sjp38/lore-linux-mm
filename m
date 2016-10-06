Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 173806B0253
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 14:36:46 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ry6so6877115pac.1
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 11:36:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h7si5030352pad.79.2016.10.06.11.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Oct 2016 11:36:45 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u96IXTmT084380
	for <linux-mm@kvack.org>; Thu, 6 Oct 2016 14:36:44 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25wu5d2u6u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Oct 2016 14:36:44 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 6 Oct 2016 12:36:43 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v4 2/5] drivers/of: do not add memory for unavailable nodes
Date: Thu,  6 Oct 2016 13:36:32 -0500
In-Reply-To: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1475778995-1420-3-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

Respect the standard dt "status" property when scanning memory nodes in
early_init_dt_scan_memory(), so that if the node is unavailable, no
memory will be added.

The use case at hand is accelerator or device memory, which may be
unusable until post-boot initialization of the memory link. Such a node
can be described in the dt as any other, given its status is "disabled".
Per the device tree specification,

"disabled"
	Indicates that the device is not presently operational, but it
	might become operational in the future (for example, something
	is not plugged in, or switched off).

Once such memory is made operational, it can then be hotplugged.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 drivers/of/fdt.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index b138efb..08e5d94 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -1056,6 +1056,9 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
 	} else if (strcmp(type, "memory") != 0)
 		return 0;
 
+	if (!of_flat_dt_device_is_available(node))
+		return 0;
+
 	reg = of_get_flat_dt_prop(node, "linux,usable-memory", &l);
 	if (reg == NULL)
 		reg = of_get_flat_dt_prop(node, "reg", &l);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

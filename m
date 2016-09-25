Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 27732280269
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:37:10 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu14so315379794pad.0
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 11:37:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 143si20701057pfu.156.2016.09.25.11.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 11:37:09 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8PIXKwH063554
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:37:09 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25p73eudcy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:37:08 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Sun, 25 Sep 2016 14:37:07 -0400
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v3 2/5] drivers/of: do not add memory for unavailable nodes
Date: Sun, 25 Sep 2016 13:36:53 -0500
In-Reply-To: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1474828616-16608-3-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

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
index 9241c6e..59b772a 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -1056,6 +1056,9 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
 	} else if (strcmp(type, "memory") != 0)
 		return 0;
 
+	if (!of_flat_dt_is_available(node))
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

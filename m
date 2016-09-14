Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1B96B025E
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:07:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 128so50841823pfb.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 13:07:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id lt14si6187401pab.179.2016.09.14.13.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 13:07:09 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8EK57IT069027
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:07:08 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25excdwekw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:07:08 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 14 Sep 2016 14:07:07 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v2 1/3] drivers/of: recognize status property of dt memory nodes
Date: Wed, 14 Sep 2016 15:06:56 -0500
In-Reply-To: <1473883618-14998-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1473883618-14998-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1473883618-14998-2-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

Respect the standard dt "status" property when scanning memory nodes in
early_init_dt_scan_memory(), so that if the property is present and not
"okay", no memory will be added.

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
 drivers/of/fdt.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index 085c638..fc19590 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -1022,8 +1022,10 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
 				     int depth, void *data)
 {
 	const char *type = of_get_flat_dt_prop(node, "device_type", NULL);
+	const char *status;
 	const __be32 *reg, *endp;
 	int l;
+	bool add_memory;
 
 	/* We are scanning "memory" nodes only */
 	if (type == NULL) {
@@ -1044,6 +1046,9 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
 
 	endp = reg + (l / sizeof(__be32));
 
+	status = of_get_flat_dt_prop(node, "status", NULL);
+	add_memory = !status || !strcmp(status, "okay");
+
 	pr_debug("memory scan node %s, reg size %d,\n", uname, l);
 
 	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
@@ -1057,6 +1062,9 @@ int __init early_init_dt_scan_memory(unsigned long node, const char *uname,
 		pr_debug(" - %llx ,  %llx\n", (unsigned long long)base,
 		    (unsigned long long)size);
 
+		if (!add_memory)
+			continue;
+
 		early_init_dt_add_memory_arch(base, size);
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5CC8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id u20so17813346pfa.1
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:05 -0800 (PST)
Message-Id: <20181226133351.106676005@intel.com>
Date: Wed, 26 Dec 2018 21:14:47 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 01/21] e820: cheat PMEM as DRAM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0001-e820-Force-PMEM-entry-as-RAM-type-to-enumerate-NUMA-.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Fan Du <fan.du@intel.com>

This is a hack to enumerate PMEM as NUMA nodes.
It's necessary for current BIOS that don't yet fill ACPI HMAT table.

WARNING: take care to backup. It is mutual exclusive with libnvdimm
subsystem and can destroy ndctl managed namespaces.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/kernel/e820.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux.orig/arch/x86/kernel/e820.c	2018-12-23 19:20:34.587078783 +0800
+++ linux/arch/x86/kernel/e820.c	2018-12-23 19:20:34.587078783 +0800
@@ -403,7 +403,8 @@ static int __init __append_e820_table(st
 		/* Ignore the entry on 64-bit overflow: */
 		if (start > end && likely(size))
 			return -1;
-
+		if (type == E820_TYPE_PMEM)
+			type = E820_TYPE_RAM;
 		e820__range_add(start, size, type);
 
 		entry++;

Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C168C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 134F1218FF
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 134F1218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF8B48E0009; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5DF48E0003; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4A338E0009; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0C08E0006
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s22so15223477pgv.8
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=bLqbS/PT6+OZn4Cd5ognINxOjsGpaTLmfW4Gzyha0A4=;
        b=NM5AqxtgvI0sPCSC7eCYsY2rHc6pXdxWCyARWdzUQirD+yebcLW+wUhQDtOdqfI+1l
         QRx77MsjU6X/g1cebkC1cioPra6Zr/C11YTHD9Krn/ObbslnJ9reXtzkSNdvPXQnpd//
         Ddp3forWtX1Rsahl/pdzW7b3FFKpCjPzd9jPCSApWAFTq3ycOY3AySkqh6rjoSnOcn7J
         4OhczEjTBR3iRDNTJ4lZfSoeqDYO4pD5+LQo4hen2KBR4EHrTa9GfR/Yty2X06nSdUlD
         VRBNe2vbkn/h70rH5kUozG5h3pVEpMb8yp6As4RJc7VtkLHUxugTFagHzHst2rW3gwB+
         XwpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWaxmL6qH5T4yaHndwjeIjlGS1Ik7CCdRLykf6ajQuGVFEobFsWz
	GnIfEf422rqBvTKYDaLc/9lCZd0Ulpm9fzM0qQ/e5AyiNHytjvkNJoEzgwXR1zOGTrF3ztUjcnD
	rCfpaw6D1r6mV4OYxbLys/CEB8ZQYjZiOqURnmZo26FYo8oHLVx4GwrNI5NMeC485MQ==
X-Received: by 2002:aa7:8286:: with SMTP id s6mr19849796pfm.63.1545831426820;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
X-Google-Smtp-Source: AFSGD/WQ4B60GhMAduoRZhcDq54lJ66ohrTTN6e0JuJ1HGfD+xHUlIohYnwBU82oQ1LCgC3W/drH
X-Received: by 2002:aa7:8286:: with SMTP id s6mr19849757pfm.63.1545831426118;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=YGjs0E7YKjQD8P1I9uTbUB0hD+3JfO4B+tij/eDcVeX+a4dQh448qANYJnrqUUAlka
         2mnthQw1RTMol3Pd6D8b6hBQlOKNsbBE4ZXkdT9VPuHlg9YI+pf0KxzfCVV4/z/pNgPA
         0nWOuU1B+EpNfxTnMnhhaOVWZavHtcy67PmYtqb6yrgts51SCsWrY68p0po5lRLGxudj
         3FvycUcfV45baAMzDRo5RCEEDGV8eull3F+EhZHGPu283iI/7Cimr50i9Eb4/TQ6KTAk
         Y5pJvDX6usx2yXGhLbNFdLpVuswCp/JvKeEreQDhciUGsySMdYhZ9pdS/j9eBkskRZRO
         Ekdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=bLqbS/PT6+OZn4Cd5ognINxOjsGpaTLmfW4Gzyha0A4=;
        b=pq8aQYkOMpFj9e10gitZIPllbb11Xfp9oinWxQhL+uMuH9acYiqN0N0gpdLnWy6BlD
         yTl6mOvlF2nVKl3V2TggL+Z03RNlMYcCulCuum++xjR4L64vuUhEQk4ynskLC8qn41y4
         sGph6iKVWv3Ai3NU7hP5pegyJ3StEOiWQJYm8wVEo5opV+qLnzK71VNyUfqiNqexggB+
         7vo3Mhs7CotOg53IQ+BYhmO3293YUMpzfCtcajBWwkVXTtLCCMhiAPLsZBAHp+//60AW
         SRnT9CXEujLvrsj9Puxk58k3MBS83vJqjN1txc50vPajD3uBFMzsBKPQotz3r8P36nW+
         O2tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="121185460"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Dec 2018 05:37:01 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005Nz-7S; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.164047705@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:48 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fan Du <fan.du@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 02/21] acpi/numa: memorize NUMA node type from SRAT table
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0002-acpi-Memorize-numa-node-type-from-SRAT-table.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131448.sajHp4IGYRDHkO2dWGiCnqE0EDBU0wGtYhomLWwD_U0@z>

From: Fan Du <fan.du@intel.com>

Mark NUMA node as DRAM or PMEM.

This could happen in boot up state (see the e820 pmem type
override patch), or on fly when bind devdax device with kmem
driver.

It depends on BIOS supplying PMEM NUMA proximity in SRAT table,
that's current production BIOS does.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/include/asm/numa.h |    2 ++
 arch/x86/mm/numa.c          |    2 ++
 drivers/acpi/numa.c         |    5 +++++
 3 files changed, 9 insertions(+)

--- linux.orig/arch/x86/include/asm/numa.h	2018-12-23 19:20:39.890947888 +0800
+++ linux/arch/x86/include/asm/numa.h	2018-12-23 19:20:39.890947888 +0800
@@ -30,6 +30,8 @@ extern int numa_off;
  */
 extern s16 __apicid_to_node[MAX_LOCAL_APIC];
 extern nodemask_t numa_nodes_parsed __initdata;
+extern nodemask_t numa_nodes_pmem;
+extern nodemask_t numa_nodes_dram;
 
 extern int __init numa_add_memblk(int nodeid, u64 start, u64 end);
 extern void __init numa_set_distance(int from, int to, int distance);
--- linux.orig/arch/x86/mm/numa.c	2018-12-23 19:20:39.890947888 +0800
+++ linux/arch/x86/mm/numa.c	2018-12-23 19:20:39.890947888 +0800
@@ -20,6 +20,8 @@
 
 int numa_off;
 nodemask_t numa_nodes_parsed __initdata;
+nodemask_t numa_nodes_pmem;
+nodemask_t numa_nodes_dram;
 
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
--- linux.orig/drivers/acpi/numa.c	2018-12-23 19:20:39.890947888 +0800
+++ linux/drivers/acpi/numa.c	2018-12-23 19:20:39.890947888 +0800
@@ -297,6 +297,11 @@ acpi_numa_memory_affinity_init(struct ac
 
 	node_set(node, numa_nodes_parsed);
 
+	if (ma->flags & ACPI_SRAT_MEM_NON_VOLATILE)
+		node_set(node, numa_nodes_pmem);
+	else
+		node_set(node, numa_nodes_dram);
+
 	pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s%s\n",
 		node, pxm,
 		(unsigned long long) start, (unsigned long long) end - 1,



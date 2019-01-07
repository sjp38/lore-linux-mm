Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5459D8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:09:40 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g12so199081pll.22
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:09:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u188si22794549pfb.232.2019.01.07.06.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 06:09:38 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x07E8xVJ102642
	for <linux-mm@kvack.org>; Mon, 7 Jan 2019 09:09:38 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pv6w4ms9s-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Jan 2019 09:09:38 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 7 Jan 2019 14:09:35 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [RFC][PATCH v2 10/21] mm: build separate zonelist for PMEM and DRAM node
In-Reply-To: <20190107095753.7feee5fxjja5lt75@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com> <20181226133351.644607371@intel.com> <87sgyc7n9a.fsf@linux.ibm.com> <20190107095753.7feee5fxjja5lt75@wfg-t540p.sh.intel.com>
Date: Mon, 07 Jan 2019 19:39:19 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87h8ekk19s.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

Fengguang Wu <fengguang.wu@intel.com> writes:

> On Tue, Jan 01, 2019 at 02:44:41PM +0530, Aneesh Kumar K.V wrote:
>>Fengguang Wu <fengguang.wu@intel.com> writes:
>>
>>> From: Fan Du <fan.du@intel.com>
>>>
>>> When allocate page, DRAM and PMEM node should better not fall back to
>>> each other. This allows migration code to explicitly control which type
>>> of node to allocate pages from.
>>>
>>> With this patch, PMEM NUMA node can only be used in 2 ways:
>>> - migrate in and out
>>> - numactl
>>
>>Can we achieve this using nodemask? That way we don't tag nodes with
>>different properties such as DRAM/PMEM. We can then give the
>>flexibilility to the device init code to add the new memory nodes to
>>the right nodemask
>
> Aneesh, in patch 2 we did create nodemask numa_nodes_pmem and
> numa_nodes_dram. What's your supposed way of "using nodemask"?
>

IIUC the patch is to avoid allocation from PMEM nodes and the way you
achieve it is by checking if (is_node_pmem(n)). We already have
abstractness to avoid allocation from a node using node mask. I was
wondering whether we can do the equivalent of above using that.

ie, __next_zone_zonelist can do zref_in_nodemask(z,
default_exclude_nodemask)) and decide whether to use the specific zone
or not.

That way we don't add special code like 

+	PGDAT_DRAM,			/* Volatile DRAM memory node */
+	PGDAT_PMEM,			/* Persistent memory node */

The reason is that there could be other device memory that would want to
get excluded from that default allocation like you are doing for PMEM

-aneesh

Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6BE5C4CEC9
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 00:31:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7438221907
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 00:31:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7438221907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECCB56B0318; Wed, 18 Sep 2019 20:31:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7CFA6B0319; Wed, 18 Sep 2019 20:31:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6B9A6B031A; Wed, 18 Sep 2019 20:31:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0159.hostedemail.com [216.40.44.159])
	by kanga.kvack.org (Postfix) with ESMTP id B234B6B0318
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 20:31:11 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5755E180AD7C1
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 00:31:11 +0000 (UTC)
X-FDA: 75949790742.14.farm87_a4adbd4a4c3b
X-HE-Tag: farm87_a4adbd4a4c3b
X-Filterd-Recvd-Size: 3249
Received: from mga18.intel.com (mga18.intel.com [134.134.136.126])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 00:31:10 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Sep 2019 17:31:08 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,522,1559545200"; 
   d="scan'208";a="177883572"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga007.jf.intel.com with ESMTP; 18 Sep 2019 17:31:06 -0700
Date: Thu, 19 Sep 2019 08:30:47 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Yunfeng Ye <yeyunfeng@huawei.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>, rppt@linux.ibm.com,
	akpm@linux-foundation.org, osalvador@suse.de, mhocko@suse.co,
	dan.j.williams@intel.com, david@redhat.com, cai@lca.pw,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Support memblock alloc on the exact node for
 sparse_buffer_init()
Message-ID: <20190919003047.GA20697@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <af88d8ab-4088-e857-575f-9be57542e130@huawei.com>
 <20190918065140.GA5446@richard>
 <a0cbf140-7045-81bf-4686-6e742f97ceb8@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a0cbf140-7045-81bf-4686-6e742f97ceb8@huawei.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 18, 2019 at 03:08:41PM +0800, Yunfeng Ye wrote:
>
>
>On 2019/9/18 14:51, Wei Yang wrote:
>> On Wed, Sep 18, 2019 at 12:22:29PM +0800, Yunfeng Ye wrote:
>>> Currently, when memblock_find_in_range_node() fail on the exact node, it
>>> will use %NUMA_NO_NODE to find memblock from other nodes. At present,
>>> the work is good, but when the large memory is insufficient and the
>>> small memory is enough, we want to allocate the small memory of this
>>> node first, and do not need to allocate large memory from other nodes.
>>>
>>> In sparse_buffer_init(), it will prepare large chunks of memory for page
>>> structure. The page management structure requires a lot of memory, but
>>> if the node does not have enough memory, it can be converted to a small
>>> memory allocation without having to allocate it from other nodes.
>>>
>>> Add %MEMBLOCK_ALLOC_EXACT_NODE flag for this situation. Normally, the
>>> behavior is the same with %MEMBLOCK_ALLOC_ACCESSIBLE, only that it will
>>> not allocate from other nodes when a single node fails to allocate.
>>>
>>> If large contiguous block memory allocated fail in sparse_buffer_init(),
>>> it will allocates small block memmory section by section later.
>>>
>> 
>> Looks this changes current behavior even it fall back to section based
>> allocation.
>> 
>When fall back to section allocation, it still use %MEMBLOCK_ALLOC_ACCESSIBLE
>,I think the behavior is not change, Can you tell me the detail about the
>changes. thanks.
>

You pass MEMBLOCK_ALLOC_EXACT_NODE for the first round allocation, which
forbid it allocates from other node. This is different from current behavior.
Am I right?


Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37ECFC49ED7
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 07:14:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC43521907
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 07:14:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC43521907
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81F6E6B033E; Thu, 19 Sep 2019 03:14:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A9AE6B033F; Thu, 19 Sep 2019 03:14:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 670F86B0340; Thu, 19 Sep 2019 03:14:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0089.hostedemail.com [216.40.44.89])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6BB6B033E
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 03:14:48 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C3C3E180AD811
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 07:14:47 +0000 (UTC)
X-FDA: 75950807814.26.cork01_29b091556a643
X-HE-Tag: cork01_29b091556a643
X-Filterd-Recvd-Size: 6532
Received: from huawei.com (szxga06-in.huawei.com [45.249.212.32])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 07:14:46 +0000 (UTC)
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 550BE2E860EECD4E82C6;
	Thu, 19 Sep 2019 15:14:41 +0800 (CST)
Received: from [127.0.0.1] (10.177.251.225) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.439.0; Thu, 19 Sep 2019
 15:14:36 +0800
Subject: Re: [PATCH] mm: Support memblock alloc on the exact node for
 sparse_buffer_init()
To: Mike Rapoport <rppt@linux.ibm.com>
CC: <akpm@linux-foundation.org>, <osalvador@suse.de>, <mhocko@suse.co>,
	<dan.j.williams@intel.com>, <david@redhat.com>,
	<richardw.yang@linux.intel.com>, <cai@lca.pw>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
References: <af88d8ab-4088-e857-575f-9be57542e130@huawei.com>
 <20190919044753.GA20548@linux.ibm.com>
From: Yunfeng Ye <yeyunfeng@huawei.com>
Message-ID: <6d23d00c-f400-f486-dc6d-31b6f141d913@huawei.com>
Date: Thu, 19 Sep 2019 15:14:22 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190919044753.GA20548@linux.ibm.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.251.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/9/19 12:47, Mike Rapoport wrote:
> Hi,
> 
> On Wed, Sep 18, 2019 at 12:22:29PM +0800, Yunfeng Ye wrote:
>> Currently, when memblock_find_in_range_node() fail on the exact node, it
>> will use %NUMA_NO_NODE to find memblock from other nodes. At present,
>> the work is good, but when the large memory is insufficient and the
>> small memory is enough, we want to allocate the small memory of this
>> node first, and do not need to allocate large memory from other nodes.
>>
>> In sparse_buffer_init(), it will prepare large chunks of memory for page
>> structure. The page management structure requires a lot of memory, but
>> if the node does not have enough memory, it can be converted to a small
>> memory allocation without having to allocate it from other nodes.
>>
>> Add %MEMBLOCK_ALLOC_EXACT_NODE flag for this situation. Normally, the
>> behavior is the same with %MEMBLOCK_ALLOC_ACCESSIBLE, only that it will
>> not allocate from other nodes when a single node fails to allocate.
>>
>> If large contiguous block memory allocated fail in sparse_buffer_init(),
>> it will allocates small block memmory section by section later.
> 
> Did you see the sparse_buffer_init() actually falling back to allocate from a
> different node? If a node does not have enough memory to hold it's own
> memory map, filling only it with parts of the memory map will not make such
> node usable.
>  
Normally, it won't happen that sparse_buffer_init() falling back from a different
node, because page structure size is 64 bytes per 4KB of memory, no more than 2%
of total available memory. But in the special cases, for eaxmple, memory address
is isolated by BIOS when memory failure, split the total memory many pieces,
although we have enough memory, but no large contiguous block memory in one node.
sparse_buffer_init() needs large contiguous block memory to be alloc in one time,

Eg, the size of memory is 1TB, sparse_buffer_init() need 1TB * 64/4096 = 16GB, but
we have 100 blocks memory which every block only have 10GB, although total memory
have almost 100*10GB=1TB, but no contiguous 16GB block.

Before commit 2a3cb8baef71 ("mm/sparse: delete old sparse_init and enable new one"),
we have %CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER config to meeting this situation,
after that, it fall back to allocate memory from other nodes, so have the performance
impact by remote numa access.

commit 85c77f791390 ("mm/sparse: add new sparse_init_nid() and sparse_init()") wrote
that:
    "
    sparse_init_nid(), which only
    operates within one memory node, and thus allocates memory either in large
    contiguous block or allocates section by section
    "
it means that allocates section by section is a normal choice too, so I think add
%MEMBLOCK_ALLOC_EXACT_NODE is also a choice for this situation. Most cases,
sparse_buffer_init() works good and not allocated from other nodes at present.

thanks.
Yunfeng Ye

>> Signed-off-by: Yunfeng Ye <yeyunfeng@huawei.com>
>> ---
>>  include/linux/memblock.h | 1 +
>>  mm/memblock.c            | 3 ++-
>>  mm/sparse.c              | 2 +-
>>  3 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>> index f491690..9a81d9c 100644
>> --- a/include/linux/memblock.h
>> +++ b/include/linux/memblock.h
>> @@ -339,6 +339,7 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
>>  #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
>>  #define MEMBLOCK_ALLOC_ACCESSIBLE	0
>>  #define MEMBLOCK_ALLOC_KASAN		1
>> +#define MEMBLOCK_ALLOC_EXACT_NODE	2
>>
>>  /* We are using top down, so it is safe to use 0 here */
>>  #define MEMBLOCK_LOW_LIMIT 0
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 7d4f61a..dbd52c3c 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -277,6 +277,7 @@ static phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
>>
>>  	/* pump up @end */
>>  	if (end == MEMBLOCK_ALLOC_ACCESSIBLE ||
>> +	    end == MEMBLOCK_ALLOC_EXACT_NODE ||
>>  	    end == MEMBLOCK_ALLOC_KASAN)
>>  		end = memblock.current_limit;
>>
>> @@ -1365,7 +1366,7 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
>>  	if (found && !memblock_reserve(found, size))
>>  		goto done;
>>
>> -	if (nid != NUMA_NO_NODE) {
>> +	if (end != MEMBLOCK_ALLOC_EXACT_NODE && nid != NUMA_NO_NODE) {
>>  		found = memblock_find_in_range_node(size, align, start,
>>  						    end, NUMA_NO_NODE,
>>  						    flags);
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 72f010d..828db46 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -477,7 +477,7 @@ static void __init sparse_buffer_init(unsigned long size, int nid)
>>  	sparsemap_buf =
>>  		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
>>  						addr,
>> -						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
>> +						MEMBLOCK_ALLOC_EXACT_NODE, nid);
>>  	sparsemap_buf_end = sparsemap_buf + size;
>>  }
>>
>> -- 
>> 2.7.4.huawei.3
>>
>>
> 



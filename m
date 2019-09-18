Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7BAFC4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 06:52:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AC7121906
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 06:52:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AC7121906
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8C716B027B; Wed, 18 Sep 2019 02:52:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3D906B027C; Wed, 18 Sep 2019 02:52:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D039B6B027D; Wed, 18 Sep 2019 02:52:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0251.hostedemail.com [216.40.44.251])
	by kanga.kvack.org (Postfix) with ESMTP id A92306B027B
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 02:52:06 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1C3A268B9
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 06:52:06 +0000 (UTC)
X-FDA: 75947121852.23.beast41_4c7737dd3f453
X-HE-Tag: beast41_4c7737dd3f453
X-Filterd-Recvd-Size: 4648
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 06:52:05 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Sep 2019 23:52:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,519,1559545200"; 
   d="scan'208";a="216842807"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga002.fm.intel.com with ESMTP; 17 Sep 2019 23:51:59 -0700
Date: Wed, 18 Sep 2019 14:51:40 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Yunfeng Ye <yeyunfeng@huawei.com>
Cc: rppt@linux.ibm.com, akpm@linux-foundation.org, osalvador@suse.de,
	mhocko@suse.co, dan.j.williams@intel.com, david@redhat.com,
	richardw.yang@linux.intel.com, cai@lca.pw, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Support memblock alloc on the exact node for
 sparse_buffer_init()
Message-ID: <20190918065140.GA5446@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <af88d8ab-4088-e857-575f-9be57542e130@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af88d8ab-4088-e857-575f-9be57542e130@huawei.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 18, 2019 at 12:22:29PM +0800, Yunfeng Ye wrote:
>Currently, when memblock_find_in_range_node() fail on the exact node, it
>will use %NUMA_NO_NODE to find memblock from other nodes. At present,
>the work is good, but when the large memory is insufficient and the
>small memory is enough, we want to allocate the small memory of this
>node first, and do not need to allocate large memory from other nodes.
>
>In sparse_buffer_init(), it will prepare large chunks of memory for page
>structure. The page management structure requires a lot of memory, but
>if the node does not have enough memory, it can be converted to a small
>memory allocation without having to allocate it from other nodes.
>
>Add %MEMBLOCK_ALLOC_EXACT_NODE flag for this situation. Normally, the
>behavior is the same with %MEMBLOCK_ALLOC_ACCESSIBLE, only that it will
>not allocate from other nodes when a single node fails to allocate.
>
>If large contiguous block memory allocated fail in sparse_buffer_init(),
>it will allocates small block memmory section by section later.
>

Looks this changes current behavior even it fall back to section based
allocation.

>Signed-off-by: Yunfeng Ye <yeyunfeng@huawei.com>
>---
> include/linux/memblock.h | 1 +
> mm/memblock.c            | 3 ++-
> mm/sparse.c              | 2 +-
> 3 files changed, 4 insertions(+), 2 deletions(-)
>
>diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>index f491690..9a81d9c 100644
>--- a/include/linux/memblock.h
>+++ b/include/linux/memblock.h
>@@ -339,6 +339,7 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
> #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
> #define MEMBLOCK_ALLOC_ACCESSIBLE	0
> #define MEMBLOCK_ALLOC_KASAN		1
>+#define MEMBLOCK_ALLOC_EXACT_NODE	2
>
> /* We are using top down, so it is safe to use 0 here */
> #define MEMBLOCK_LOW_LIMIT 0
>diff --git a/mm/memblock.c b/mm/memblock.c
>index 7d4f61a..dbd52c3c 100644
>--- a/mm/memblock.c
>+++ b/mm/memblock.c
>@@ -277,6 +277,7 @@ static phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
>
> 	/* pump up @end */
> 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE ||
>+	    end == MEMBLOCK_ALLOC_EXACT_NODE ||
> 	    end == MEMBLOCK_ALLOC_KASAN)
> 		end = memblock.current_limit;
>
>@@ -1365,7 +1366,7 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
> 	if (found && !memblock_reserve(found, size))
> 		goto done;
>
>-	if (nid != NUMA_NO_NODE) {
>+	if (end != MEMBLOCK_ALLOC_EXACT_NODE && nid != NUMA_NO_NODE) {
> 		found = memblock_find_in_range_node(size, align, start,
> 						    end, NUMA_NO_NODE,
> 						    flags);
>diff --git a/mm/sparse.c b/mm/sparse.c
>index 72f010d..828db46 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -477,7 +477,7 @@ static void __init sparse_buffer_init(unsigned long size, int nid)
> 	sparsemap_buf =
> 		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
> 						addr,
>-						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
>+						MEMBLOCK_ALLOC_EXACT_NODE, nid);
> 	sparsemap_buf_end = sparsemap_buf + size;
> }
>
>-- 
>2.7.4.huawei.3
>

-- 
Wei Yang
Help you, Help me


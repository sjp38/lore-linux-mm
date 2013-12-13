Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id C7AB26B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 16:29:16 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so1958331yhl.20
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:29:16 -0800 (PST)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id o28si3254425yhd.191.2013.12.13.13.29.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 13:29:15 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id z20so1977690yhz.8
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:29:15 -0800 (PST)
Date: Fri, 13 Dec 2013 16:29:12 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 07/23] mm/memblock: switch to use NUMA_NO_NODE instead
 of MAX_NUMNODES
Message-ID: <20131213212912.GL27070@htj.dyndns.org>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
 <1386625856-12942-8-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386625856-12942-8-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 09, 2013 at 04:50:40PM -0500, Santosh Shilimkar wrote:
> +	if (nid == MAX_NUMNODES)
> +		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
> +			     __func__);

Why not just use WARN_ONCE()?  We'd want to know who the caller is
anyway.  Also, wouldn't something like the following simpler?

	if (WARN_ONCE(nid == MAX_NUMNODES, blah blah))
		nid = NUMA_NO_NODE;

> @@ -768,6 +773,11 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
>  	struct memblock_type *rsv = &memblock.reserved;
>  	int mi = *idx & 0xffffffff;
>  	int ri = *idx >> 32;
> +	bool check_node = (nid != NUMA_NO_NODE) && (nid != MAX_NUMNODES);
> +
> +	if (nid == MAX_NUMNODES)
> +		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
> +			     __func__);

Ditto.

Provided the patch is tested on an actual NUMA setup.

Reviwed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

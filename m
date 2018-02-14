Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E79196B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 00:08:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i8so1356690pgv.23
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 21:08:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor140420pgf.286.2018.02.13.21.08.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Feb 2018 21:08:48 -0800 (PST)
Date: Wed, 14 Feb 2018 14:08:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 1/1] mm: initialize pages on demand during boot
Message-ID: <20180214050843.GA2811@jagdpanzerIV>
References: <20180209192216.20509-1-pasha.tatashin@oracle.com>
 <20180209192216.20509-2-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180209192216.20509-2-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (02/09/18 14:22), Pavel Tatashin wrote:
[..]
> +/*
> + * If this zone has deferred pages, try to grow it by initializing enough
> + * deferred pages to satisfy the allocation specified by order, rounded up to
> + * the nearest PAGES_PER_SECTION boundary.  So we're adding memory in increments
> + * of SECTION_SIZE bytes by initializing struct pages in increments of
> + * PAGES_PER_SECTION * sizeof(struct page) bytes.
> + *
> + * Return true when zone was grown by at least number of pages specified by
> + * order. Otherwise return false.
> + *
> + * Note: We use noinline because this function is needed only during boot, and
> + * it is called from a __ref function _deferred_grow_zone. This way we are
> + * making sure that it is not inlined into permanent text section.
> + */
> +static noinline bool __init
> +deferred_grow_zone(struct zone *zone, unsigned int order)
> +{
> +	int zid = zone_idx(zone);
> +	int nid = zone->node;

		^^^^^^^^^

Should be CONFIG_NUMA dependent

struct zone {
...
#ifdef CONFIG_NUMA
	int node;
#endif
...

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

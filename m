Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 427186B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 18:12:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i124so41786wmf.1
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 15:12:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s1si6541332wrf.301.2017.10.16.15.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 15:12:55 -0700 (PDT)
Date: Mon, 16 Oct 2017 15:12:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, compaction: properly initialize alloc_flags in
 compact_control
Message-Id: <20171016151252.ee4cc68f7e022bab447478d4@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1710161503020.102726@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1710161503020.102726@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 16 Oct 2017 15:03:37 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> 
> compaction_suitable() requires a useful cc->alloc_flags, otherwise the
> results of compact_zone() can be indeterminate.  Kcompactd currently
> checks compaction_suitable() itself with alloc_flags == 0, but passes an
> uninitialized value from the stack to compact_zone(), which does its own
> check.
> 
> The same is true for compact_node() when explicitly triggering full node
> compaction.
> 
> Properly initialize cc.alloc_flags on the stack.
> 

The compiler will zero any not-explicitly-initialized fields in these
initializers.

> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1792,9 +1792,9 @@ static void compact_node(int nid)
>  {
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  	int zoneid;
> -	struct zone *zone;
>  	struct compact_control cc = {
>  		.order = -1,
> +		.alloc_flags = 0,
>  		.total_migrate_scanned = 0,
>  		.total_free_scanned = 0,
>  		.mode = MIGRATE_SYNC,
> @@ -1805,6 +1805,7 @@ static void compact_node(int nid)
>  
>  
>  	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
> +		struct zone *zone;
>  
>  		zone = &pgdat->node_zones[zoneid];
>  		if (!populated_zone(zone))
> @@ -1923,6 +1924,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  	struct zone *zone;
>  	struct compact_control cc = {
>  		.order = pgdat->kcompactd_max_order,
> +		.alloc_flags = 0,
>  		.total_migrate_scanned = 0,
>  		.total_free_scanned = 0,
>  		.classzone_idx = pgdat->kcompactd_classzone_idx,
> @@ -1945,8 +1947,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  		if (compaction_deferred(zone, cc.order))
>  			continue;
>  
> -		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
> -							COMPACT_CONTINUE)
> +		if (compaction_suitable(zone, cc.order, cc.alloc_flags,
> +					zoneid) != COMPACT_CONTINUE)
>  			continue;

So afaict the above hunk is the only functional change here.  It will
propagate any of compact_zone()'s modifications to cc->alloc_flags into
succeeding calls to compaction_suitable().  I suspect this is a
no-op (didn't look), and it wasn't changelogged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF0A6B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 03:49:05 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j28so5980217wrd.17
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 00:49:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 189si1143461wmp.128.2018.02.20.00.49.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Feb 2018 00:49:03 -0800 (PST)
Date: Tue, 20 Feb 2018 09:49:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] slab: fix /proc/slabinfo alignment
Message-ID: <20180220084902.GT21134@dhcp22.suse.cz>
References: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ? ? <mordorw@hotmail.com>
Cc: "cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue 20-02-18 02:29:13, ? ? wrote:
> Signed-off-by: mordor <mordorw@hotmail.com>
> /proc/slabinfo is not aligned, it is difficult to read, so correct it

I do not see this as an improvement, to be honest. Moreover you risk a
regression when some dumb parsing tool relies on the current layout
format. I find the later rather unlikely but there would have to be a
very good reason to take the risk.

> ---
>  mm/slab_common.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 10f127b..7111549 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1232,7 +1232,6 @@ void cache_random_seq_destroy(struct kmem_cache *cachep)
>  #else
>  #define SLABINFO_RIGHTS S_IRUSR
>  #endif
> -
>  static void print_slabinfo_header(struct seq_file *m)
>  {
>  	/*
> @@ -1244,7 +1243,7 @@ static void print_slabinfo_header(struct seq_file *m)
>  #else
>  	seq_puts(m, "slabinfo - version: 2.1\n");
>  #endif
> -	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>");
> +	seq_puts(m, "# name                         <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>");
>  	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
>  	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
>  #ifdef CONFIG_DEBUG_SLAB
> @@ -1291,6 +1290,7 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
>  	}
>  }
>  
> +
>  static void cache_show(struct kmem_cache *s, struct seq_file *m)
>  {
>  	struct slabinfo sinfo;
> @@ -1300,13 +1300,13 @@ static void cache_show(struct kmem_cache *s, struct seq_file *m)
>  
>  	memcg_accumulate_slabinfo(s, &sinfo);
>  
> -	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
> +	seq_printf(m, "%-30s %13lu %10lu %9u %12u %14d",
>  		   cache_name(s), sinfo.active_objs, sinfo.num_objs, s->size,
>  		   sinfo.objects_per_slab, (1 << sinfo.cache_order));
>  
> -	seq_printf(m, " : tunables %4u %4u %4u",
> +	seq_printf(m, " : tunables %7u %12u %14u",
>  		   sinfo.limit, sinfo.batchcount, sinfo.shared);
> -	seq_printf(m, " : slabdata %6lu %6lu %6lu",
> +	seq_printf(m, " : slabdata %14lu %11lu %13lu",
>  		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail);
>  	slabinfo_show_stats(m, s);
>  	seq_putc(m, '\n');
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

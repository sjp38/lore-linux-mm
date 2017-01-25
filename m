Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2F376B026A
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 21:02:22 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id t56so174516862qte.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 18:02:22 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id n132si13281381qka.227.2017.01.24.18.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 18:02:22 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id l7so29191629qtd.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 18:02:22 -0800 (PST)
Date: Tue, 24 Jan 2017 21:02:20 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170125020220.GA2727@mtj.duckdns.org>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
 <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
 <20170123170329.GA7820@htj.duckdns.org>
 <20170123200412.mkesardc4mckk6df@techsingularity.net>
 <20170123205501.GA25944@htj.duckdns.org>
 <20170123230429.os7ssxab4mazrkrb@techsingularity.net>
 <20170124160722.GC12281@htj.duckdns.org>
 <20170124235457.x7ssjun5ht2ycyac@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124235457.x7ssjun5ht2ycyac@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Petr Mladek <pmladek@suse.cz>

Hello,

On Tue, Jan 24, 2017 at 11:54:57PM +0000, Mel Gorman wrote:
> @@ -2402,24 +2415,16 @@ void drain_all_pages(struct zone *zone)
>  			cpumask_clear_cpu(cpu, &cpus_with_pcps);
>  	}
>  
> +	for_each_cpu(cpu, &cpus_with_pcps) {
> +		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
> +		INIT_WORK(work, drain_local_pages_wq);
> +		schedule_work_on(cpu, work);
>  	}
> +	for_each_cpu(cpu, &cpus_with_pcps)
> +		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
> +
>  	put_online_cpus();
> +	mutex_unlock(&pcpu_drain_mutex);

Looks good to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

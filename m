Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5016B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 03:31:01 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so34355584wmi.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 00:31:01 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id l4si15340387wmi.168.2017.01.25.00.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 00:30:59 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 765C31C1AB3
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:30:59 +0000 (GMT)
Date: Wed, 25 Jan 2017 08:30:58 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170125083058.g2f4i5ej2ayljcmb@techsingularity.net>
References: <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
 <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
 <20170123170329.GA7820@htj.duckdns.org>
 <20170123200412.mkesardc4mckk6df@techsingularity.net>
 <20170123205501.GA25944@htj.duckdns.org>
 <20170123230429.os7ssxab4mazrkrb@techsingularity.net>
 <20170124160722.GC12281@htj.duckdns.org>
 <20170124235457.x7ssjun5ht2ycyac@techsingularity.net>
 <20170125020220.GA2727@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170125020220.GA2727@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Petr Mladek <pmladek@suse.cz>

On Tue, Jan 24, 2017 at 09:02:20PM -0500, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jan 24, 2017 at 11:54:57PM +0000, Mel Gorman wrote:
> > @@ -2402,24 +2415,16 @@ void drain_all_pages(struct zone *zone)
> >  			cpumask_clear_cpu(cpu, &cpus_with_pcps);
> >  	}
> >  
> > +	for_each_cpu(cpu, &cpus_with_pcps) {
> > +		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
> > +		INIT_WORK(work, drain_local_pages_wq);
> > +		schedule_work_on(cpu, work);
> >  	}
> > +	for_each_cpu(cpu, &cpus_with_pcps)
> > +		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
> > +
> >  	put_online_cpus();
> > +	mutex_unlock(&pcpu_drain_mutex);
> 
> Looks good to me.
> 

Thanks Tejun.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E77A56B0260
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 14:21:45 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 14so322957875pgg.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 11:21:45 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id k20si2179110pfa.244.2017.01.26.11.21.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 11:21:45 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id 194so23042918pgd.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 11:21:45 -0800 (PST)
Date: Thu, 26 Jan 2017 14:21:42 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm, page_alloc: Use static global work_struct for
 draining per-cpu pages
Message-ID: <20170126192142.GA32152@htj.duckdns.org>
References: <20170125083038.rzb5f43nptmk7aed@techsingularity.net>
 <20170125160802.67172878e6692e45fa035f37@linux-foundation.org>
 <20170126104732.meri27v5lf3or22j@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126104732.meri27v5lf3or22j@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Hello,

On Thu, Jan 26, 2017 at 10:47:32AM +0000, Mel Gorman wrote:
> On Wed, Jan 25, 2017 at 04:08:02PM -0800, Andrew Morton wrote:
> > > +	for_each_cpu(cpu, &cpus_with_pcps) {
> > > +		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
> > > +		INIT_WORK(work, drain_local_pages_wq);
> > 
> > It's strange to repeatedly run INIT_WORK() in this fashion. 
> > Overwriting an atomic_t which should already be zero, initializing a
> > list_head which should already be in the initialized state...
> > 
> > Can we instead do this a single time in init code?
> > 
> 
> INIT_WORK does different things depending on whether LOCKDEP is enabled or
> not and also whether object debugging is enabled. I'd worry that it's not
> functionally equivalent or some future change would break the assumptions
> about what INIT_WORK does internally. The init cost is there, but it's
> insignicant in comparison to the whole workqueue operation or the old
> cost of sending IPIs for that matter.

Both initing once or per each invocation are perfectly valid and
guaranteed to work.  idk, I don't have a strong opinion hereag.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

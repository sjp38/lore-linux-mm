Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92B696B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 12:52:20 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u12so33825650qku.16
        for <linux-mm@kvack.org>; Tue, 02 May 2017 09:52:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r5si9738067qkr.284.2017.05.02.09.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 09:52:19 -0700 (PDT)
Date: Tue, 2 May 2017 13:52:00 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170502165159.GA5457@amt.cnet>
References: <20170425135717.375295031@redhat.com>
 <20170425135846.203663532@redhat.com>
 <20170502102836.4a4d34ba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170502102836.4a4d34ba@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cl@linux.com, cmetcalf@mellanox.com

On Tue, May 02, 2017 at 10:28:36AM -0400, Luiz Capitulino wrote:
> On Tue, 25 Apr 2017 10:57:19 -0300
> Marcelo Tosatti <mtosatti@redhat.com> wrote:
> 
> > The per-CPU vmstat worker is a problem on -RT workloads (because
> > ideally the CPU is entirely reserved for the -RT app, without
> > interference). The worker transfers accumulated per-CPU 
> > vmstat counters to global counters.
> 
> This is a problem for non-RT too. Any task pinned to an isolated
> CPU that doesn't want to be ever interrupted will be interrupted
> by the vmstat kworker.
> 
> > To resolve the problem, create two tunables:
> > 
> > * Userspace configurable per-CPU vmstat threshold: by default the 
> > VM code calculates the size of the per-CPU vmstat arrays. This 
> > tunable allows userspace to configure the values.
> > 
> > * Userspace configurable per-CPU vmstat worker: allow disabling
> > the per-CPU vmstat worker.
>
> I have several questions about the tunables:
> 
>  - What does the vmstat_threshold value mean? What are the implications
>    of changing this value? What's the difference in choosing 1, 2, 3
>    or 500?

Its the maximum value for a vmstat statistics counter to hold. After
that value, the statistics are transferred to the global counter:

void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
                                long delta)
{
        struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
        s8 __percpu *p = pcp->vm_node_stat_diff + item;
        long x;
        long t;

        x = delta + __this_cpu_read(*p);

        t = __this_cpu_read(pcp->stat_threshold);

        if (unlikely(x > t || x < -t)) {
                node_page_state_add(x, pgdat, item);
                x = 0;
        }
        __this_cpu_write(*p, x);
}
EXPORT_SYMBOL(__mod_node_page_state);

BTW, there is a bug there, should change that to:

        if (unlikely(x >= t || x <= -t)) {

Increasing the threshold value does two things:
	1) It decreases the number of inter-processor accesses.
	2) It increases how much the global counters stay out of
	   sync relative to actual current values.

>  - If the purpose of having vmstat_threshold is to allow disabling
>    the vmstat kworker, why can't the kernel pick a value automatically?

Because it might be acceptable for the user to accept a small 
out of syncedness of the global counters in favour of performance
(one would have to analyze the situation).

Setting vmstat_threshold == 1 means the global counter is always
in sync with the page counter state of the pCPU.

>  - What are the implications of disabling the vmstat kworker? Will vm
>    stats still be collected someway or will it be completely off for
>    the CPU?

It will not be necessary to collect vmstats because at every modification
of the vm statistics, pCPUs with vmstat_threshold=1 transfer their 
values to the global counters (that is, there is no queueing of statistics
locally to improve performance).

> Also, shouldn't this patch be split into two?

First add one sysfs file, then add another sysfs file, you mean?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

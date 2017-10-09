Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BFD616B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 03:55:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i124so23518765wmf.7
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 00:55:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b58si2286502wra.248.2017.10.09.00.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 00:55:51 -0700 (PDT)
Date: Mon, 9 Oct 2017 09:55:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
Message-ID: <20171009075549.pzohdnerillwuhqo@dhcp22.suse.cz>
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
 <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
 <221a1e93-ee33-d598-67de-d6071f192040@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <221a1e93-ee33-d598-67de-d6071f192040@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon 09-10-17 14:34:11, kemi wrote:
> 
> 
> On 2017a1'10ae??03ae?JPY 17:23, Michal Hocko wrote:
> > On Thu 28-09-17 14:11:41, Kemi Wang wrote:
> >> This is the second step which introduces a tunable interface that allow
> >> numa stats configurable for optimizing zone_statistics(), as suggested by
> >> Dave Hansen and Ying Huang.
> >>
> >> =========================================================================
> >> When page allocation performance becomes a bottleneck and you can tolerate
> >> some possible tool breakage and decreased numa counter precision, you can
> >> do:
> >> 	echo [C|c]oarse > /proc/sys/vm/numa_stats_mode
> >> In this case, numa counter update is ignored. We can see about
> >> *4.8%*(185->176) drop of cpu cycles per single page allocation and reclaim
> >> on Jesper's page_bench01 (single thread) and *8.1%*(343->315) drop of cpu
> >> cycles per single page allocation and reclaim on Jesper's page_bench03 (88
> >> threads) running on a 2-Socket Broadwell-based server (88 threads, 126G
> >> memory).
> >>
> >> Benchmark link provided by Jesper D Brouer(increase loop times to
> >> 10000000):
> >> https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/
> >> bench
> >>
> >> =========================================================================
> >> When page allocation performance is not a bottleneck and you want all
> >> tooling to work, you can do:
> >> 	echo [S|s]trict > /proc/sys/vm/numa_stats_mode
> >>
> >> =========================================================================
> >> We recommend automatic detection of numa statistics by system, this is also
> >> system default configuration, you can do:
> >> 	echo [A|a]uto > /proc/sys/vm/numa_stats_mode
> >> In this case, numa counter update is skipped unless it has been read by
> >> users at least once, e.g. cat /proc/zoneinfo.
> > 
> > I am still not convinced the auto mode is worth all the additional code
> > and a safe default to use. The whole thing could have been 0/1 with a
> > simpler parsing and less code to catch readers.
> > 
> 
> I understood your concern. 
> Well, we may get rid of auto mode if there is some obvious disadvantage
> here. Now, I tend to keep it because most people may not touch this interface,
> and auto mode is helpful in such case.

But you cannot guarantee it won't break any existing users, can you?
Besides I do not remember anybody complaining about the performance
impact of these counters other than very specialized workloads which are
going to disable the accounting altogether. So I simply fail to see a
reason to add more code with a questionable semantic (see below on
partial reads).

> > E.g. why do we have to do static_branch_enable on any read or even
> > vmstat_stop? Wouldn't open be sufficient?
> > 
> 
> NUMA stats is used in four files:
> /proc/zoneinfo
> /proc/vmstat
> /sys/devices/system/node/node*/numastat
> /sys/devices/system/node/node*/vmstat
> In auto mode, each *read* will trigger the update of NUMA counter. 
> So, we should make sure the target branch is jumped to the branch 
> for NUMA counter update once the file is read from user space.
> the intension of static_branch_enable in vmstat_stop(in the call site 
> of file->file_ops.read) is for reading /proc/vmstat in case.  
> 
> I guess the *open* means file->file_op.open here, right?
> Do you suggest to move static_branch_enable to file->file_op.open? Thanks.

I haven't checked closely but what happens (or should happen) when you
do a partial read? Should you get an inconsistent results? Or is this
impossible?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

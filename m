Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 069C86B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 05:07:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d66so9319405wmi.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:07:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si5812558wrk.214.2017.03.16.02.07.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 02:07:33 -0700 (PDT)
Date: Thu, 16 Mar 2017 10:07:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170316090732.GF30501@dhcp22.suse.cz>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
 <1489613914.2733.96.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1489613914.2733.96.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed 15-03-17 14:38:34, Tim Chen wrote:
> On Wed, 2017-03-15 at 17:28 +0100, Michal Hocko wrote:
> > On Wed 15-03-17 23:44:07, Aaron Lu wrote:
> > > 
> > > On Wed, Mar 15, 2017 at 03:18:14PM +0100, Michal Hocko wrote:
> > > > 
> > > > On Wed 15-03-17 16:59:59, Aaron Lu wrote:
> > > > [...]
> > > > > 
> > > > > The proposed parallel free did this: if the process has many pages to be
> > > > > freed, accumulate them in these struct mmu_gather_batch(es) one after
> > > > > another till 256K pages are accumulated. Then take this singly linked
> > > > > list starting from tlb->local.next off struct mmu_gather *tlb and free
> > > > > them in a worker thread. The main thread can return to continue zap
> > > > > other pages(after freeing pages pointed by tlb->local.pages).
> > > > I didn't have a look at the implementation yet but there are two
> > > > concerns that raise up from this description. Firstly how are we going
> > > > to tune the number of workers. I assume there will be some upper bound
> > > > (one of the patch subject mentions debugfs for tuning) and secondly
> > > The workers are put in a dedicated workqueue which is introduced in
> > > patch 3/5 and the number of workers can be tuned through that workqueue's
> > > sysfs interface: max_active.
> > I suspect we cannot expect users to tune this. What do you consider a
> > reasonable default?
> 
> From Aaron's data, it seems like 4 is a reasonable value for max_active:
> 
> max_active:   time
> 1             8.9s   +-0.5%
> 2             5.65s  +-5.5%
> 4             4.84s  +-0.16%
> 8             4.77s  +-0.97%
> 16            4.85s  +-0.77%
> 32            6.21s  +-0.46%

OK, but this will depend on the HW, right? Also now that I am looking at
those numbers more closely. This was about unmapping 320GB area and
using 4 times more CPUs you managed to half the run time. Is this really
worth it? Sure if those CPUs were idle then this is a clear win but if
the system is moderately busy then it doesn't look like a clear win to
me.

> > Moreover, and this is a more generic question, is this functionality
> > useful in general purpose workloads? 
> 
> If we are running consecutive batch jobs, this optimization
> should help start the next job sooner.

Is this sufficient justification to add a potentially hard to tune
optimization that can influence other workloads on the machine?

> > After all the amount of the work to
> > be done is the same we just risk more lock contentions, unexpected CPU
> > usage etc. Which workloads will benefit from having exit path faster?
> >  
> > > 
> > > > 
> > > > if we offload the page freeing to the worker then the original context
> > > > can consume much more cpu cycles than it was configured via cpu
> > I was not precise here. I meant to say more cpu cycles per time unit
> > that it was allowed.
> > 
> > > 
> > > > 
> > > > controller. How are we going to handle that? Or is this considered
> > > > acceptable?
> > > I'll need to think about and take a look at this subject(not familiar
> > > with cpu controller).
> > the main problem is that kworkers will not belong to the same cpu group
> > and so they will not be throttled properly.
> 
> You do have a point that this page freeing activities should strive to
> affect other threads not in the same cgroup minimally.
> 
> On the other hand, we also don't do this throttling of kworkers 
> today (e.g. pdflush) according to the cgroup it is doing work for.

Yes, I am not saying this a new problem. I just wanted to point out that
this is something to consider here. I believe this should be fixable.
Worker can attach to the same cgroup the initiator had for example
(assuming the cgroup core allows that which is something would have to
be checked).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

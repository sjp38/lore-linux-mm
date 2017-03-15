Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 042876B038A
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 17:38:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t143so55175444pgb.5
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 14:38:36 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id l19si2259798pfa.177.2017.03.15.14.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 14:38:36 -0700 (PDT)
Message-ID: <1489613914.2733.96.camel@linux.intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Wed, 15 Mar 2017 14:38:34 -0700
In-Reply-To: <20170315162843.GA27197@dhcp22.suse.cz>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
	 <20170315141813.GB32626@dhcp22.suse.cz>
	 <20170315154406.GF2442@aaronlu.sh.intel.com>
	 <20170315162843.GA27197@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed, 2017-03-15 at 17:28 +0100, Michal Hocko wrote:
> On Wed 15-03-17 23:44:07, Aaron Lu wrote:
> > 
> > On Wed, Mar 15, 2017 at 03:18:14PM +0100, Michal Hocko wrote:
> > > 
> > > On Wed 15-03-17 16:59:59, Aaron Lu wrote:
> > > [...]
> > > > 
> > > > The proposed parallel free did this: if the process has many pages to be
> > > > freed, accumulate them in these struct mmu_gather_batch(es) one after
> > > > another till 256K pages are accumulated. Then take this singly linked
> > > > list starting from tlb->local.next off struct mmu_gather *tlb and free
> > > > them in a worker thread. The main thread can return to continue zap
> > > > other pages(after freeing pages pointed by tlb->local.pages).
> > > I didn't have a look at the implementation yet but there are two
> > > concerns that raise up from this description. Firstly how are we going
> > > to tune the number of workers. I assume there will be some upper bound
> > > (one of the patch subject mentions debugfs for tuning) and secondly
> > The workers are put in a dedicated workqueue which is introduced in
> > patch 3/5 and the number of workers can be tuned through that workqueue's
> > sysfs interface: max_active.
> I suspect we cannot expect users to tune this. What do you consider a
> reasonable default?

>From Aaron's data, it seems like 4 is a reasonable value for max_active:

max_active:A A A time
1A A A A A A A A A A A A A 8.9sA A A A+-0.5%
2A A A A A A A A A A A A A 5.65sA A A+-5.5%
4A A A A A A A A A A A A A 4.84sA A A+-0.16%
8A A A A A A A A A A A A A 4.77sA A A+-0.97%
16A A A A A A A A A A A A 4.85sA A A+-0.77%
32A A A A A A A A A A A A 6.21sA A A+-0.46%


> Moreover, and this is a more generic question, is this functionality
> useful in general purpose workloads? 

If we are running consecutive batch jobs, this optimization
should help start the next job sooner.

> After all the amount of the work to
> be done is the same we just risk more lock contentions, unexpected CPU
> usage etc. Which workloads will benefit from having exit path faster?
> A 
> > 
> > > 
> > > if we offload the page freeing to the worker then the original context
> > > can consume much more cpu cycles than it was configured via cpu
> I was not precise here. I meant to say more cpu cycles per time unit
> that it was allowed.
> 
> > 
> > > 
> > > controller. How are we going to handle that? Or is this considered
> > > acceptable?
> > I'll need to think about and take a look at this subject(not familiar
> > with cpu controller).
> the main problem is that kworkers will not belong to the same cpu group
> and so they will not be throttled properly.

You do have a point that this page freeing activities should strive to
affect other threads not in the same cgroup minimally.

On the other hand, we also don't do this throttling of kworkersA 
today (e.g. pdflush) according to the cgroup it is doing work for.


Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

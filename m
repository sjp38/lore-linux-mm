Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 756546B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:54:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c87so11724161pfl.6
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 23:54:35 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n8si4350750pll.303.2017.03.15.23.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 23:54:34 -0700 (PDT)
Date: Thu, 16 Mar 2017 14:54:44 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170316065444.GA1661@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315162843.GA27197@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed, Mar 15, 2017 at 05:28:43PM +0100, Michal Hocko wrote:
> On Wed 15-03-17 23:44:07, Aaron Lu wrote:
> > On Wed, Mar 15, 2017 at 03:18:14PM +0100, Michal Hocko wrote:
> > > On Wed 15-03-17 16:59:59, Aaron Lu wrote:
> > > [...]
> > > > The proposed parallel free did this: if the process has many pages to be
> > > > freed, accumulate them in these struct mmu_gather_batch(es) one after
> > > > another till 256K pages are accumulated. Then take this singly linked
> > > > list starting from tlb->local.next off struct mmu_gather *tlb and free
> > > > them in a worker thread. The main thread can return to continue zap
> > > > other pages(after freeing pages pointed by tlb->local.pages).
> > > 
> > > I didn't have a look at the implementation yet but there are two
> > > concerns that raise up from this description. Firstly how are we going
> > > to tune the number of workers. I assume there will be some upper bound
> > > (one of the patch subject mentions debugfs for tuning) and secondly
> > 
> > The workers are put in a dedicated workqueue which is introduced in
> > patch 3/5 and the number of workers can be tuned through that workqueue's
> > sysfs interface: max_active.
> 
> I suspect we cannot expect users to tune this. What do you consider a
> reasonable default?

I agree with Tim that 4 is a reasonable number for now.

> 
> Moreover, and this is a more generic question, is this functionality
> useful in general purpose workloads? After all the amount of the work to

I'm not sure. The main motivation is to speed up the exit of the crashed
application as explained by Dave.

> be done is the same we just risk more lock contentions, unexpected CPU
> usage etc. Which workloads will benefit from having exit path faster?
>  
> > > if we offload the page freeing to the worker then the original context
> > > can consume much more cpu cycles than it was configured via cpu
> 
> I was not precise here. I meant to say more cpu cycles per time unit
> that it was allowed.
> 
> > > controller. How are we going to handle that? Or is this considered
> > > acceptable?
> > 
> > I'll need to think about and take a look at this subject(not familiar
> > with cpu controller).
> 
> the main problem is that kworkers will not belong to the same cpu group
> and so they will not be throttled properly.

Looks like a fundamental problem as long as kworker is used.
With the default max_active of the workqueue set to 4, do you think this
is a blocking issue?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

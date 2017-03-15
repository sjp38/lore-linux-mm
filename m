Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 642796B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 12:28:48 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g10so3905294wrg.5
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:28:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l187si1048620wml.150.2017.03.15.09.28.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 09:28:47 -0700 (PDT)
Date: Wed, 15 Mar 2017 17:28:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170315162843.GA27197@dhcp22.suse.cz>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315154406.GF2442@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed 15-03-17 23:44:07, Aaron Lu wrote:
> On Wed, Mar 15, 2017 at 03:18:14PM +0100, Michal Hocko wrote:
> > On Wed 15-03-17 16:59:59, Aaron Lu wrote:
> > [...]
> > > The proposed parallel free did this: if the process has many pages to be
> > > freed, accumulate them in these struct mmu_gather_batch(es) one after
> > > another till 256K pages are accumulated. Then take this singly linked
> > > list starting from tlb->local.next off struct mmu_gather *tlb and free
> > > them in a worker thread. The main thread can return to continue zap
> > > other pages(after freeing pages pointed by tlb->local.pages).
> > 
> > I didn't have a look at the implementation yet but there are two
> > concerns that raise up from this description. Firstly how are we going
> > to tune the number of workers. I assume there will be some upper bound
> > (one of the patch subject mentions debugfs for tuning) and secondly
> 
> The workers are put in a dedicated workqueue which is introduced in
> patch 3/5 and the number of workers can be tuned through that workqueue's
> sysfs interface: max_active.

I suspect we cannot expect users to tune this. What do you consider a
reasonable default?

Moreover, and this is a more generic question, is this functionality
useful in general purpose workloads? After all the amount of the work to
be done is the same we just risk more lock contentions, unexpected CPU
usage etc. Which workloads will benefit from having exit path faster?
 
> > if we offload the page freeing to the worker then the original context
> > can consume much more cpu cycles than it was configured via cpu

I was not precise here. I meant to say more cpu cycles per time unit
that it was allowed.

> > controller. How are we going to handle that? Or is this considered
> > acceptable?
> 
> I'll need to think about and take a look at this subject(not familiar
> with cpu controller).

the main problem is that kworkers will not belong to the same cpu group
and so they will not be throttled properly.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

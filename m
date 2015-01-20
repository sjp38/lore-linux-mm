Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 70CBC6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 05:11:23 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so23580298wib.5
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 02:11:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si4437338wiw.7.2015.01.20.02.11.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 02:11:21 -0800 (PST)
Date: Tue, 20 Jan 2015 11:11:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm v2] vmscan: move reclaim_state handling to shrink_slab
Message-ID: <20150120101120.GA25342@dhcp22.suse.cz>
References: <1421311073-28130-1-git-send-email-vdavydov@parallels.com>
 <20150115125820.GE7000@dhcp22.suse.cz>
 <20150115132516.GG11264@esperanza>
 <20150115144838.GI7000@dhcp22.suse.cz>
 <20150120073550.GP9719@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150120073550.GP9719@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 19-01-15 23:35:50, Paul E. McKenney wrote:
> On Thu, Jan 15, 2015 at 03:48:38PM +0100, Michal Hocko wrote:
> > On Thu 15-01-15 16:25:16, Vladimir Davydov wrote:
[...]
> > > Does RCU free objects from irq or soft irq context?
> > 
> > and this is another part which I didn't consider at all. RCU callbacks
> > are normally processed from kthread context but rcu_init also does
> > open_softirq(RCU_SOFTIRQ, rcu_process_callbacks)
> > so something is clearly processed from softirq as well. I am not
> > familiar with RCU details enough to tell how many callbacks are
> > processed this way. Tiny RCU, on the other hand, seem to be processing
> > all callbacks via __rcu_process_callbacks and that seems to be processed
> > from softirq only.
> 
> RCU invokes all its callbacks with BH disabled, either because they
> are running in softirq context or because the rcuo kthreads disable
> BH while invoking each callback.  When running in softirq context,
> RCU will normally invoke only ten callbacks before letting the other
> softirq vectors run.  However, if there are more than 10,000 callbacks
> queued on a given CPU (which can happen!), RCU will go into panic mode
> and just invoke the callbacks as quickly as it can.

Thanks for the clarification, Paul! This means that not only drivers
might free some memory but also kfree called from RCU context would do
so this adds potentially even more memcg unrelated noise.
 
> You can of course have your callback schedule a work-queue item or
> wake up a kthread to avoid this tradeoff.
> 
> 							Thanx, Paul
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

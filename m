Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE976B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 03:44:26 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so122428392pac.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 00:44:26 -0700 (PDT)
Received: from mail-pf0-f193.google.com (mail-pf0-f193.google.com. [209.85.192.193])
        by mx.google.com with ESMTPS id e83si1019741pfj.74.2016.04.15.00.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 00:44:25 -0700 (PDT)
Received: by mail-pf0-f193.google.com with SMTP id r187so9232550pfr.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 00:44:25 -0700 (PDT)
Date: Fri, 15 Apr 2016 09:44:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 01/19] tree wide: get rid of __GFP_REPEAT for order-0
 allocations part I
Message-ID: <20160415074421.GB32377@dhcp22.suse.cz>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <1460372892-8157-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1604141255020.6593@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1604141255020.6593@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org

On Thu 14-04-16 12:56:28, David Rientjes wrote:
> On Mon, 11 Apr 2016, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __GFP_REPEAT has a rather weak semantic but since it has been introduced
> > around 2.6.12 it has been ignored for low order allocations. Yet we have
> > the full kernel tree with its usage for apparently order-0 allocations.
> > This is really confusing because __GFP_REPEAT is explicitly documented
> > to allow allocation failures which is a weaker semantic than the current
> > order-0 has (basically nofail).
> > 
> > Let's simply drop __GFP_REPEAT from those places. This would allow
> > to identify place which really need allocator to retry harder and
> > formulate a more specific semantic for what the flag is supposed to do
> > actually.
> > 
> > Cc: linux-arch@vger.kernel.org
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> I did exactly this before, and Andrew objected saying that __GFP_REPEAT 
> may not be needed for the current page allocator's implementation but 
> could with others and that setting __GFP_REPEAT for an allocation 
> provided useful information with regards to intent.

>From what I've seen it was more a copy&paste of the arch code which
spread out this flag and there was also a misleading usage.

> At the time, I attempted to eliminate __GFP_REPEAT entirely.

This is not my plan. I actually want to provide a useful semantic for
something like this flag - aka try really hard but eventually fail
for all orders and stop being special only for those that are costly. I
will call it __GFP_BEST_EFFORT. But I have to clean up the current usage
first. Costly orders will keep __GFP_REPEAT because the intent is clear
there. All others will lose the flag and then we can start adding
__GFP_BEST_EFFORT where it matters also for lower orders.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

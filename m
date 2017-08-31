Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EAA66B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 05:43:38 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u93so274034wrc.10
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 02:43:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t76si90374wme.39.2017.08.31.02.43.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Aug 2017 02:43:36 -0700 (PDT)
Date: Thu, 31 Aug 2017 10:29:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170831092909.kavmkrdisq7xx2eu@suse.de>
References: <20170728091904.14627-1-mhocko@kernel.org>
 <20170823175709.GA22743@xo-6d-61-c0.localdomain>
 <20170825063545.GA25498@dhcp22.suse.cz>
 <20170825072818.GA15494@amd>
 <20170825080442.GF25498@dhcp22.suse.cz>
 <20170825213936.GA13576@amd>
 <87pobjhssq.fsf@notabene.neil.brown.name>
 <20170828123657.GK17097@dhcp22.suse.cz>
 <20170831090722.GA12920@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170831090722.GA12920@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Michal Hocko <mhocko@kernel.org>, NeilBrown <neilb@suse.com>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 31, 2017 at 11:07:22AM +0200, Pavel Machek wrote:
> > > > "This allocation is temporary. It lasts milliseconds, not hours."
> > > 
> > > It isn't sufficient to give a rule for when GFP_TEMPORARY will be used,
> > > you also need to explain (at least in general terms) how the information
> > > will be used.  Also you need to give guidelines on whether the flag
> > > should be set for allocation that will last seconds or minutes.
> > > 
> > > If we have a flag that doesn't have a well defined meaning that actually
> > > affects behavior, it will not be used consistently, and if we ever
> > > change exactly how it behaves we can expect things to break.  So it is
> > > better not to have a flag, than to have a poorly defined flag.
> > 
> > Absolutely agreed!
> > 
> > > My current thoughts is that the important criteria is not how long the
> > > allocation will be used for, but whether it is reclaimable.  Allocations
> > > that will only last 5 msecs are reclaimable by calling "usleep(5000)".
> > > Other allocations might be reclaimable in other ways.  Allocations that
> > > are not reclaimable may well be directed to a more restricted pool of
> > > memory, and might be more likely to fail.  If we grew a strong
> > > "reclaimable" concept, this 'temporary' concept that you want to hold on
> > > to would become a burden.
> > 
> > ... and here again. The whole motivation for the flag was to gather
> > these objects together and reduce chances of internal fragmentation
> > due to long lived objects mixed with short term ones. Without an
> > explicit way to reclaim those objects or having a clear checkpoint to
> > wait for it is not really helping us to reach desired outcome (less
> > fragmented memory).
> 
> Really?
> 
> If you group allocations that last << 1 second, and ones that last >>
> 1 second, I'm pretty sure it reduces fragmentation... "reclaimable" or
> not.
> 

If this was always done reliably then sure, it makes sense. At the time it
was introduced by me, proc was used to relay large amounts of information
to userspace. The patch had a noticable impact but on limited memory,
32-bit and this proc relay was in use. In retrospect, it's possible that
it was the monitoring itself that showed a "benefit" for the patch.

If the flag is used incorrectly even once then the value is diminished
and it can even cause harm (not as severe as misusing __GFP_MOVABLE but
harmful nonetheless). It only has a benefit if there is a large source of
temporary allocations that are long-lived enough to cause fragmentation
during small intervals and to be honest, directly measuring that is
extremely difficult. The benefit is too marginal, the potential for harm
is high and Michal is right to remove it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

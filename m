Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC89B6B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 05:48:59 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y16so2307678wmd.6
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 02:48:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xx2si4560081wjc.251.2016.12.02.02.48.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 02:48:58 -0800 (PST)
Date: Fri, 2 Dec 2016 11:48:51 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: alloc_contig: demote PFN busy message to debug level
Message-ID: <20161202104851.GH6830@dhcp22.suse.cz>
References: <20161202095742.32449-1-l.stach@pengutronix.de>
 <74234427-005f-609e-3f33-cdf9a739c1d2@suse.cz>
 <1480675271.17003.50.camel@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480675271.17003.50.camel@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, "Robin H. Johnson" <robbat2@gentoo.org>, kernel@pengutronix.de, Andrew Morton <akpm@linux-foundation.org>, patchwork-lst@pengutronix.de, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Fri 02-12-16 11:41:11, Lucas Stach wrote:
> Am Freitag, den 02.12.2016, 11:18 +0100 schrieb Vlastimil Babka:
> > On 12/02/2016 10:57 AM, Lucas Stach wrote:
> > > There are a lot of reasons why a PFN might be busy and unable to be isolated
> > > some of which can't really be avoided. This message is spamming the logs when
> > > a lot of CMA allocations are happening, causing isolation to happen quite
> > > frequently.
> > 
> > Is this related to Robin's report [1] or you have an independent case of 
> > lots of CMA allocations, and in which context are there?
> > 
> No, I've seen this bug report, but this patch was sitting to be sent out
> for a while now.
> 
> > > Demote the message to log level, as CMA will just retry the allocation, so
> > > there is no need to have this message in the logs. If someone is interested
> > > in the failing case, there is a tracepoint to track those failures properly.
> > 
> > I don't think we should just hide the issue like this, as getting high 
> > volume reports from this is also very likely associated with high 
> > overhead for the allocations. If it's the generic dma-cma context, like 
> > in [1] where it attempts CMA for order-0 allocations, we should first do 
> > something about that, before tweaking the logging.
> > 
> Etnaviv (the driver I maintain) currently does a stupid thing by
> allocating and freeing lots of DMA buffers (higher-order) from different
> threads. This is causing overhead at the CMA side, but really isn't
> something to be handled at the CMA side, but rather Etnaviv must get
> more clever about its CMA usage.
> 
> Still this message is really disturbing as page isolation failures can
> be caused by lots of other reasons like temporarily pinned pages.

Hmm, then I think that what Robin has proposed [1] should be a generally
better solution because it both ratelimits and points to the user who is
triggering this path. I am still not really sure I understand why is the
message useful, to be honest so it very well might be better to just
remove it altogether. This is something for the CMA guys to answer
though.

[1] http://lkml.kernel.org/r/robbat2-20161130T195244-998539995Z@orbis-terrarum.net
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

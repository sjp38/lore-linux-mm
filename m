Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 315886B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 05:57:49 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so44198075wjb.7
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 02:57:49 -0800 (PST)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id bt18si4616496wjb.137.2016.12.02.02.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 02:57:48 -0800 (PST)
Message-ID: <1480676263.17003.55.camel@pengutronix.de>
Subject: Re: [PATCH] mm: alloc_contig: demote PFN busy message to debug level
From: Lucas Stach <l.stach@pengutronix.de>
Date: Fri, 02 Dec 2016 11:57:43 +0100
In-Reply-To: <20161202104851.GH6830@dhcp22.suse.cz>
References: <20161202095742.32449-1-l.stach@pengutronix.de>
	 <74234427-005f-609e-3f33-cdf9a739c1d2@suse.cz>
	 <1480675271.17003.50.camel@pengutronix.de>
	 <20161202104851.GH6830@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, "Robin H. Johnson" <robbat2@gentoo.org>, kernel@pengutronix.de, Andrew Morton <akpm@linux-foundation.org>, patchwork-lst@pengutronix.de, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>

Am Freitag, den 02.12.2016, 11:48 +0100 schrieb Michal Hocko:
> On Fri 02-12-16 11:41:11, Lucas Stach wrote:
> > Am Freitag, den 02.12.2016, 11:18 +0100 schrieb Vlastimil Babka:
> > > On 12/02/2016 10:57 AM, Lucas Stach wrote:
> > > > There are a lot of reasons why a PFN might be busy and unable to be isolated
> > > > some of which can't really be avoided. This message is spamming the logs when
> > > > a lot of CMA allocations are happening, causing isolation to happen quite
> > > > frequently.
> > > 
> > > Is this related to Robin's report [1] or you have an independent case of 
> > > lots of CMA allocations, and in which context are there?
> > > 
> > No, I've seen this bug report, but this patch was sitting to be sent out
> > for a while now.
> > 
> > > > Demote the message to log level, as CMA will just retry the allocation, so
> > > > there is no need to have this message in the logs. If someone is interested
> > > > in the failing case, there is a tracepoint to track those failures properly.
> > > 
> > > I don't think we should just hide the issue like this, as getting high 
> > > volume reports from this is also very likely associated with high 
> > > overhead for the allocations. If it's the generic dma-cma context, like 
> > > in [1] where it attempts CMA for order-0 allocations, we should first do 
> > > something about that, before tweaking the logging.
> > > 
> > Etnaviv (the driver I maintain) currently does a stupid thing by
> > allocating and freeing lots of DMA buffers (higher-order) from different
> > threads. This is causing overhead at the CMA side, but really isn't
> > something to be handled at the CMA side, but rather Etnaviv must get
> > more clever about its CMA usage.
> > 
> > Still this message is really disturbing as page isolation failures can
> > be caused by lots of other reasons like temporarily pinned pages.
> 
> Hmm, then I think that what Robin has proposed [1] should be a generally
> better solution because it both ratelimits and points to the user who is
> triggering this path. 

Dumping a stacktrace at this point is only going to increase the noise
from this message, as it can be trigger under normal operating
conditions of CMA. If someone temporarily locked a previously movable
page with GUP or something alike, the stacktrace will point to the
victim rather than the offender, so I think the value of the stackstrace
is rather limited.

Regards,
Lucas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

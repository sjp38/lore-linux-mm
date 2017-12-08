Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 122126B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 05:03:32 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j4so5694788wrg.15
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 02:03:32 -0800 (PST)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id h1si5475855wre.294.2017.12.08.02.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 02:03:29 -0800 (PST)
Message-ID: <1512727403.11506.21.camel@pengutronix.de>
Subject: Re: [PATCH] mm: page_alloc: avoid excessive IRQ disabled times in
 free_unref_page_list
From: Lucas Stach <l.stach@pengutronix.de>
Date: Fri, 08 Dec 2017 11:03:23 +0100
In-Reply-To: <20171207195103.dkiqjoeasr35atqj@techsingularity.net>
References: <20171207170314.4419-1-l.stach@pengutronix.de>
	 <20171207195103.dkiqjoeasr35atqj@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

Am Donnerstag, den 07.12.2017, 19:51 +0000 schrieb Mel Gorman:
> On Thu, Dec 07, 2017 at 06:03:14PM +0100, Lucas Stach wrote:
> > Since 9cca35d42eb6 (mm, page_alloc: enable/disable IRQs once when
> > freeing
> > a list of pages) we see excessive IRQ disabled times of up to 250ms
> > on an
> > embedded ARM system (tracing overhead included).
> > 
> > This is due to graphics buffers being freed back to the system via
> > release_pages(). Graphics buffers can be huge, so it's not hard to
> > hit
> > cases where the list of pages to free has 2048 entries. Disabling
> > IRQs
> > while freeing all those pages is clearly not a good idea.
> > 
> 
> 250ms to free 2048 entries? That seems excessive but I guess the
> embedded ARM system is not that fast.

Urgh, yes, I've messed up the order of magnitude in the commit log. It
really is on the order of 25ms. Which is still prohibitively long for
an IRQs off section.

Regards,
Lucas

> > Introduce a batch limit, which allows IRQ servicing once every few
> > pages.
> > The batch count is the same as used in other parts of the MM
> > subsystem
> > when dealing with IRQ disabled regions.
> > 
> > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> 
> Thanks.
> 
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

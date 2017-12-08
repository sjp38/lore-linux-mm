Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B958A6B026A
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 06:39:01 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i71so889591wmd.9
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 03:39:01 -0800 (PST)
Received: from outbound-smtp22.blacknight.com (outbound-smtp22.blacknight.com. [81.17.249.190])
        by mx.google.com with ESMTPS id k62si1048983edc.303.2017.12.08.03.39.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 03:39:00 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp22.blacknight.com (Postfix) with ESMTPS id 3407FB8E8E
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 11:38:58 +0000 (GMT)
Date: Fri, 8 Dec 2017 11:38:56 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: avoid excessive IRQ disabled times in
 free_unref_page_list
Message-ID: <20171208113856.7352reah7xebvp7a@techsingularity.net>
References: <20171207170314.4419-1-l.stach@pengutronix.de>
 <20171207195103.dkiqjoeasr35atqj@techsingularity.net>
 <1512727403.11506.21.camel@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1512727403.11506.21.camel@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On Fri, Dec 08, 2017 at 11:03:23AM +0100, Lucas Stach wrote:
> Am Donnerstag, den 07.12.2017, 19:51 +0000 schrieb Mel Gorman:
> > On Thu, Dec 07, 2017 at 06:03:14PM +0100, Lucas Stach wrote:
> > > Since 9cca35d42eb6 (mm, page_alloc: enable/disable IRQs once when
> > > freeing
> > > a list of pages) we see excessive IRQ disabled times of up to 250ms
> > > on an
> > > embedded ARM system (tracing overhead included).
> > > 
> > > This is due to graphics buffers being freed back to the system via
> > > release_pages(). Graphics buffers can be huge, so it's not hard to
> > > hit
> > > cases where the list of pages to free has 2048 entries. Disabling
> > > IRQs
> > > while freeing all those pages is clearly not a good idea.
> > > 
> > 
> > 250ms to free 2048 entries? That seems excessive but I guess the
> > embedded ARM system is not that fast.
> 
> Urgh, yes, I've messed up the order of magnitude in the commit log. It
> really is on the order of 25ms. Which is still prohibitively long for
> an IRQs off section.
> 

Ok, 25ms is more plausible but I agree that it's still an excessive
amount of time to have IRQs disabled. The problem still needs fixing but
I'd like to see Andrew's approach at least attempted as it should
achieve the same goal while being slightly nicer from a cache hotness
perspective.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

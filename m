Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 987EA6B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 18:21:04 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a45so4877979wra.14
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 15:21:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b9si4480224wrf.514.2017.12.07.15.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 15:21:02 -0800 (PST)
Date: Thu, 7 Dec 2017 15:20:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: page_alloc: avoid excessive IRQ disabled times in
 free_unref_page_list
Message-Id: <20171207152059.96ebc2f7dfd1a65a91252029@linux-foundation.org>
In-Reply-To: <20171207195103.dkiqjoeasr35atqj@techsingularity.net>
References: <20171207170314.4419-1-l.stach@pengutronix.de>
	<20171207195103.dkiqjoeasr35atqj@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Lucas Stach <l.stach@pengutronix.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On Thu, 7 Dec 2017 19:51:03 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> On Thu, Dec 07, 2017 at 06:03:14PM +0100, Lucas Stach wrote:
> > Since 9cca35d42eb6 (mm, page_alloc: enable/disable IRQs once when freeing
> > a list of pages) we see excessive IRQ disabled times of up to 250ms on an
> > embedded ARM system (tracing overhead included).
> > 
> > This is due to graphics buffers being freed back to the system via
> > release_pages(). Graphics buffers can be huge, so it's not hard to hit
> > cases where the list of pages to free has 2048 entries. Disabling IRQs
> > while freeing all those pages is clearly not a good idea.
> > 
> 
> 250ms to free 2048 entries? That seems excessive but I guess the
> embedded ARM system is not that fast.

I wonder how common such lenghty lists are.

If "significantly" then there may be additional benefit in rearranging
free_hot_cold_page_list() so it only walks a small number of list
entries at a time.  So the data from the first loop is still in cache
during execution of the second loop.  And that way this
long-irq-off-time problem gets fixed automagically.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

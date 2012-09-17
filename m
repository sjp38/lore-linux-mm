Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id F38C86B006E
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 05:12:56 -0400 (EDT)
Received: by dadi14 with SMTP id i14so748619dad.14
        for <linux-mm@kvack.org>; Mon, 17 Sep 2012 02:12:56 -0700 (PDT)
Date: Mon, 17 Sep 2012 02:12:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] Try pages allocation from higher to lower orders
In-Reply-To: <CAPqfFkCGuoJhkyyAJzxPo0VQJR6t7h1pCacKUa6PDiwWW7j5EA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1209170206300.25095@chino.kir.corp.google.com>
References: <CAPqfFkCGuoJhkyyAJzxPo0VQJR6t7h1pCacKUa6PDiwWW7j5EA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Cohen <dacohen@gmail.com>
Cc: linux-mm@kvack.org

On Sun, 9 Sep 2012, David Cohen wrote:

> Requesting pages with order > 0 is faster than requesting a single
> page 20k times if memory isn't fragmented. But in case memory is
> fragmented, at some point order > 0 may not be available and page
> allocation process go through more expensive path, which ends up being
> slower than requesting 20k single pages. I'd like to have a way to
> choose faster option depending on fragmentation scenario.
> Is there currently a reliable solution for this case? Couldn't find one.
> If the answer is really "no", what does it sound like to implement a
> function e.g. alloc_pages_try_orders(mask, min_order, max_order).

I don't think that's generally useful, so it would have to be isolated to 
the driver you're working on.  But what I would suggest would be to avoid 
doing memory compaction and reclaim on higher orders and rather fallback 
to allocating smaller and smaller orders first.  Try using 
fragmentation_index() and determine the optimal order to allocate 
depending on the current state of fragmentation; if that's insufficient, 
then you'll have to fallback to using memory compaction.  You'll want to 
compact much more than a single order-9 page allocation, though, so 
perhaps explicitly trigger compact_node() beforehand and try to incur the 
penalty only once.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

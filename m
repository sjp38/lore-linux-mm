Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED7BE900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 18:49:56 -0400 (EDT)
Date: Tue, 12 Apr 2011 15:49:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Regression from 2.6.36
Message-Id: <20110412154906.70829d60.akpm@linux-foundation.org>
In-Reply-To: <1302190586.3357.45.camel@edumazet-laptop>
References: <20110315132527.130FB80018F1@mail1005.cent>
	<20110317001519.GB18911@kroah.com>
	<20110407120112.E08DCA03@pobox.sk>
	<4D9D8FAA.9080405@suse.cz>
	<BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>
	<1302177428.3357.25.camel@edumazet-laptop>
	<1302178426.3357.34.camel@edumazet-laptop>
	<BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
	<1302190586.3357.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>, =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

On Thu, 07 Apr 2011 17:36:26 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 07 avril 2011 __ 23:27 +0800, Changli Gao a __crit :
> 
> > azurlt, would you please test the patch attached? Thanks.
> > 
> 
> Yes of course, I meant to reverse the patch
> 
> (use kmalloc() under PAGE_SIZE, vmalloc() for 'big' allocs)
> 
> 
> Dont fallback to vmalloc if kmalloc() fails.
> 
> 
> if (size <= PAGE_SIZE)
> 	return kmalloc(size, GFP_KERNEL);
> else
> 	return vmalloc(size);
> 

It's somewhat unclear (to me) what caused this regression.

Is it because the kernel is now doing large kmalloc()s for the fdtable,
and this makes the page allocator go nuts trying to satisfy high-order
page allocation requests?

Is it because the kernel now will usually free the fdtable
synchronously within the rcu callback, rather than deferring this to a
workqueue?

The latter seems unlikely, so I'm thinking this was a case of
high-order-allocations-considered-harmful?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

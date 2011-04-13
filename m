Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 78637900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 21:29:10 -0400 (EDT)
Date: Tue, 12 Apr 2011 18:31:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Regression from 2.6.36
Message-Id: <20110412183132.a854bffc.akpm@linux-foundation.org>
In-Reply-To: <BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com>
References: <20110315132527.130FB80018F1@mail1005.cent>
	<20110317001519.GB18911@kroah.com>
	<20110407120112.E08DCA03@pobox.sk>
	<4D9D8FAA.9080405@suse.cz>
	<BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>
	<1302177428.3357.25.camel@edumazet-laptop>
	<1302178426.3357.34.camel@edumazet-laptop>
	<BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
	<1302190586.3357.45.camel@edumazet-laptop>
	<20110412154906.70829d60.akpm@linux-foundation.org>
	<BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changli Gao <xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

On Wed, 13 Apr 2011 09:23:11 +0800 Changli Gao <xiaosuo@gmail.com> wrote:

> On Wed, Apr 13, 2011 at 6:49 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >
> > It's somewhat unclear (to me) what caused this regression.
> >
> > Is it because the kernel is now doing large kmalloc()s for the fdtable,
> > and this makes the page allocator go nuts trying to satisfy high-order
> > page allocation requests?
> >
> > Is it because the kernel now will usually free the fdtable
> > synchronously within the rcu callback, rather than deferring this to a
> > workqueue?
> >
> > The latter seems unlikely, so I'm thinking this was a case of
> > high-order-allocations-considered-harmful?
> >
> 
> Maybe, but I am not sure. Maybe my patch causes too many inner
> fragments. For example, when asking for 5 pages, get 8 pages, and 3
> pages are wasted, then memory thrash happens finally.

That theory sounds less likely, but could be tested by using
alloc_pages_exact().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E67686B0047
	for <linux-mm@kvack.org>; Sun, 26 Sep 2010 22:17:37 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8R2HNwc016913
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 27 Sep 2010 11:17:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A341745DE4E
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:17:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 872B545DE4C
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:17:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 729BCE38001
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:17:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DDF41DB8013
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:17:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: do not print backtraces on GFP_ATOMIC failures
In-Reply-To: <1285088427.2617.723.camel@edumazet-laptop>
References: <20100921094638.9910add0.akpm@linux-foundation.org> <1285088427.2617.723.camel@edumazet-laptop>
Message-Id: <20100927110723.6B37.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 27 Sep 2010 11:17:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > > @@ -72,7 +72,7 @@ struct vm_area_struct;
> > >  /* This equals 0, but use constants in case they ever change */
> > >  #define GFP_NOWAIT	(GFP_ATOMIC & ~__GFP_HIGH)
> > >  /* GFP_ATOMIC means both !wait (__GFP_WAIT not set) and use emergency pool */
> > > -#define GFP_ATOMIC	(__GFP_HIGH)
> > > +#define GFP_ATOMIC	(__GFP_HIGH | __GFP_NOWARN)
> > >  #define GFP_NOIO	(__GFP_WAIT)
> > >  #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
> > >  #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
> > 
> > A much finer-tuned implementation would be to add __GFP_NOWARN just to
> > the networking call sites.  I asked about this in June and it got
> > nixed:
> > 
> > http://www.spinics.net/lists/netdev/msg131965.html
> > --
> 
> Yes, I remember this particular report was useful to find and correct a
> bug.
> 
> I dont know what to say.
> 
> Being silent or verbose, it really depends on the context ?

At least, MM developers don't want to track network allocation failure
issue. We don't have enough knowledge in this area. To be honest, We 
are unhappy current bad S/N bug report rate ;)

Traditionally, We hoped this warnings help to debug VM issue. but
It haven't happen. We haven't detect VM issue from this allocation
failure report. Instead, We've received a lot of network allocation
failure report.

Recently, The S/N ratio became more bad. If the network device enable
jumbo frame feature, order-2 GFP_ATOMIC allocation is called frequently.
Anybody don't have to assume order-2 allocation can success anytime.

I'm not against accurate warning at all. but I cant tolerate this
semi-random warning steal our time. If anyone will not make accurate
warning, I hope to remove this one completely instead.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

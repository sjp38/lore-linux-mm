Subject: Re: [PATCH] Add freezer call in
From: Nigel Cunningham <ncunningham@cyclades.com>
Reply-To: ncunningham@cyclades.com
In-Reply-To: <20050315233740.GE21292@elf.ucw.cz>
References: <1110925280.6454.143.camel@desktop.cunningham.myip.net.au>
	 <20050315233740.GE21292@elf.ucw.cz>
Content-Type: text/plain
Message-Id: <1110935361.6454.197.camel@desktop.cunningham.myip.net.au>
Mime-Version: 1.0
Date: Wed, 16 Mar 2005 12:09:21 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@digeo.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Wed, 2005-03-16 at 10:37, Pavel Machek wrote:
> Hi!
> 
> > This patch adds a freezer call to the slow path in __alloc_pages. It
> > thus avoids freezing failures in low memory situations. Like the other
> > patches, it has been in Suspend2 for longer than I can remember.
> 
> This one seems wrong.
> 
> What if someone does
> 
> 	down(&some_lock_needed_during_suspend);
> 	kmalloc()
> 
> ? If you freeze him during that allocation, you'll deadlock later...

I suppose you're right. I'll see if I can look into this situation some
more. (Longer todo!).

Nigel

> > Signed-of-by: Nigel Cunningham <ncunningham@cyclades.com>
> > 
> > diff -ruNp 213-missing-refrigerator-calls-old/mm/page_alloc.c 213-missing-refrigerator-calls-new/mm/page_alloc.c
> > --- 213-missing-refrigerator-calls-old/mm/page_alloc.c	2005-02-03 22:33:50.000000000 +1100
> > +++ 213-missing-refrigerator-calls-new/mm/page_alloc.c	2005-03-16 09:01:28.000000000 +1100
> > @@ -838,6 +838,7 @@ rebalance:
> >  			do_retry = 1;
> >  	}
> >  	if (do_retry) {
> > +		try_to_freeze(0);
> >  		blk_congestion_wait(WRITE, HZ/50);
> >  		goto rebalance;
> >  	}
-- 
Nigel Cunningham
Software Engineer, Canberra, Australia
http://www.cyclades.com
Bus: +61 (2) 6291 9554; Hme: +61 (2) 6292 8028;  Mob: +61 (417) 100 574

Maintainer of Suspend2 Kernel Patches http://suspend2.net

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

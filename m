Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E6C696B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 02:02:21 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5462CVH026826
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Jun 2009 15:02:12 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26ECD45DE7A
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 15:02:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E638145DE70
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 15:02:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B5F371DB8044
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 15:02:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 58B041DB803B
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 15:02:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Warn if we run out of swap space
In-Reply-To: <alpine.DEB.1.10.0905270953100.17417@gentwo.org>
References: <20090527094224.67cace20.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.1.10.0905270953100.17417@gentwo.org>
Message-Id: <20090604144619.085A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Jun 2009 15:02:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Paul Mundt <lethal@linux-sh.org>, Randy Dunlap <randy.dunlap@oracle.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> On Wed, 27 May 2009, KAMEZAWA Hiroyuki wrote:
> 
> > >  3 files changed, 17 insertions(+)
> > >
> > > Index: linux-2.6/mm/swapfile.c
> > > ===================================================================
> > > --- linux-2.6.orig/mm/swapfile.c	2009-05-22 14:03:37.000000000 -0500
> > > +++ linux-2.6/mm/swapfile.c	2009-05-26 09:11:52.000000000 -0500
> > > @@ -374,6 +374,8 @@ no_page:
> > >  	return 0;
> > >  }
> > >
> > > +int out_of_swap_message_printed = 0;
> > > +
> > >  swp_entry_t get_swap_page(void)
> > >  {
> > >  	struct swap_info_struct *si;
> > > @@ -410,6 +412,11 @@ swp_entry_t get_swap_page(void)
> > >  	}
> > >
> > >  	nr_swap_pages++;
> > > +	if (!out_of_swap_message_printed) {
> > > +		out_of_swap_message_printed = 1;
> > > +		printk(KERN_WARNING "All of swap is in use. Some pages "
> > > +			"cannot be swapped out.\n");
> > > +	}
> > >  noswap:
> > >  	spin_unlock(&swap_lock);
> > BTW, hmm
> >
> > Isn't this should be
> > ==
> > noswap:
> > 	if (total_swap_pages && !out_of_swap_message_printed) {
> > 		....
> > 	}
> 
> Look at the beginning of get_swap_page():
> 
>    spin_lock(&swap_lock);
>         if (nr_swap_pages <= 0)
>                 goto noswap;
>         nr_swap_pages--;
> 
> I placed the printk intentionally before the noswap label.

I tested your patch. but it never output warning messages although swap full.

thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

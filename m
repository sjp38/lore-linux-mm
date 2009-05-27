Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 295846B005D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 09:54:32 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 41E4482C536
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:09:27 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PgVDpxd35Azc for <linux-mm@kvack.org>;
	Wed, 27 May 2009 10:09:27 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 63AB282C538
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:09:22 -0400 (EDT)
Date: Wed, 27 May 2009 09:54:59 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Warn if we run out of swap space
In-Reply-To: <20090527094224.67cace20.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905270953100.17417@gentwo.org>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <20090524144056.0849.A69D9226@jp.fujitsu.com> <4A1A057A.3080203@oracle.com> <20090526032934.GC9188@linux-sh.org> <alpine.DEB.1.10.0905261022170.7242@gentwo.org>
 <20090527094224.67cace20.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Paul Mundt <lethal@linux-sh.org>, Randy Dunlap <randy.dunlap@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 27 May 2009, KAMEZAWA Hiroyuki wrote:

> >  3 files changed, 17 insertions(+)
> >
> > Index: linux-2.6/mm/swapfile.c
> > ===================================================================
> > --- linux-2.6.orig/mm/swapfile.c	2009-05-22 14:03:37.000000000 -0500
> > +++ linux-2.6/mm/swapfile.c	2009-05-26 09:11:52.000000000 -0500
> > @@ -374,6 +374,8 @@ no_page:
> >  	return 0;
> >  }
> >
> > +int out_of_swap_message_printed = 0;
> > +
> >  swp_entry_t get_swap_page(void)
> >  {
> >  	struct swap_info_struct *si;
> > @@ -410,6 +412,11 @@ swp_entry_t get_swap_page(void)
> >  	}
> >
> >  	nr_swap_pages++;
> > +	if (!out_of_swap_message_printed) {
> > +		out_of_swap_message_printed = 1;
> > +		printk(KERN_WARNING "All of swap is in use. Some pages "
> > +			"cannot be swapped out.\n");
> > +	}
> >  noswap:
> >  	spin_unlock(&swap_lock);
> BTW, hmm
>
> Isn't this should be
> ==
> noswap:
> 	if (total_swap_pages && !out_of_swap_message_printed) {
> 		....
> 	}

Look at the beginning of get_swap_page():

   spin_lock(&swap_lock);
        if (nr_swap_pages <= 0)
                goto noswap;
        nr_swap_pages--;

I placed the printk intentionally before the noswap label.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

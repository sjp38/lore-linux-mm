Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 60FCC6B004D
	for <linux-mm@kvack.org>; Sun, 24 May 2009 20:54:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4P0t09A004532
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 May 2009 09:55:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0FF245DD7F
	for <linux-mm@kvack.org>; Mon, 25 May 2009 09:54:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DBEA45DD78
	for <linux-mm@kvack.org>; Mon, 25 May 2009 09:54:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FFD7E08003
	for <linux-mm@kvack.org>; Mon, 25 May 2009 09:54:59 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C9A71DB8038
	for <linux-mm@kvack.org>; Mon, 25 May 2009 09:54:59 +0900 (JST)
Date: Mon, 25 May 2009 09:53:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-Id: <20090525095326.8c8335e2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090522213847.5f4a276b.akpm@linux-foundation.org>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
	<20090522213847.5f4a276b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 22 May 2009 21:38:47 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 22 May 2009 14:58:19 -0400 (EDT) Christoph Lameter <cl@linux-foundation.org> wrote:
> 
> > 
> > Subject: Warn if we run out of swap space
> > 
> > Running out of swap space means that the evicton of anonymous pages may no longer
> > be possible which can lead to OOM conditions.
> > 
> > Print a warning when swap space first becomes exhausted.
> > 
> > Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> > 
> > ---
> >  mm/swapfile.c |    5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > Index: linux-2.6/mm/swapfile.c
> > ===================================================================
> > --- linux-2.6.orig/mm/swapfile.c	2009-05-22 12:25:19.000000000 -0500
> > +++ linux-2.6/mm/swapfile.c	2009-05-22 13:56:10.000000000 -0500
> > @@ -380,6 +380,7 @@ swp_entry_t get_swap_page(void)
> >  	pgoff_t offset;
> >  	int type, next;
> >  	int wrapped = 0;
> > +	static int printed = 0;
> > 
> >  	spin_lock(&swap_lock);
> >  	if (nr_swap_pages <= 0)
> > @@ -410,6 +411,10 @@ swp_entry_t get_swap_page(void)
> >  	}
> > 
> >  	nr_swap_pages++;
> > +	if (!printed) {
> > +		printed = 1;
> > +		printk(KERN_WARNING "All of swap is in use. Some pages cannot be swapped out.");
> > +	}
> >  noswap:
> >  	spin_unlock(&swap_lock);
> >  	return (swp_entry_t) {0};
> 
> I think the warning is useful.  (Although the missing \n makes me wonder
> how well tested this is).
> 
> However the once-per-boot thing weakens it quite a lot.  Suppose someone
> runs out of swap, sees the message, adds more swap then later runs out
> again?
> 
> Perhaps we could clear the `printed' flag each time the amount of online
> swap is altered?
> 
How about clearing it in the condition vm_swap_full() returns false ?
Anyway, I welcome this patch :)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

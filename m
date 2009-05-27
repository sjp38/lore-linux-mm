Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 845086B0055
	for <linux-mm@kvack.org>; Tue, 26 May 2009 20:26:52 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R0RFso028954
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 May 2009 09:27:15 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DA89C45DE55
	for <linux-mm@kvack.org>; Wed, 27 May 2009 09:27:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A810B45DE51
	for <linux-mm@kvack.org>; Wed, 27 May 2009 09:27:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 84E94E18005
	for <linux-mm@kvack.org>; Wed, 27 May 2009 09:27:14 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FE951DB8037
	for <linux-mm@kvack.org>; Wed, 27 May 2009 09:27:14 +0900 (JST)
Date: Wed, 27 May 2009 09:25:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-Id: <20090527092540.2a023168.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090526135527.750e7df2.akpm@linux-foundation.org>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
	<20090524144056.0849.A69D9226@jp.fujitsu.com>
	<4A1A057A.3080203@oracle.com>
	<20090526032934.GC9188@linux-sh.org>
	<alpine.DEB.1.10.0905261022170.7242@gentwo.org>
	<20090526131540.70fd410a.akpm@linux-foundation.org>
	<4A1C54D9.4030702@oracle.com>
	<20090526135527.750e7df2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, cl@linux.com, lethal@linux-sh.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, pavel@ucw.cz, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009 13:55:27 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 26 May 2009 13:45:13 -0700
> Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
> > Andrew Morton wrote:
> > > On Tue, 26 May 2009 10:23:36 -0400 (EDT)
> > > Christoph Lameter <cl@linux.com> wrote:
> > > 
> > >> @@ -410,6 +412,11 @@ swp_entry_t get_swap_page(void)
> > >>  	}
> > >>
> > >>  	nr_swap_pages++;
> > >> +	if (!out_of_swap_message_printed) {
> > >> +		out_of_swap_message_printed = 1;
> > >> +		printk(KERN_WARNING "All of swap is in use. Some pages "
> > >> +			"cannot be swapped out.\n");
> > >> +	}
> > >>  noswap:
> > >>  	spin_unlock(&swap_lock);
> > >>  	return (swp_entry_t) {0};
> > >> Index: linux-2.6/mm/vmscan.c
> > >> ===================================================================
> > >> --- linux-2.6.orig/mm/vmscan.c	2009-05-26 09:06:03.000000000 -0500
> > >> +++ linux-2.6/mm/vmscan.c	2009-05-26 09:20:30.000000000 -0500
> > >> @@ -1945,6 +1945,15 @@ out:
> > >>  		goto loop_again;
> > >>  	}
> > >>
> > >> +	/*
> > >> +	 * If we had an out of swap condition but things have improved then
> > >> +	 * reset the flag so that we print the message again when we run
> > >> +	 * out of swap again.
> > >> +	 */
> > >> +#ifdef CONFIG_SWAP
> > >> +	if (out_of_swap_message_printed && !vm_swap_full())
> > >> +		out_of_swap_message_printed = 0;
> > >> +#endif
> > >>  	return sc.nr_reclaimed;
> > >>  }
> > > 
> > > I still worry that there may be usage patterns which will result in
> > > this message coming out many times.
> > 
> > and using printk_ratelimit() or printk_timed_ratelimit() would be OK or not?
> 
> Well...  it would help.  We'd then get the same thing in the logs
> thousands of times rather than hundreds of thousands of times.
> 
> 
> But what's wrong with printing the thing just once, and not printing it
> again until after someone ran swapon or swapoff?  I think that matches up
> with the operator's actions pretty closely?
> 
IMHO, when the system is used every day without reboot and shared by users,
following behavior can be shown.

Monday   : UserA uses.
Tuesday  : UserA uses
Wednesday: UserA uses and near to swap full.
Thursday : UserB uses
Friday   : UserB uses and near to swap full.

If the appliation can be changed while the system is alive, multiple message is
not very bad. And...I don't think swapon/swapoff is usual operation for users.

Anyway, I think vm_swap_full() does all necessary work as Christoph explained in
other thread.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

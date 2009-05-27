Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D24386B005D
	for <linux-mm@kvack.org>; Tue, 26 May 2009 20:43:19 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R0hwSw003380
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 May 2009 09:43:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 22B3445DE5D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 09:43:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F12FD45DD79
	for <linux-mm@kvack.org>; Wed, 27 May 2009 09:43:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C3C77E38009
	for <linux-mm@kvack.org>; Wed, 27 May 2009 09:43:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E748E38004
	for <linux-mm@kvack.org>; Wed, 27 May 2009 09:43:57 +0900 (JST)
Date: Wed, 27 May 2009 09:42:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-Id: <20090527094224.67cace20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0905261022170.7242@gentwo.org>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
	<20090524144056.0849.A69D9226@jp.fujitsu.com>
	<4A1A057A.3080203@oracle.com>
	<20090526032934.GC9188@linux-sh.org>
	<alpine.DEB.1.10.0905261022170.7242@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Randy Dunlap <randy.dunlap@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009 10:23:36 -0400 (EDT)
Christoph Lameter <cl@linux.com> wrote:

> 
> Subject: Warn if we run out of swap space
> 
> Running out of swap space means that the evicton of anonymous pages may no longer
> be possible which can lead to OOM conditions.
> 
> Print a warning when swap space first becomes exhausted.
> We do not use WARN_ON because that would perform a meaningless stack dump.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  include/linux/swap.h |    1 +
>  mm/swapfile.c        |    7 +++++++
>  mm/vmscan.c          |    9 +++++++++
>  3 files changed, 17 insertions(+)
> 
> Index: linux-2.6/mm/swapfile.c
> ===================================================================
> --- linux-2.6.orig/mm/swapfile.c	2009-05-22 14:03:37.000000000 -0500
> +++ linux-2.6/mm/swapfile.c	2009-05-26 09:11:52.000000000 -0500
> @@ -374,6 +374,8 @@ no_page:
>  	return 0;
>  }
> 
> +int out_of_swap_message_printed = 0;
> +
>  swp_entry_t get_swap_page(void)
>  {
>  	struct swap_info_struct *si;
> @@ -410,6 +412,11 @@ swp_entry_t get_swap_page(void)
>  	}
> 
>  	nr_swap_pages++;
> +	if (!out_of_swap_message_printed) {
> +		out_of_swap_message_printed = 1;
> +		printk(KERN_WARNING "All of swap is in use. Some pages "
> +			"cannot be swapped out.\n");
> +	}
>  noswap:
>  	spin_unlock(&swap_lock);
BTW, hmm

Isn't this should be
==
noswap:
	if (total_swap_pages && !out_of_swap_message_printed) {
		....
	}
==

?
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

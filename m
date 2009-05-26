Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D45EF6B005C
	for <linux-mm@kvack.org>; Tue, 26 May 2009 16:15:33 -0400 (EDT)
Date: Tue, 26 May 2009 13:15:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-Id: <20090526131540.70fd410a.akpm@linux-foundation.org>
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
Cc: lethal@linux-sh.org, randy.dunlap@oracle.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, pavel@ucw.cz, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009 10:23:36 -0400 (EDT)
Christoph Lameter <cl@linux.com> wrote:

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
>  	return (swp_entry_t) {0};
> Index: linux-2.6/mm/vmscan.c
> ===================================================================
> --- linux-2.6.orig/mm/vmscan.c	2009-05-26 09:06:03.000000000 -0500
> +++ linux-2.6/mm/vmscan.c	2009-05-26 09:20:30.000000000 -0500
> @@ -1945,6 +1945,15 @@ out:
>  		goto loop_again;
>  	}
> 
> +	/*
> +	 * If we had an out of swap condition but things have improved then
> +	 * reset the flag so that we print the message again when we run
> +	 * out of swap again.
> +	 */
> +#ifdef CONFIG_SWAP
> +	if (out_of_swap_message_printed && !vm_swap_full())
> +		out_of_swap_message_printed = 0;
> +#endif
>  	return sc.nr_reclaimed;
>  }

I still worry that there may be usage patterns which will result in
this message coming out many times.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

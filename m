Message-ID: <46B23666.3020205@redhat.com>
Date: Thu, 02 Aug 2007 15:54:14 -0400
From: Chuck Ebbert <cebbert@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] balance_dirty_pages - exit loop when no more pages	available
References: <1185901890.3133.33.camel@castor.rsk.org>
In-Reply-To: <1185901890.3133.33.camel@castor.rsk.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: richard kennedy <richard@rsk.demon.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/31/2007 01:11 PM, richard kennedy wrote:

Peter, did you see this?

> exit loop in balance_dirty_pages when no more pages available to write
> 
> On a bdi that has very little traffic balance_dirty_pages can loop
> needlessly waiting until do_writepages has written enough pages.
> 
> do_writepages will return encountered_congestion==0 && nr_to_write > 0 
> when it has completed a pass but did not find enough pages available to
> write. balance_dirty_pages ignores this and keeps looping until a total
> of chunk pages was written. 
> 
> this patch adds an extra exit condition to break out of the loop in this
> case. 
> 
> I've tested this on my amd64 desktop, and I also have a version of this
> patch that includes a printk and a test case that occasionally does
> trigger this condition.  
> 
> Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
> 
> ------
> --- linux-2.6.22.1/mm/page-writeback.c.orig	2007-07-30 16:36:09.000000000 +0100
> +++ linux-2.6.22.1/mm/page-writeback.c	2007-07-31 16:26:43.000000000 +0100
> @@ -250,6 +250,8 @@ static void balance_dirty_pages(struct a
>  			pages_written += write_chunk - wbc.nr_to_write;
>  			if (pages_written >= write_chunk)
>  				break;		/* We've done our duty */
> +			if (!wbc.encountered_congestion && wbc.nr_to_write > 0)
> +				break;	/* didn't find enough to do */
>  		}
>  		congestion_wait(WRITE, HZ/10);
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

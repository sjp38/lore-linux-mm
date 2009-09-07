Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B65E76B0095
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 06:06:30 -0400 (EDT)
Subject: Re: [RFC PATCH] v2 mm: balance_dirty_pages.  reduce calls to
 global_page_state to reduce cache references
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <20090906035537.GA16063@localhost>
References: <1252062330.2271.61.camel@castor>
	 <20090906035537.GA16063@localhost>
Content-Type: text/plain
Date: Mon, 07 Sep 2009 11:06:26 +0100
Message-Id: <1252317986.2348.15.camel@castor>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "chris.mason" <chris.mason@oracle.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2009-09-06 at 11:55 +0800, Wu Fengguang wrote:
> On Fri, Sep 04, 2009 at 07:05:30PM +0800, Richard Kennedy wrote:
> > Reducing the number of times balance_dirty_pages calls global_page_state
> > reduces the cache references and so improves write performance on a
> > variety of workloads.
> > 
> > 'perf stats' of simple fio write tests shows the reduction in cache
> > access.
> > Where the test is fio 'write,mmap,600Mb,pre_read' on AMD AthlonX2 with
> > 3Gb memory (dirty_threshold approx 600 Mb)
> > running each test 10 times, dropping the fasted & slowest values then
> > taking 
> > the average & standard deviation
> > 
> > 		average (s.d.) in millions (10^6)
> > 2.6.31-rc8	648.6 (14.6)
> > +patch		620.1 (16.5)
> > 
> > Achieving this reduction is by dropping clip_bdi_dirty_limit as it  
> > rereads the counters to apply the dirty_threshold and moving this check
> > up into balance_dirty_pages where it has already read the counters.
> > 
> > Also by rearrange the for loop to only contain one copy of the limit
> > tests allows the pdflush test after the loop to use the local copies of
> > the counters rather than rereading them.
> > 
> > In the common case with no throttling it now calls global_page_state 5
> > fewer times and bdi_stat 2 fewer.
> > 
> > This version includes the changes suggested by 
> > Wu Fengguang <fengguang.wu@intel.com>
> 
> It seems that an redundant pages_written test can be reduced by
> 
> --- linux.orig/mm/page-writeback.c	2009-09-06 11:44:39.000000000 +0800
> +++ linux/mm/page-writeback.c	2009-09-06 11:44:42.000000000 +0800
> @@ -526,10 +526,6 @@ static void balance_dirty_pages(struct a
>  		    (background_thresh + dirty_thresh) / 2)
>  			break;
>  
> -		/* done enough? */
> -		if (pages_written >= write_chunk)
> -			break;
> -
>  		if (!bdi->dirty_exceeded)
>  			bdi->dirty_exceeded = 1;
>  
> @@ -547,7 +543,7 @@ static void balance_dirty_pages(struct a
>  			pages_written += write_chunk - wbc.nr_to_write;
>  			/* don't wait if we've done enough */
>  			if (pages_written >= write_chunk)
> -				continue;
> +				break;
>  		}
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  	}
> 
> Otherwise the patch looks good to me. Thank you for the nice work!
> 
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> 
Thank you.

I'll give your suggestion a try & run some tests. I think you're right
it should be better. Not re-reading the global counters again should be
of some benefit!
regards
Richard


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 58DC66B0032
	for <linux-mm@kvack.org>; Sun, 18 Aug 2013 21:58:07 -0400 (EDT)
Message-ID: <52117BED.7000909@cn.fujitsu.com>
Date: Mon, 19 Aug 2013 09:59:09 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: readahead: make context readahead more conservative
References: <20130808085418.GA23970@localhost>
In-Reply-To: <20130808085418.GA23970@localhost>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tao Ma <tm@tao.ma>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi, everyone

On Thu, 8 Aug 2013 16:54:18 +0800, Fengguang Wu wrote:
> This helps performance on moderately dense random reads on SSD.
> 
> Transaction-Per-Second numbers provided by Taobao:
> 
> 		QPS	case
> 		-------------------------------------------------------
> 		7536	disable context readahead totally
> w/ patch:	7129	slower size rampup and start RA on the 3rd read
> 		6717	slower size rampup
> w/o patch:	5581	unmodified context readahead
> 
> Before, readahead will be started whenever reading page N+1 when it
> happen to read N recently. After patch, we'll only start readahead
> when *three* random reads happen to access pages N, N+1, N+2. The
> probability of this happening is extremely low for pure random reads,
> unless they are very dense, which actually deserves some readahead.
> 
> Also start with a smaller readahead window. The impact to interleaved
> sequential reads should be small, because for a long run stream, the
> the small readahead window rampup phase is negletable.
> 
> The context readahead actually benefits clustered random reads on HDD
> whose seek cost is pretty high. However as SSD is increasingly used
> for random read workloads it's better for the context readahead to
> concentrate on interleaved sequential reads.
> 
> Another SSD rand read test from Miao
> 
>         # file size:        2GB
>         # read IO amount: 625MB
>         sysbench --test=fileio          \
>                 --max-requests=10000    \
>                 --num-threads=1         \
>                 --file-num=1            \
>                 --file-block-size=64K   \
>                 --file-test-mode=rndrd  \
>                 --file-fsync-freq=0     \
>                 --file-fsync-end=off    run
> 
> shows the performance of btrfs grows up from 69MB/s to 121MB/s,
> ext4 from 104MB/s to 121MB/s.

I did the same test on the hard disk recently,
for btrfs, there is ~5% regression(10.65MB/s -> 10.09MB/s),
for ext4, the performance grows up a bit.(9.98MB/s -> 10.04MB/s).
(I run the test for 4 times, and the above result is the average of the test.)

Any comment?

Thanks
Miao

> 
> Tested-by: Tao Ma <tm@tao.ma>
> Tested-by: Miao Xie <miaox@cn.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/readahead.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> --- linux-next.orig/mm/readahead.c	2013-08-08 16:21:29.675286154 +0800
> +++ linux-next/mm/readahead.c	2013-08-08 16:21:33.851286019 +0800
> @@ -371,10 +371,10 @@ static int try_context_readahead(struct
>  	size = count_history_pages(mapping, ra, offset, max);
>  
>  	/*
> -	 * no history pages:
> +	 * not enough history pages:
>  	 * it could be a random read
>  	 */
> -	if (!size)
> +	if (size <= req_size)
>  		return 0;
>  
>  	/*
> @@ -385,8 +385,8 @@ static int try_context_readahead(struct
>  		size *= 2;
>  
>  	ra->start = offset;
> -	ra->size = get_init_ra_size(size + req_size, max);
> -	ra->async_size = ra->size;
> +	ra->size = min(size + req_size, max);
> +	ra->async_size = 1;
>  
>  	return 1;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

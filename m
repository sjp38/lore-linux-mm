Date: Thu, 05 Jun 2008 11:23:08 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] page reclaim throttle v7
In-Reply-To: <20080605110637.d50af953.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080605021211.871673550@jp.fujitsu.com> <20080605110637.d50af953.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080605110925.9C29.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi kame-san,

> I like this series and I'd like to support this under memcg when
> this goes to mainline. (it seems better to test this for a while
> before adding some memcg-related changes.)
> 
> Then, please give me inputs.
> What do you think do I have to do for supporting this in memcg ?
> Handling the case of scan_global_lru(sc)==false is enough ?

my patch have 2 improvement.
1. ristrict reclaiming parallerism of #task (throttle)
2. reclaiming cut off if other task already freed enough memory.

we already consider #1 on memcg and works well.
but we doesn't support #2 on memcg because balbir-san's said
"memcg doesn't need it".

if you need improvement of #2, please change blow portion of my patch.

> +	/* reclaim still necessary? */
> +	if (scan_global_lru(sc) &&
> +	    freed - sc->was_freed >= threshold) {
> +		if (zone_watermark_ok(zone, sc->order, zone->pages_high,
> +				      gfp_zone(sc->gfp_mask), 0)) {
> +			ret = -EAGAIN;
> +			goto out;
> +		}
> +		sc->was_freed = freed;
> +	}
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

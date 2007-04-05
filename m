Date: Thu, 5 Apr 2007 15:57:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/12] mm: page_alloc_wait
Message-Id: <20070405155743.91380f00.akpm@linux-foundation.org>
In-Reply-To: <20070405174320.129577639@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
	<20070405174320.129577639@programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@programming.kicks-ass.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

On Thu, 05 Apr 2007 19:42:19 +0200
root@programming.kicks-ass.net wrote:

> Introduce a mechanism to wait on free memory.
> 
> Currently congestion_wait() is abused to do this.

Such a very small explanation for such a terrifying change.

> ...
>
> --- linux-2.6-mm.orig/mm/vmscan.c	2007-04-05 16:29:46.000000000 +0200
> +++ linux-2.6-mm/mm/vmscan.c	2007-04-05 16:29:49.000000000 +0200
> @@ -1436,6 +1436,7 @@ static int kswapd(void *p)
>  		finish_wait(&pgdat->kswapd_wait, &wait);
>  
>  		balance_pgdat(pgdat, order);
> +		page_alloc_ok();
>  	}
>  	return 0;
>  }

For a start, we don't know that kswapd freed pages which are in a suitable
zone.  And we don't know that kswapd freed pages which are in a suitable
cpuset.

congestion_wait() is similarly ignorant of the suitability of the pages,
but the whole idea behind congestion_wait is that it will throttle page
allocators to some speed which is proportional to the speed at which the IO
systems can retire writes - view it as a variable-speed polling operation,
in which the polling frequency goes up when the IO system gets faster. 
This patch changes that philosophy fundamentally.  That's worth more than a
2-line changelog.

Also, there might be situations in which kswapd gets stuck in some dark
corner.  Perhaps the process which is waiting in the page allocator holds
filesystem locks which kswapd is blocked on.  Or kswapd might be blocked on
a particular request queue, or a dead NFS server or something.  The timeout
will save us, but things will be slow.

There could be other problems too, dunno - this stuff is tricky.  Why are
you changing it, what problems are being solved, etc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

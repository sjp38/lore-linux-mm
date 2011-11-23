Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 45D3D6B016A
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 13:33:57 -0500 (EST)
Date: Wed, 23 Nov 2011 10:33:44 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: slub: use irqsafe_cpu_cmpxchg for put_cpu_partial
In-Reply-To: <alpine.DEB.2.00.1111230907330.16139@router.home>
Message-ID: <alpine.DEB.2.01.1111231025180.8000@trent.utfs.org>
References: <20111121131531.GA1679@x4.trippels.de> <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121161036.GA1679@x4.trippels.de> <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121173556.GA1673@x4.trippels.de> <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121185215.GA1673@x4.trippels.de> <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop> <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
 <alpine.DEB.2.00.1111212105330.19606@router.home> <1321948113.27077.24.camel@edumazet-laptop> <1321999085.14573.2.camel@pasglop> <alpine.DEB.2.01.1111221511070.8000@trent.utfs.org> <1322007501.14573.15.camel@pasglop> <alpine.DEB.2.01.1111222145470.8000@trent.utfs.org>
 <CAOJsxLGWTRuwQ04Mg26fNhZEmo7yVXG5vSZgF7Q5GESCk65odA@mail.gmail.com> <alpine.DEB.2.00.1111230907330.16139@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Eric Dumazet <eric.dumazet@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>

On Wed, 23 Nov 2011 at 09:14, Christoph Lameter wrote:
> I think he only tested the patch that he showed us.

Yes, that's the (only) one I tested so far. I did some overnight testing 
(rsync'ing to the external disk again) for 6hrs and ran "slabinfo" every 
30s during the run: http://nerdbynature.de/bits/3.2.0-rc1/oops/slabinfo-1.txt.xz

The machine is still up & running. So for me, your patch fixes it!

  Tested-by: Christian Kujau <lists@nerdbynature.de>

Thanks!
Christian.

> Subject: slub: use irqsafe_cpu_cmpxchg for put_cpu_partial
> 
> The cmpxchg must be irq safe. The fallback for this_cpu_cmpxchg only
> disables preemption which results in per cpu partial page operation
> potentially failing on non x86 platforms.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  mm/slub.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2011-11-23 09:10:48.000000000 -0600
> +++ linux-2.6/mm/slub.c	2011-11-23 09:10:57.000000000 -0600
> @@ -1969,7 +1969,7 @@ int put_cpu_partial(struct kmem_cache *s
>  		page->pobjects = pobjects;
>  		page->next = oldpage;
> 
> -	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
> +	} while (irqsafe_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
>  	stat(s, CPU_PARTIAL_FREE);
>  	return pobjects;
>  }
> 

-- 
BOFH excuse #43:

boss forgot system password

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

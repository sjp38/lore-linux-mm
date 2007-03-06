Date: Tue, 6 Mar 2007 07:54:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC} memory unplug patchset prep [2/16] gathering
 alloc_zeroed_user_highpage()
In-Reply-To: <20070306134334.e01e41bf.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0703060017390.21900@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
 <20070306134334.e01e41bf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, KAMEZAWA Hiroyuki wrote:

> Definitions of alloc_zeroed_user_highpage() is scattered.
> This patch gathers them to linux/highmem.h
> 
> To do so, added CONFIG_ARCH_HAS_PREZERO_USERPAGE and
> CONFIG_ARCH_HAS_FLUSH_USERNEWZEROPAGE.
> 

Previous to this patch, __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE was never 
configurable by the user and was totally dependant on the architecture, 
which seems appropriate.  Are there cases when a user would actually 
prefer to disable the new CONFIG_ARCH_HAS_PREZERO_USERPAGE to avoid 
__GFP_ZERO allocations?

> Index: devel-tree-2.6.20-mm2/include/linux/highmem.h
> ===================================================================
> --- devel-tree-2.6.20-mm2.orig/include/linux/highmem.h
> +++ devel-tree-2.6.20-mm2/include/linux/highmem.h
> @@ -60,8 +60,22 @@ static inline void clear_user_highpage(s
>  	/* Make sure this page is cleared on other CPU's too before using it */
>  	smp_wmb();
>  }
> +#ifndef CONFIG_ARCH_HAS_FLUSH_USER_NEWZEROPAGE
> +#define flush_user_newzeroapge(page)	do{}while(0);
> +#endif
>  

Well, I guess this supports my point.  It doesn't appear as it was ever 
tested in disabling __GFP_ZERO allocations because 
flush_user_newzeropage() is misspelled above so it wouldn't even compile.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

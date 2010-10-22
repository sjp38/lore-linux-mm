Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1CEFB6B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 23:21:48 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9M3Ljdb010957
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 Oct 2010 12:21:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D0BB45DE4F
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:21:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 833A345DE4E
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:21:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 694CD1DB8013
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:21:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 247F61DB8012
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:21:45 +0900 (JST)
Date: Fri, 22 Oct 2010 12:16:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] do_migrate_range: exit loop if not_managed is true.
Message-Id: <20101022121610.2c380b0b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287667701-8081-2-git-send-email-lliubbo@gmail.com>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
	<1287667701-8081-2-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, fengguang.wu@intel.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010 21:28:20 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> If not_managed is true all pages will be putback to lru, so
> break the loop earlier to skip other pages isolate.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

please don't skip dump_page().

-Kame

> ---
>  mm/memory_hotplug.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d4e940a..4f72184 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -709,15 +709,17 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  					    page_is_file_cache(page));
>  
>  		} else {
> -			/* Becasue we don't have big zone->lock. we should
> -			   check this again here. */
> -			if (page_count(page))
> -				not_managed++;
>  #ifdef CONFIG_DEBUG_VM
>  			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
>  			       pfn);
>  			dump_page(page);
>  #endif
> +			/* Becasue we don't have big zone->lock. we should
> +			   check this again here. */
> +			if (page_count(page)) {
> +				not_managed++;
> +				break;
> +			}
>  		}
>  	}
>  	ret = -EBUSY;
> -- 
> 1.5.6.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

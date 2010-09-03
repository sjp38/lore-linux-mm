Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 631716B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 23:15:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o833FXOx021343
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Sep 2010 12:15:33 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9222E45DE4D
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 12:15:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B67945DE6E
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 12:15:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 39E37E38001
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 12:15:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD3271DB8037
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 12:15:32 +0900 (JST)
Date: Fri, 3 Sep 2010 12:10:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/2 v2] Make is_mem_section_removable more conformable with
 offlining code
Message-Id: <20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100902150554.GE10265@tiehlicka.suse.cz>
References: <20100901121951.GC6663@tiehlicka.suse.cz>
	<20100901124138.GD6663@tiehlicka.suse.cz>
	<20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902082829.GA10265@tiehlicka.suse.cz>
	<20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902092454.GA17971@tiehlicka.suse.cz>
	<AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
	<20100902131855.GC10265@tiehlicka.suse.cz>
	<AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
	<20100902143939.GD10265@tiehlicka.suse.cz>
	<20100902150554.GE10265@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Sep 2010 17:05:54 +0200
Michal Hocko <mhocko@suse.cz> wrote:

>  extern int mem_online_node(int nid);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index a4cfcdc..2b736ed 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -569,16 +569,25 @@ out:
>  EXPORT_SYMBOL_GPL(add_memory);
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> +
>  /*
> - * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy
> - * set and the size of the free page is given by page_order(). Using this,
> - * the function determines if the pageblock contains only free pages.
> - * Due to buddy contraints, a free page at least the size of a pageblock will
> - * be located at the start of the pageblock
> + * A free or LRU pages block are removable
> + * Do not use MIGRATE_MOVABLE because it can be insufficient and
> + * other MIGRATE types are tricky.
>   */
> -static inline int pageblock_free(struct page *page)
> -{
> -	return PageBuddy(page) && page_order(page) >= pageblock_order;
> +bool is_page_removable(struct page *page)
> +{
> +	int page_block = 1 << pageblock_order;
> +	while (page_block > 0) {
> +		if (PageBuddy(page)) {
> +			page_block -= page_order(page);
> +		} else if (PageLRU(page))
> +			page_block--;
> +		else 
> +			return false;
> +	}

still seems wrong..."page" pointer should be updated.

Ok, here is my patch in reply to this mail. (changed the subject as v2.)

1. bugfix for current code.
2. show precise removable information.

Tested and seems to work well.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

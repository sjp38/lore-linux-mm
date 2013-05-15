Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 43EAF6B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 19:20:56 -0400 (EDT)
Date: Wed, 15 May 2013 16:20:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 3/4] memory_hotplug: use pgdat_resize_lock() in
 online_pages()
Message-Id: <20130515162054.1c76200ee9514ca8a2054628@linux-foundation.org>
In-Reply-To: <1368486787-9511-4-git-send-email-cody@linux.vnet.ibm.com>
References: <1368486787-9511-1-git-send-email-cody@linux.vnet.ibm.com>
	<1368486787-9511-4-git-send-email-cody@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 13 May 2013 16:13:06 -0700 Cody P Schafer <cody@linux.vnet.ibm.com> wrote:

> mmzone.h documents node_size_lock (which pgdat_resize_lock() locks) as
> follows:
> 
>         * Must be held any time you expect node_start_pfn, node_present_pages
>         * or node_spanned_pages stay constant.  [...]

Yeah, I suppose so.  Although no present code sites actually do that.

> So actually hold it when we update node_present_pages in online_pages().
> 
> ...
>
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -915,6 +915,7 @@ static void node_states_set_node(int node, struct memory_notify *arg)
>  
>  int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
>  {
> +	unsigned long flags;
>  	unsigned long onlined_pages = 0;
>  	struct zone *zone;
>  	int need_zonelists_rebuild = 0;
> @@ -993,7 +994,11 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  
>  	zone->managed_pages += onlined_pages;
>  	zone->present_pages += onlined_pages;
> +
> +	pgdat_resize_lock(zone->zone_pgdat, &flags);
>  	zone->zone_pgdat->node_present_pages += onlined_pages;
> +	pgdat_resize_unlock(zone->zone_pgdat, &flags);
> +
>  	if (onlined_pages) {
>  		node_states_set_node(zone_to_nid(zone), &arg);
>  		if (need_zonelists_rebuild)

afaict the only benefits of making this change are

a) so that code which does

	a = p->node_present_pages;
	...
	b = p->node_present_pages;

   can ensure that `a' and `b' are equal, by taking pgdat_resize_lock().

   Which is somewhat odd, and

b) to make the comment truthful ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

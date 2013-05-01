Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 7D2BC6B01F4
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:30:55 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id 15so1022660pdi.29
        for <linux-mm@kvack.org>; Wed, 01 May 2013 15:30:54 -0700 (PDT)
Date: Wed, 1 May 2013 15:30:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] memory_hotplug: use pgdat_resize_lock() when updating
 node_present_pages
In-Reply-To: <1367446635-12856-5-git-send-email-cody@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1305011530050.8804@chino.kir.corp.google.com>
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-5-git-send-email-cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 1 May 2013, Cody P Schafer wrote:

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index a221fac..0bdca10 100644
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

Why?  You can't get a partial read of a word-sized data structure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id DD3676B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:41:27 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id jh10so511706pab.10
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 13:41:27 -0700 (PDT)
Date: Wed, 10 Apr 2013 13:41:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Simplify for_each_populated_zone()
In-Reply-To: <20130410202727.20368.29222.stgit@srivatsabhat.in.ibm.com>
Message-ID: <alpine.DEB.2.02.1304101339260.25932@chino.kir.corp.google.com>
References: <20130410202727.20368.29222.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 11 Apr 2013, Srivatsa S. Bhat wrote:

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ede2749..2489042 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -948,9 +948,7 @@ extern struct zone *next_zone(struct zone *zone);
>  	for (zone = (first_online_pgdat())->node_zones; \
>  	     zone;					\
>  	     zone = next_zone(zone))			\
> -		if (!populated_zone(zone))		\
> -			; /* do nothing */		\
> -		else
> +		if (populated_zone(zone))
>  
>  static inline struct zone *zonelist_zone(struct zoneref *zoneref)
>  {

Nack, it's written the way it is to avoid ambiguous else statements 
following it.  People do things like

	for_each_populated_zone(z)
		if (...) {
		} else (...) {
		}

and it's now ambiguous (and should warn with -Wparentheses).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

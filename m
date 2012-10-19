Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 9CA066B0069
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:55:01 -0400 (EDT)
Date: Fri, 19 Oct 2012 09:54:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Simplify for_each_populated_zone()
Message-ID: <20121019135454.GJ31863@cmpxchg.org>
References: <20121019105546.9704.93446.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121019105546.9704.93446.stgit@srivatsabhat.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@gmail.com, akpm@linux-foundation.org

On Fri, Oct 19, 2012 at 04:25:47PM +0530, Srivatsa S. Bhat wrote:
> Move the check for populated_zone() to the control statement of the
> 'for' loop and get rid of the odd looking if/else block.
> 
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
> 
>  include/linux/mmzone.h |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 50aaca8..5bdf02e 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -913,11 +913,8 @@ extern struct zone *next_zone(struct zone *zone);
>  
>  #define for_each_populated_zone(zone)		        \
>  	for (zone = (first_online_pgdat())->node_zones; \
> -	     zone;					\
> -	     zone = next_zone(zone))			\
> -		if (!populated_zone(zone))		\
> -			; /* do nothing */		\
> -		else
> +	     zone && populated_zone(zone);		\
> +	     zone = next_zone(zone))

I don't think we want to /abort/ the loop when encountering an
unpopulated zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch 02/20] Use an indexed array for LRU variables
References: <20080304225157.573336066@redhat.com>
	<20080304225226.653954413@redhat.com>
Date: Wed, 05 Mar 2008 01:31:10 +0100
In-Reply-To: <20080304225226.653954413@redhat.com> (Rik van Riel's message of
	"Tue, 04 Mar 2008 17:51:59 -0500")
Message-ID: <87lk4yc8q9.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Hi Rik,

Rik van Riel <riel@redhat.com> writes:

> Index: linux-2.6.25-rc3-mm1/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.25-rc3-mm1.orig/include/linux/mmzone.h	2008-03-04 14:12:52.000000000 -0500
> +++ linux-2.6.25-rc3-mm1/include/linux/mmzone.h	2008-03-04 14:59:31.000000000 -0500
> @@ -80,8 +80,8 @@ struct zone_padding {
>  enum zone_stat_item {
>  	/* First 128 byte cacheline (assuming 64 bit words) */
>  	NR_FREE_PAGES,
> -	NR_INACTIVE,
> -	NR_ACTIVE,
> +	NR_INACTIVE,	/* must match order of LRU_[IN]ACTIVE */
> +	NR_ACTIVE,	/*  "     "     "   "       "         */
>  	NR_ANON_PAGES,	/* Mapped anonymous pages */
>  	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
>  			   only modified from process context */
> @@ -105,6 +105,13 @@ enum zone_stat_item {
>  #endif
>  	NR_VM_ZONE_STAT_ITEMS };

How about a #define LRU_STAT_BASE NR_INACTIVE ...

> Index: linux-2.6.25-rc3-mm1/include/linux/mm_inline.h
> ===================================================================
> --- linux-2.6.25-rc3-mm1.orig/include/linux/mm_inline.h	2007-07-08 19:32:17.000000000 -0400
> +++ linux-2.6.25-rc3-mm1/include/linux/mm_inline.h	2008-03-04 14:59:31.000000000 -0500
> @@ -1,40 +1,51 @@
>  static inline void
> +add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
> +{
> +	list_add(&page->lru, &zone->list[l]);
> +	__inc_zone_state(zone, NR_INACTIVE + l);

... in order to avoid using NR_INACTIVE in places like this?

(LRU_STAT_BASE is a bad name, I apologize)

Or perhaps a macro lru_stat (it's getting worse...) that yields the zone
stat index corresponding to the lru list type?  I think this would
increase readability.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

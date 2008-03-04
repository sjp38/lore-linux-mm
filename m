Date: Tue, 04 Mar 2008 19:46:04 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 12/21] No Reclaim LRU Infrastructure
In-Reply-To: <20080228192929.031646681@redhat.com>
References: <20080228192908.126720629@redhat.com> <20080228192929.031646681@redhat.com>
Message-Id: <20080304192441.1EA2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

sorry for late review.

> 
> Index: linux-2.6.25-rc2-mm1/mm/Kconfig
> ===================================================================
> --- linux-2.6.25-rc2-mm1.orig/mm/Kconfig	2008-02-19 16:23:09.000000000 -0500
> +++ linux-2.6.25-rc2-mm1/mm/Kconfig	2008-02-28 11:05:04.000000000 -0500
> @@ -193,3 +193,13 @@ config NR_QUICK
>  config VIRT_TO_BUS
>  	def_bool y
>  	depends on !ARCH_NO_VIRT_TO_BUS
> +
> +config NORECLAIM
> +	bool "Track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"
> +	depends on EXPERIMENTAL && 64BIT

as far as I remembered, somebody said CONFIG_NORECLAIM is easy confusable.
may be..

IMHO insert "lru" word is better.
example,

config NORECLAIM_LRU
	bool "Zone LRU of track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"
	depends on EXPERIMENTAL && 64BIT


> @@ -356,8 +380,10 @@ void release_pages(struct page **pages, 
>  				zone = pagezone;
>  				spin_lock_irqsave(&zone->lru_lock, flags);
>  			}
> -			VM_BUG_ON(!PageLRU(page));
> -			__ClearPageLRU(page);
> +			is_lru_page = PageLRU(page);
> +			VM_BUG_ON(!(is_lru_page));
> +			if (is_lru_page)
> +				__ClearPageLRU(page);
>  			del_page_from_lru(zone, page);
>  		}

it seems unnecessary change??


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

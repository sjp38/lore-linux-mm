Date: Wed, 14 Feb 2007 21:33:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/7] Logic to move mlocked pages
Message-Id: <20070214213321.0633d570.akpm@linux-foundation.org>
In-Reply-To: <20070215012510.5343.52706.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
	<20070215012510.5343.52706.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007 17:25:10 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> --- linux-2.6.20.orig/mm/migrate.c	2007-02-14 17:07:44.000000000 -0800
> +++ linux-2.6.20/mm/migrate.c	2007-02-14 17:08:54.000000000 -0800
> @@ -58,6 +58,13 @@
>  			else
>  				del_page_from_inactive_list(zone, page);
>  			list_add_tail(&page->lru, pagelist);
> +		} else
> +		if (PageMlocked(page)) {
> +			ret = 0;
> +			get_page(page);
> +			ClearPageMlocked(page);
> +			list_add_tail(&page->lru, pagelist);
> +			__dec_zone_state(zone, NR_MLOCK);
>  		}
>  		spin_unlock_irq(&zone->lru_lock);

argh.  Please change your scripts to use `diff -p'.

Why does whatever-funtion-this-is do the get_page() there?  Looks odd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

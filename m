Date: Fri, 17 Feb 2006 08:35:25 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] 4/4 Migration Cache - use for direct migration
In-Reply-To: <1140190651.5219.25.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0602170834310.30999@schroedinger.engr.sgi.com>
References: <1140190651.5219.25.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Feb 2006, Lee Schermerhorn wrote:

> Index: linux-2.6.16-rc3-mm1/mm/vmscan.c
> ===================================================================
> --- linux-2.6.16-rc3-mm1.orig/mm/vmscan.c	2006-02-15 10:50:59.000000000 -0500
> +++ linux-2.6.16-rc3-mm1/mm/vmscan.c	2006-02-15 10:51:09.000000000 -0500
> @@ -911,7 +911,12 @@ redo:
>  		 * preserved.
>  		 */
>  		if (PageAnon(page) && !PageSwapCache(page)) {
> -			if (!add_to_swap(page, GFP_KERNEL)) {
> +			if (!to) {
> +				if (!add_to_swap(page, GFP_KERNEL)) {
> +					rc = -ENOMEM;
> +					goto unlock_page;
> +				}
> +			} else if (add_to_migration_cache(page, GFP_KERNEL)) {
>  				rc = -ENOMEM;
>  				goto unlock_page;
>  			}

Hmmm.... maybe add another parameter to add_to_swap instead? This seems to 
be duplicating some code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

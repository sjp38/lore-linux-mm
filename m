Date: Tue, 4 Apr 2006 19:58:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 6/6] Swapless V1: Revise main migration logic
Message-Id: <20060404195820.4adc09d7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060404065810.24532.30027.sendpatchset@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
	<20060404065810.24532.30027.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, lhms-devel@lists.sourceforge.net, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Mon, 3 Apr 2006 23:58:10 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> New migration scheme
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.17-rc1/mm/migrate.c
> ===================================================================
> --- linux-2.6.17-rc1.orig/mm/migrate.c	2006-04-03 23:44:31.000000000 -0700
> +++ linux-2.6.17-rc1/mm/migrate.c	2006-04-03 23:48:02.000000000 -0700
> @@ -151,27 +151,21 @@ int migrate_page_remove_references(struc
>  	 * indicates that the page is in use or truncate has removed
>  	 * the page.
>  	 */
> -	if (!mapping || page_mapcount(page) + nr_refs != page_count(page))
> -		return -EAGAIN;
> +	if (!page->mapping ||
> +		page_mapcount(page) + nr_refs + !!mapping != page_count(page))
> +			return -EAGAIN;
>  
I think this hidden !!mapping refcnt is not easy to read.

How about modifying caller istead of callee ?

in migrate_page()
==
if (page->mapping) 
	rc = migrate_page_remove_reference(newpage, page, 2)
else
	rc = migrate_page_remove_reference(newpage, page, 1);
==

If you dislike this 'if', plz do as you like.

Thanks,
--Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: [1/5] follow_page: do not put_page if FOLL_GET not specified.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060523174349.10156.22044.sendpatchset@schroedinger.engr.sgi.com>
References: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
	 <20060523174349.10156.22044.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 23 May 2006 20:29:10 +0200
Message-Id: <1148408951.10561.10.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-05-23 at 10:43 -0700, Christoph Lameter wrote:
> follow: no put_page() if FOLL_GET not specified.
> 
> Seems that one of the side effects of the dirty pages patch in
> 2.6.17-rc4-mm3 is that follow_pages does a page_put if FOLL_GET is
> not set in the flags passed to it. This breaks sys_move_pages()
> page status determination.
> 
> Only put_page if we did a get_page() before.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

However, Andrew dropped the patches from -mm. I'll do a new series that
incorporates the suggestions from Hugh.

> Index: linux-2.6.17-rc4-mm3/mm/memory.c
> ===================================================================
> --- linux-2.6.17-rc4-mm3.orig/mm/memory.c	2006-05-22 18:03:32.280767264 -0700
> +++ linux-2.6.17-rc4-mm3/mm/memory.c	2006-05-23 10:01:48.917295988 -0700
> @@ -964,7 +964,7 @@ struct page *follow_page(struct vm_area_
>  			set_page_dirty(page);
>  		mark_page_accessed(page);
>  	}
> -	if (!(flags & FOLL_GET))
> +	if (!(flags & FOLL_GET) && (flags & FOLL_TOUCH))
>  		put_page(page);
>  	goto out;
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

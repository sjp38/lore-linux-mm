Date: Wed, 26 Nov 2003 12:20:36 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Clear dirty bits etc on compound frees
Message-Id: <20031126122036.6389c773.akpm@osdl.org>
In-Reply-To: <22420000.1069877625@[10.10.2.4]>
References: <22420000.1069877625@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-mm@kvack.org, guillaume@morinfr.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> Guillaume noticed this on s390 whilst writing a driver that used
> compound pages. Seems correct to me, I've tested it on i386 as
> well. The patch just makes us call free_pages_check for each element
> of a compound page.
> 
> diff -purN -X /home/mbligh/.diff.exclude virgin/mm/page_alloc.c clear_dirty/mm/page_alloc.c
> --- virgin/mm/page_alloc.c	2003-10-14 15:50:36.000000000 -0700
> +++ clear_dirty/mm/page_alloc.c	2003-11-26 10:36:04.000000000 -0800
> @@ -267,8 +267,11 @@ free_pages_bulk(struct zone *zone, int c
>  void __free_pages_ok(struct page *page, unsigned int order)
>  {
>  	LIST_HEAD(list);
> +	int i;
>  
>  	mod_page_state(pgfree, 1 << order);
> +	for (i = 0 ; i < (1 << order) ; ++i)
> +		free_pages_check(__FUNCTION__, page + i);

hmm.  How did the dirty bit get itself set?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

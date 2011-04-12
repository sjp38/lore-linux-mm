Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC778D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 06:29:58 -0400 (EDT)
Received: by bwz17 with SMTP id 17so7900653bwz.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 03:29:55 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 3/3] reuse __free_pages_exact() in __alloc_pages_exact()
References: <20110411220345.9B95067C@kernel> <20110411220348.D0280E4D@kernel>
Date: Tue, 12 Apr 2011 12:29:53 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vttl33xz3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <20110411220348.D0280E4D@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi
 Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Tue, 12 Apr 2011 00:03:48 +0200, Dave Hansen <dave@linux.vnet.ibm.com>  
wrote:
> diff -puN mm/page_alloc.c~reuse-free-exact mm/page_alloc.c
> --- linux-2.6.git/mm/page_alloc.c~reuse-free-exact	2011-04-11  
> 15:01:17.701822598 -0700
> +++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-11 15:01:17.713822594  
> -0700
> @@ -2338,14 +2338,11 @@ struct page *__alloc_pages_exact(gfp_t g
> 	page = alloc_pages(gfp_mask, order);
>  	if (page) {
> -		struct page *alloc_end = page + (1 << order);
> -		struct page *used = page + nr_pages;
> +		struct page *unused_start = page + nr_pages;
> +		int nr_unused = (1 << order) - nr_pages;

How about unsigned long?

> 		split_page(page, order);
> -		while (used < alloc_end) {
> -			__free_page(used);
> -			used++;
> -		}
> +		__free_pages_exact(unused_start, nr_unused);
>  	}
> 	return page;

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

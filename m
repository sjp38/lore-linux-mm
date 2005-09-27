Received: by nproxy.gmail.com with SMTP id x37so378946nfc
        for <linux-mm@kvack.org>; Tue, 27 Sep 2005 00:21:03 -0700 (PDT)
Message-ID: <2cd57c90050927002163f78269@mail.gmail.com>
Date: Tue, 27 Sep 2005 15:21:03 +0800
From: Coywolf Qi Hunt <coywolf@gmail.com>
Reply-To: Coywolf Qi Hunt <coywolf@gmail.com>
Subject: Re: [PATCH 7/9] try harder on large allocations
In-Reply-To: <433856B2.8030906@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <4338537E.8070603@austin.ibm.com> <433856B2.8030906@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Mike Kravetz <kravetz@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On 9/27/05, Joel Schopp <jschopp@austin.ibm.com> wrote:
> Fragmentation avoidance patches increase our chances of satisfying high order
> allocations.  So this patch takes more than one iteration at trying to fulfill
> those allocations because unlike before the extra iterations are often useful.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Joel Schopp <jschopp@austin.ibm.com>
>
>
> Index: 2.6.13-joel2/mm/page_alloc.c
> ===================================================================
> --- 2.6.13-joel2.orig/mm/page_alloc.c   2005-09-21 11:13:14.%N -0500
> +++ 2.6.13-joel2/mm/page_alloc.c        2005-09-21 11:14:49.%N -0500
> @@ -944,7 +944,8 @@ __alloc_pages(unsigned int __nocast gfp_
>         int can_try_harder;
>         int did_some_progress;
>         int alloctype;
> -
> +       int highorder_retry = 3;
> +
>         alloctype = (gfp_mask & __GFP_RCLM_BITS);
>         might_sleep_if(wait);
>
> @@ -1090,7 +1091,14 @@ rebalance:
>                                 goto got_pg;
>                 }
>
> -               out_of_memory(gfp_mask, order);
> +               if (order < MAX_ORDER/2) out_of_memory(gfp_mask, order);

Shouldn't that be written in two lines?

> +               /*
> +                * Due to low fragmentation efforts, we should try a little
> +                * harder to satisfy high order allocations
> +                */
> +               if (order >= MAX_ORDER/2 && --highorder_retry > 0)
> +                       goto rebalance;
> +
>                 goto restart;
>         }

--
Coywolf Qi Hunt
http://sosdg.org/~coywolf/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

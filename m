Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A77156B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:57:43 -0400 (EDT)
Received: by dadv6 with SMTP id v6so1183912dad.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 20:57:43 -0700 (PDT)
Date: Tue, 20 Mar 2012 20:57:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC]swap: don't do discard if no discard option added
In-Reply-To: <4F68795E.9030304@kernel.org>
Message-ID: <alpine.LSU.2.00.1203202019140.1842@eggly.anvils>
References: <4F68795E.9030304@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Holger Kiehl <Holger.Kiehl@dwd.de>, "Martin K. Petersen" <martin.petersen@oracle.com>, linux-mm@kvack.org

On Tue, 20 Mar 2012, Shaohua Li wrote:
> 
> Even don't add discard option, swapon will do discard, this sounds buggy,
> especially when discard is slow or buggy.

It's not a bug in swapon, it's an intentional feature, made explicit in
commit 339944663273 "swap: discard while swapping only if SWAP_FLAG_DISCARD"
and in the swapon(2) manpage.  We were also careful in wording the swapon(8)
manpage and the comment on SWAP_FLAG_DISCARD in swap.h - too lawyerly ;-?

It appears to be a bug in the Vertex 2: I did receive one other such
report on a Vertex 2 fourteen months ago, and in the absence of further
reports, we decided to consider that user's drive defective.  I wonder
if Holger's drive is defective, or if it's true of all Vertex 2s, or
if it depends on the firmware revision, and a later revision fixes it.

If the latter (if there is a firmware revision which fixes it), then
I think it's clear that SWAP_FLAG_DISCARD should continue to behave
as it does at present, with discard at swapon independent of it.

Holger, do you have the latest firmware on this drive?
Have any other Vertex 2 users observed this behaviour?

I've seen no such problem with the original OCZ Vertex, nor with
their Vertex 3, nor with the Intel drives I've tried (and you
report no problem with FusionIO's, though no advantage either).

But if there's no good firmware for the Vertex 2, I'm not so sure
what to do: two reports in fourteen months, on a superseded drive -
is that strong enough to disable a feature which appeared to offer
some advantage on others?

Is there a lower level at which we could blacklist the Vertex 2
to disable driver support for its discard?

Hugh

> 
> Reported-by: Holger Kiehl <Holger.Kiehl@dwd.de>
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> ---
>  mm/swapfile.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux/mm/swapfile.c
> ===================================================================
> --- linux.orig/mm/swapfile.c	2012-03-20 20:11:59.222767526 +0800
> +++ linux/mm/swapfile.c	2012-03-20 20:13:25.362767387 +0800
> @@ -2105,7 +2105,7 @@ SYSCALL_DEFINE2(swapon, const char __use
>  			p->flags |= SWP_SOLIDSTATE;
>  			p->cluster_next = 1 + (random32() % p->highest_bit);
>  		}
> -		if (discard_swap(p) == 0 && (swap_flags & SWAP_FLAG_DISCARD))
> +		if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
>  			p->flags |= SWP_DISCARDABLE;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

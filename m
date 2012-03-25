Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 5EFF56B007E
	for <linux-mm@kvack.org>; Sun, 25 Mar 2012 15:17:02 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so6180309pbc.14
        for <linux-mm@kvack.org>; Sun, 25 Mar 2012 12:17:01 -0700 (PDT)
Date: Sun, 25 Mar 2012 12:16:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] Re: kswapd stuck using 100% CPU
In-Reply-To: <20120324102621.353114da@annuminas.surriel.com>
Message-ID: <alpine.LSU.2.00.1203251212050.1984@eggly.anvils>
References: <20120324130353.48f2e4c8@kryten> <20120324102621.353114da@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Anton Blanchard <anton@samba.org>, aarcange@redhat.com, mel@csn.ul.ie, akpm@linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sat, 24 Mar 2012, Rik van Riel wrote:
> 
> Only test compaction_suitable if the kernel is built with CONFIG_COMPACTION,
> otherwise the stub compaction_suitable function will always return
> COMPACT_SKIPPED and send kswapd into an infinite loop.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Reported-by: Anton Blanchard <anton@samba.org>

Thank you, Anton and Rik.  I never quite got around to investigating
why swapping had been nearly twice as slow with linux-next on my Aspire
One (with a relatively minimal config, omitting COMPACTION).  That was
the reason (one half of the HT cpu busy in kswapd), and this fixes it.

Tested-by: Hugh Dickins <hughd@google.com>

> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7658fd6..33c332b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2946,7 +2946,8 @@ out:
>  				continue;
>  
>  			/* Would compaction fail due to lack of free memory? */
> -			if (compaction_suitable(zone, order) == COMPACT_SKIPPED)
> +			if (COMPACTION_BUILD &&
> +			    compaction_suitable(zone, order) == COMPACT_SKIPPED)
>  				goto loop_again;
>  
>  			/* Confirm the zone is balanced for order-0 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

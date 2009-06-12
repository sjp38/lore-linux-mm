Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B136E6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:09:54 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:10:02 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
Message-ID: <20090612091002.GA32052@elte.hu>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>


* Pekka J Enberg <penberg@cs.helsinki.fi> wrote:

> index 3964d3c..6387c19 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1548,6 +1548,20 @@ new_slab:
>  		goto load_freelist;
>  	}
>  
> +	/*
> +	 * Lets not wait if we're booting up or suspending even if the user
> +	 * asks for it.
> +	 */
> +	if (system_state != SYSTEM_RUNNING)
> +		gfpflags &= ~__GFP_WAIT;

Hiding that bug like that is not particularly clean IMO. We should 
not let system_state hacks spread like that.

We emit a debug warning but dont crash, so all should be fine and 
the culprits can then be fixed, right?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [PATCH -mm 11/14] bootmem: respect goal more likely
References: <20080530194220.286976884@saeurebad.de>
	<20080530194739.417271003@saeurebad.de>
Date: Fri, 30 May 2008 22:16:56 +0200
In-Reply-To: <20080530194739.417271003@saeurebad.de> (Johannes Weiner's
	message of "Fri, 30 May 2008 21:42:31 +0200")
Message-ID: <87lk1rmts7.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Johannes Weiner <hannes@saeurebad.de> writes:

> The old node-agnostic code tried allocating on all nodes starting from
> the one with the lowest range.  alloc_bootmem_core retried without the
> goal if it could not satisfy it and so the goal was only respected at
> all when it happened to be on the first (lowest page numbers) node (or
> theoretically if allocations failed on all nodes before to the one
> holding the goal).
>
> Introduce a non-panicking helper that starts allocating from the node
> holding the goal and falls back only after all thes tries failed.
>
> Make all other allocation helpers benefit from this new helper.
>
> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
> CC: Ingo Molnar <mingo@elte.hu>
> CC: Yinghai Lu <yhlu.kernel@gmail.com>
> CC: Andi Kleen <andi@firstfloor.org>
> ---
>
>  mm/bootmem.c |   77 +++++++++++++++++++++++++++++++----------------------------
>  1 file changed, 41 insertions(+), 36 deletions(-)
>
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -487,11 +487,33 @@ find_block:
>  		memset(region, 0, size);
>  		return region;
>  	}
> +	return NULL;
> +}

Sorry, forgot to update ->last_success handling here.  Update coming soon.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

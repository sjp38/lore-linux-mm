Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 125656B0129
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 17:28:08 -0500 (EST)
Date: Fri, 17 Feb 2012 14:28:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix potentially derefencing uninitialized 'r'.
Message-Id: <20120217142806.07a97347.akpm@linux-foundation.org>
In-Reply-To: <1328257256-1296-1-git-send-email-geunsik.lim@gmail.com>
References: <1328257256-1296-1-git-send-email-geunsik.lim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geunsik Lim <geunsik.lim@gmail.com>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Fri,  3 Feb 2012 17:20:56 +0900
Geunsik Lim <geunsik.lim@gmail.com> wrote:

> struct memblock_region 'r' will not be initialized potentially
> because of while statement's condition in __next_mem_pfn_range()function.
> Initialize struct memblock_region data structure by default.
> 
> Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
> ---
>  mm/memblock.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 77b5f22..867f5a2 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -671,7 +671,7 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
>  				unsigned long *out_end_pfn, int *out_nid)
>  {
>  	struct memblock_type *type = &memblock.memory;
> -	struct memblock_region *r;
> +	struct memblock_region *r = &type->regions[*idx];
>  
>  	while (++*idx < type->cnt) {
>  		r = &type->regions[*idx];

The following `if' test prevents any such dereference.

Maybe you saw a compilation warning (I didn't).  If so,
unintialized_var() is one way of suppressing it.

A better way is to reorganise the code (nicely).  Often that option
isn't available.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

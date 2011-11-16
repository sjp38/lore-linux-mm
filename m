Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 093596B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 20:14:38 -0500 (EST)
Subject: Re: [patch]slub: add missed accounting
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <1320994454.22361.259.camel@sli10-conroe>
References: <1320994454.22361.259.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Nov 2011 09:24:21 +0800
Message-ID: <1321406661.22361.302.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>

looks I got Christoph's email address wrong, fixed it.

On Fri, 2011-11-11 at 14:54 +0800, Shaohua Li wrote:
> With per-cpu partial list, slab is added to partial list first and then moved
> to node list. The __slab_free() code path for add/remove_partial is almost
> deprecated(except for slub debug). But we forget to account add/remove_partial
> when move per-cpu partial pages to node list, so the statistics for such events
> are always 0. Add corresponding accounting.
> 
> This is against the patch "slub: use correct parameter to add a page to
> partial list tail"
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> ---
>  mm/slub.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2011-11-11 14:43:38.000000000 +0800
> +++ linux/mm/slub.c	2011-11-11 14:43:40.000000000 +0800
> @@ -1901,11 +1901,14 @@ static void unfreeze_partials(struct kme
>  			}
>  
>  			if (l != m) {
> -				if (l == M_PARTIAL)
> +				if (l == M_PARTIAL) {
>  					remove_partial(n, page);
> -				else
> +					stat(s, FREE_REMOVE_PARTIAL);
> +				} else {
>  					add_partial(n, page,
>  						DEACTIVATE_TO_TAIL);
> +					stat(s, FREE_ADD_PARTIAL);
> +				}
>  
>  				l = m;
>  			}
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

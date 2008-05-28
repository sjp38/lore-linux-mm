Message-ID: <483DB6F5.2030101@cs.helsinki.fi>
Date: Wed, 28 May 2008 22:48:05 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: Subject: Slab allocators: Remove kmem_cache_name() to fix invalid
 frees
References: <Pine.LNX.4.64.0805281032290.22637@schroedinger.engr.sgi.com> <1211997084.31329.155.camel@calx> <Pine.LNX.4.64.0805281121100.32755@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0805281121100.32755@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, David Miller <davem@davemloft.net>, acme <acme@redhat.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> A draft patch to allow anonymous caches follows. Allowing duplicate names
> would also be possible. Just need to deal with sysfs. Maybe generate a
> _x at the end?

Or a "cache-" prefix. I don't think we ought to allow duplicate names, 
though.

> Subject: slub: Support anonymous slabs
> 
> Slabs really do not need to have a name so one could pass NULL as a name. 
> The name is only relevant for sysfs support. There we need a unique name.
> Use the address of the kmem_cache structure as the name.
> 
> [Would output "" if debugging is one]
> 
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/slub.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-05-28 11:16:24.000000000 -0700
> +++ linux-2.6/mm/slub.c	2008-05-28 11:17:33.000000000 -0700
> @@ -4310,6 +4310,7 @@ static int sysfs_slab_add(struct kmem_ca
>  	int err;
>  	const char *name;
>  	int unmergeable;
> +	char buf[20];
>  
>  	if (slab_state < SYSFS)
>  		/* Defer until later */
> @@ -4322,8 +4323,13 @@ static int sysfs_slab_add(struct kmem_ca
>  		 * This is typically the case for debug situations. In that
>  		 * case we can catch duplicate names easily.
>  		 */
> -		sysfs_remove_link(&slab_kset->kobj, s->name);
> +		if (s->name)
> +			sysfs_remove_link(&slab_kset->kobj, s->name);
>  		name = s->name;
> +		if (!name) {
> +			sprintf(buf, "%p", s);
> +			name = buf;
> +		}

Perhaps add a comment here explaining why we're doing this?

Other than that, looks good to me. Please re-send with proper changelog 
from the original patch.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

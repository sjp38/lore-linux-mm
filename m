Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CCE836B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 06:11:12 -0400 (EDT)
Message-ID: <4FB37CC9.3060102@parallels.com>
Date: Wed, 16 May 2012 14:09:13 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] SL[AUO]B common code 8/9] slabs: list addition move to
 slab_common
References: <20120514201544.334122849@linux.com> <20120514201613.467708800@linux.com>
In-Reply-To: <20120514201613.467708800@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On 05/15/2012 12:15 AM, Christoph Lameter wrote:
> Move the code to append the new kmem_cache to the list of slab caches to
> the kmem_cache_create code in the shared code.
>
> This is possible now since the acquisition of the mutex was moved into
> kmem_cache_create().
>
> Signed-off-by: Christoph Lameter<cl@linux.com>
>
>
> ---
>   mm/slab.c        |    7 +++++--
>   mm/slab_common.c |    3 +++
>   mm/slub.c        |    2 --
>   3 files changed, 8 insertions(+), 4 deletions(-)
>
> Index: linux-2.6/mm/slab_common.c
> ===================================================================
> --- linux-2.6.orig/mm/slab_common.c	2012-05-14 08:39:27.859145830 -0500
> +++ linux-2.6/mm/slab_common.c	2012-05-14 08:39:29.827145790 -0500
> @@ -98,6 +98,9 @@ struct kmem_cache *kmem_cache_create(con
>
>   	s = __kmem_cache_create(name, size, align, flags, ctor);
>
> +	if (s&&  s->refcount == 1)
> +		list_add(&s->list,&slab_caches);
> +
>   oops:

I personally think that the refcount == 1 test is too fragile.
It happens to be true, and is likely to be true in the future, but there 
is no particular reason that is *has* to be true forever.

Also, the only reasons it exists, seems to be to go around the fact that 
the slab already adds the kmalloc caches to a list in a slightly 
different way. And there has to be cleaner ways to achieve that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

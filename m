Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 492236B0044
	for <linux-mm@kvack.org>; Mon, 21 May 2012 14:13:55 -0400 (EDT)
Date: Mon, 21 May 2012 13:13:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Common code 09/12] slabs: Extract a common function for
 kmem_cache_destroy
In-Reply-To: <4FBA0C2D.3000101@parallels.com>
Message-ID: <alpine.DEB.2.00.1205211312270.30649@router.home>
References: <20120518161906.207356777@linux.com> <20120518161932.147485968@linux.com> <4FBA0C2D.3000101@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On Mon, 21 May 2012, Glauber Costa wrote:

> Something doesn't smell right here. It seems that we're now closing the caches
> right away. That wasn't the case before, nor it should be: For aliases, we
> should only decrease the refcount.

Why not? The only thing that could be left pending are frees to the page
allocator. We can do those frees with just the kmem_cache structure
hanging on for awhile.

> So unless I am missing something, it seems to me the correct code would be:
>
> s->refcount--;
> if (!s->refcount)
>     return kmem_cache_close;
> return 0;
>
> And while we're on that, that makes the sequence list_del() -> if it fails ->
> list_add() in the common kmem_cache_destroy a bit clumsy. Aliases will be
> re-added to the list quite frequently. Not that it is a big problem, but
> still...

True but this is just an intermediate step. Ultimately the series will
move sysfs processing into slab_common.c and then this is going away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

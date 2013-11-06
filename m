Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E5AC36B00FE
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 14:54:34 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fb1so144651pad.37
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 11:54:34 -0800 (PST)
Received: from psmtp.com ([74.125.245.159])
        by mx.google.com with SMTP id yk3si223001pac.273.2013.11.06.11.54.24
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 11:54:33 -0800 (PST)
Date: Wed, 6 Nov 2013 20:54:17 +0100
From: Andreas Herrmann <andreas.herrmann@calxeda.com>
Subject: Re: [PATCH] mm/slub: Switch slub_debug kernel option to early_param
 to avoid boot panic
Message-ID: <20131106195417.GK5661@alberich>
References: <20131106184529.GB5661@alberich>
 <000001422ed8406b-14bef091-eee0-4e0e-bcdd-a8909c605910-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <000001422ed8406b-14bef091-eee0-4e0e-bcdd-a8909c605910-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Nov 06, 2013 at 02:16:33PM -0500, Christoph Lameter wrote:
> On Wed, 6 Nov 2013, Andreas Herrmann wrote:
> 
> > When I've used slub_debug kernel option (e.g.
> > "slub_debug=,skbuff_fclone_cache" or similar) on a debug session I've
> > seen a panic like:
> 
> Hmmm.. That looks like its due to some slabs not having names
> during early boot. kmem_cache_flags is called with NULL as a parameter.

That's because the slub_debug parameter is not evaluated before
kmem_cache_flags is called.

Older kernels didn't show this problem. I think the sequence of those
calls has changed. Not sure what patch set has made that change.

> Are you sure that this fixes the issue? Looks like the
> kmem_cache_flag function should fail regardless of how early you set it.
> 
> AFAICT the right fix would be:

That would avoid the panic but I guess it won't enable slub debugging.

However I'll test this.


Andreas

> Subject: slub: Handle NULL parameter in kmem_cache_flags
> 
> kmem_cache_flags may be called with NULL parameter during early boot.
> Skip the test in that case.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2013-10-15 13:55:44.000000000 -0500
> +++ linux/mm/slub.c	2013-11-06 13:09:21.810583134 -0600
> @@ -1217,7 +1217,7 @@ static unsigned long kmem_cache_flags(un
>  	/*
>  	 * Enable debugging if selected on the kernel commandline.
>  	 */
> -	if (slub_debug && (!slub_debug_slabs ||
> +	if (slub_debug && name && (!slub_debug_slabs ||
>  		!strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs))))
>  		flags |= slub_debug;
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

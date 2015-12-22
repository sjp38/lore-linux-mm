Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 04A1682F74
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 15:47:58 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p187so122506507wmp.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:47:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o124si45917933wmg.25.2015.12.22.12.47.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 12:47:56 -0800 (PST)
Subject: Re: [RFC][PATCH 1/7] mm/slab_common.c: Add common support for slab
 saniziation
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <1450755641-7856-2-git-send-email-laura@labbott.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5679B701.9040802@suse.cz>
Date: Tue, 22 Dec 2015 21:48:01 +0100
MIME-Version: 1.0
In-Reply-To: <1450755641-7856-2-git-send-email-laura@labbott.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <laura@labbott.name>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com, Mathias Krause <minipli@googlemail.com>

On 22.12.2015 4:40, Laura Abbott wrote:
> Each of the different allocators (SLAB/SLUB/SLOB) handles
> clearing of objects differently depending on configuration.
> Add common infrastructure for selecting sanitization levels
> (off, slow path only, partial, full) and marking caches as
> appropriate.
> 
> All credit for the original work should be given to Brad Spengler and
> the PaX Team.
> 
> Signed-off-by: Laura Abbott <laura@labbott.name>
>  
> +#ifdef CONFIG_SLAB_MEMORY_SANITIZE
> +#ifdef CONFIG_X86_64
> +#define SLAB_MEMORY_SANITIZE_VALUE       '\xfe'
> +#else
> +#define SLAB_MEMORY_SANITIZE_VALUE       '\xff'
> +#endif
> +enum slab_sanitize_mode {
> +	/* No sanitization */
> +	SLAB_SANITIZE_OFF = 0,
> +
> +	/* Partial sanitization happens only on the slow path */
> +	SLAB_SANITIZE_PARTIAL_SLOWPATH = 1,

Can you explain more about this variant? I wonder who might find it useful
except someone getting a false sense of security, but cheaper.
It sounds like wanting the cake and eat it too :)
I would be surprised if such IMHO half-solution existed in the original
PAX_MEMORY_SANITIZE too?

Or is there something that guarantees that the objects freed on hotpath won't
stay there for long so the danger of leak is low? (And what about
use-after-free?) It depends on further slab activity, no? (I'm not that familiar
with SLUB, but I would expect the hotpath there being similar to SLAB freeing
the object on per-cpu array_cache. But, it seems the PARTIAL_SLOWPATH is not
implemented for SLAB, so there might be some fundamental difference I'm missing.)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

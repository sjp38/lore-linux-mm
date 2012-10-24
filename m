Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 9E5746B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 04:56:27 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id hq7so192459wib.8
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 01:56:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350914737-4097-3-git-send-email-glommer@parallels.com>
References: <1350914737-4097-1-git-send-email-glommer@parallels.com>
	<1350914737-4097-3-git-send-email-glommer@parallels.com>
Date: Wed, 24 Oct 2012 11:56:25 +0300
Message-ID: <CAOJsxLHuQxZ8Hh_bhidaZRMqKssRc=h3RRPPPYD=unoJU-G4AA@mail.gmail.com>
Subject: Re: [PATCH 2/2] slab: move kmem_cache_free to common code
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Mon, Oct 22, 2012 at 5:05 PM, Glauber Costa <glommer@parallels.com> wrote:
> +/**
> + * kmem_cache_free - Deallocate an object
> + * @cachep: The cache the allocation was from.
> + * @objp: The previously allocated object.
> + *
> + * Free an object which was previously allocated from this
> + * cache.
> + */
> +void kmem_cache_free(struct kmem_cache *s, void *x)
> +{
> +       __kmem_cache_free(s, x);
> +       trace_kmem_cache_free(_RET_IP_, x);
> +}
> +EXPORT_SYMBOL(kmem_cache_free);

As Christoph mentioned, this is going to hurt performance. The proper
way to do this is to implement the *hook* in mm/slab_common.c and call
that from all the allocator specific kmem_cache_free() functions.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

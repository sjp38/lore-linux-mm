Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85A466B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:39:34 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id n2so92530911obo.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:39:34 -0700 (PDT)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id 6si10453833ion.85.2016.04.27.08.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 08:39:32 -0700 (PDT)
Date: Wed, 27 Apr 2016 10:39:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v4] mm: SLAB freelist randomization
In-Reply-To: <20160426161743.f831225a4efb3eb04debe402@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1604271027540.20042@east.gentwo.org>
References: <1461687670-47585-1-git-send-email-thgarnie@google.com> <20160426161743.f831225a4efb3eb04debe402@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Garnier <thgarnie@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kees Cook <keescook@chromium.org>, gthelen@google.com, labbott@fedoraproject.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 26 Apr 2016, Andrew Morton wrote:

> : CONFIG_FREELIST_RANDOM bugs me a bit - "freelist" is so vague.
> : CONFIG_SLAB_FREELIST_RANDOM would be better.  I mean, what Kconfig
> : identifier could be used for implementing randomisation in
> : slub/slob/etc once CONFIG_FREELIST_RANDOM is used up?
>
> but this pearl appeared to pass unnoticed.

Ok. lets add SLAB here and then use this option for the other allocators
as well.

> > +	/* If it fails, we will just use the global lists */
> > +	cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), GFP_KERNEL);
> > +	if (!cachep->random_seq)
> > +		return -ENOMEM;
>
> OK, no BUG.  If this happens, kmem_cache_init_late() will go BUG
> instead ;)
>
> Questions for slab maintainers:
>
> What's going on with the gfp_flags in there?  kmem_cache_init_late()
> passes GFP_NOWAIT into enable_cpucache().
>
> a) why the heck does it do that?  It's __init code!

enable_cpucache() was called when a slab cache was reconfigured by writing to /proc/slabinfo.
That was changed awhile back when the memcg changes were made ot slab. So
now its ok to be made init code.

> Finally, all callers of enable_cpucache() (and hence of
> cache_random_seq_create()) are __init, so we're unnecessarily bloating
> up vmlinux.  Could someone please take a look at this as a separate
> thing?

Hmmm. Well if that is the case then lots of stuff could be straightened
out. Joonsoo?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

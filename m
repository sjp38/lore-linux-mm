Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 084F66B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 03:18:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so185250205pfy.2
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 00:18:05 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a1si14882489pfb.126.2016.04.29.00.18.04
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 00:18:05 -0700 (PDT)
Date: Fri, 29 Apr 2016 16:18:10 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v4] mm: SLAB freelist randomization
Message-ID: <20160429071810.GD19896@js1304-P5Q-DELUXE>
References: <1461687670-47585-1-git-send-email-thgarnie@google.com>
 <20160426161743.f831225a4efb3eb04debe402@linux-foundation.org>
 <alpine.DEB.2.20.1604271027540.20042@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1604271027540.20042@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Garnier <thgarnie@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Kees Cook <keescook@chromium.org>, gthelen@google.com, labbott@fedoraproject.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 27, 2016 at 10:39:29AM -0500, Christoph Lameter wrote:
> On Tue, 26 Apr 2016, Andrew Morton wrote:
> 
> > : CONFIG_FREELIST_RANDOM bugs me a bit - "freelist" is so vague.
> > : CONFIG_SLAB_FREELIST_RANDOM would be better.  I mean, what Kconfig
> > : identifier could be used for implementing randomisation in
> > : slub/slob/etc once CONFIG_FREELIST_RANDOM is used up?
> >
> > but this pearl appeared to pass unnoticed.
> 
> Ok. lets add SLAB here and then use this option for the other allocators
> as well.
> 
> > > +	/* If it fails, we will just use the global lists */
> > > +	cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), GFP_KERNEL);
> > > +	if (!cachep->random_seq)
> > > +		return -ENOMEM;
> >
> > OK, no BUG.  If this happens, kmem_cache_init_late() will go BUG
> > instead ;)
> >
> > Questions for slab maintainers:
> >
> > What's going on with the gfp_flags in there?  kmem_cache_init_late()
> > passes GFP_NOWAIT into enable_cpucache().
> >
> > a) why the heck does it do that?  It's __init code!
> 
> enable_cpucache() was called when a slab cache was reconfigured by writing to /proc/slabinfo.
> That was changed awhile back when the memcg changes were made ot slab. So
> now its ok to be made init code.
> 
> > Finally, all callers of enable_cpucache() (and hence of
> > cache_random_seq_create()) are __init, so we're unnecessarily bloating
> > up vmlinux.  Could someone please take a look at this as a separate
> > thing?
> 
> Hmmm. Well if that is the case then lots of stuff could be straightened
> out. Joonsoo?
> 

As I mentioned in other thread, enable_cpucache() can be called
whenever kmem_cache is created. It should not be __init.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

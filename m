Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 85F896B003A
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 04:17:37 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id t61so7467565wes.39
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 01:17:36 -0800 (PST)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500:20f:1fff:fe04:1bbb])
        by mx.google.com with ESMTP id i10si532119wix.57.2013.12.03.01.17.36
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 01:17:36 -0800 (PST)
Date: Tue, 3 Dec 2013 11:17:35 +0200 (EET)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: Slab BUG with DEBUG_* options
In-Reply-To: <alpine.DEB.2.02.1311301428390.18027@chino.kir.corp.google.com>
Message-ID: <alpine.SOC.1.00.1312031116150.3485@math.ut.ee>
References: <alpine.SOC.1.00.1311300125490.6363@math.ut.ee> <alpine.DEB.2.02.1311301428390.18027@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> > I am debugging a reboot problem on Sun Ultra 5 (sparc64) with 512M RAM 
> > and turned on DEBUG_PAGEALLOC DEBUG_SLAB and DEBUG_SLAB_LEAK (and most 
> > other debug options) and got the following BUG and hang on startup. This 
> > happened originally with 3.11-rc2-00058 where my bisection of 
> > another problem lead, but I retested 3.12 to have the same BUG in the 
> > same place.
> > 
> > kernel BUG at mm/slab.c:2391!
[...

> > The line shows that __kmem_cache_create gets a NULL from kmalloc_slab().
> > 
> > I instrumented the code and found the following:
> > 
> > __kmem_cache_create: starting, size=248, flags=8192
> > __kmem_cache_create: now flags=76800
> > __kmem_cache_create: aligned size to 248 because of redzoning
> > __kmem_cache_create: pagealloc debug, setting size to 8192
> > __kmem_cache_create: aligned size to 8192
> > __kmem_cache_create: num=1, slab_size=64
> > __kmem_cache_create: starting, size=96, flags=8192
> > __kmem_cache_create: now flags=76800
> > __kmem_cache_create: aligned size to 96 because of redzoning
> > __kmem_cache_create: pagealloc debug, setting size to 8192
> > __kmem_cache_create: aligned size to 8192
> > __kmem_cache_create: num=1, slab_size=64
> > __kmem_cache_create: starting, size=192, flags=8192
> > __kmem_cache_create: now flags=76800
> > __kmem_cache_create: aligned size to 192 because of redzoning
> > __kmem_cache_create: pagealloc debug, setting size to 8192
> > __kmem_cache_create: aligned size to 8192
> > __kmem_cache_create: num=1, slab_size=64
> > __kmem_cache_create: starting, size=32, flags=8192
> > __kmem_cache_create: now flags=76800
> > __kmem_cache_create: aligned size to 32 because of redzoning
> > __kmem_cache_create: aligned size to 32
> > __kmem_cache_create: num=226, slab_size=960
> > __kmem_cache_create: starting, size=64, flags=8192
> > __kmem_cache_create: now flags=76800
> > __kmem_cache_create: aligned size to 64 because of redzoning
> > __kmem_cache_create: pagealloc debug, setting size to 8192
> > __kmem_cache_create: turning on CFLGS_OFF_SLAB, size=8192
> > __kmem_cache_create: aligned size to 8192
> > __kmem_cache_create: num=1, slab_size=64
> > __kmem_cache_create: CFLGS_OFF_SLAB, size=8192, slab_size=52
> > __kmem_cache_create: CFLGS_OFF_SLAB, allocating slab 52
> > 
> > With slab size 64, it turns on CFLGS_OFF_SLAB and off slab allocation 
> > with this size fails. I do not know slab internals so I can not tell if 
> > this just happens because of the debug paths, or is it a real problem 
> > without the debug options too.
> > 
> 
> Sounds like a problem with create_kmalloc_caches(), what are the values 
> for KMALLOC_SHIFT_LOW and KMALLOC_SHIFT_HIGH?

KMALLOC_SHIFT_LOW=5, KMALLOC_SHIFT_HIGH=23
 
> It's interesting you report this as starting with 3.11-rc2 because this 
> changed in 3.9, what kernels were tested before 3.11-rc2 if any?

No other kernels were tested with slab debug - but all relsese kernels 
and most rc-s starting with rc2 or rc3 eacg time were tested without 
slab debug.

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

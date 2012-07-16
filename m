Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 2CA7F6B004D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 15:58:12 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so12722472pbb.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 12:58:11 -0700 (PDT)
Date: Mon, 16 Jul 2012 12:58:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <alpine.DEB.2.00.1207160915470.28952@router.home>
Message-ID: <alpine.DEB.2.00.1207161253240.29012@chino.kir.corp.google.com>
References: <1342221125.17464.8.camel@lorien2> <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com> <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com> <1342407840.3190.5.camel@lorien2> <alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1207160915470.28952@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shuah Khan <shuah.khan@hp.com>, Pekka Enberg <penberg@kernel.org>, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Mon, 16 Jul 2012, Christoph Lameter wrote:

> > > struct kmem_cache *kmem_cache_create(const char *name, size_t size,
> > > size_t align,
> > >                 unsigned long flags, void (*ctor)(void *))
> > > {
> > >         struct kmem_cache *s = NULL;
> > >
> > > #ifdef CONFIG_DEBUG_VM
> > >         if (!name || in_interrupt() || size < sizeof(void *) ||
> > >                 size > KMALLOC_MAX_SIZE) {
> > >                 printk(KERN_ERR "kmem_cache_create(%s) integrity check"
> > >                         " failed\n", name);
> > >                 goto out;
> > >         }
> > > #endif
> > >
> >
> > Agreed, this shouldn't depend on CONFIG_DEBUG_VM.
> 
> These checks are useless for regular kernel operations. They are
> only useful when developing code and should only be enabled during
> development. There is no point in testing the size and the name which are
> typically constant when a slab is created with a stable kernel.
> 

Sounds like a response from someone who is very familiar with slab 
allocators.  The reality, though, is that very few people are going to be 
doing development with CONFIG_DEBUG_VM enabled unless they notice problems 
beforehand.

Are you seriously trying to optimize kmem_cache_create()?  These checks 
certainly aren't going to hurt your perfromance and it seems appropriate 
to do some sanity checking before blowing up in unexpected ways.  It's 
also the way it's been done for years before extracting common allocator 
functions to their own file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

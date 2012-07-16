Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id DBF506B0062
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 10:17:23 -0400 (EDT)
Date: Mon, 16 Jul 2012 09:17:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1207160915470.28952@router.home>
References: <1342221125.17464.8.camel@lorien2> <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com> <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com> <1342407840.3190.5.camel@lorien2>
 <alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Shuah Khan <shuah.khan@hp.com>, Pekka Enberg <penberg@kernel.org>, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Mon, 16 Jul 2012, David Rientjes wrote:

> On Sun, 15 Jul 2012, Shuah Khan wrote:
>
> > I can work on reshuffling the code. Do have a question though. This
> > following sanity check is currently done only when CONFIG_DEBUG_VM is
> > defined. However, it does appear to be something that is that should be
> > checked even in regular path.
> >
> > struct kmem_cache *kmem_cache_create(const char *name, size_t size,
> > size_t align,
> >                 unsigned long flags, void (*ctor)(void *))
> > {
> >         struct kmem_cache *s = NULL;
> >
> > #ifdef CONFIG_DEBUG_VM
> >         if (!name || in_interrupt() || size < sizeof(void *) ||
> >                 size > KMALLOC_MAX_SIZE) {
> >                 printk(KERN_ERR "kmem_cache_create(%s) integrity check"
> >                         " failed\n", name);
> >                 goto out;
> >         }
> > #endif
> >
>
> Agreed, this shouldn't depend on CONFIG_DEBUG_VM.

These checks are useless for regular kernel operations. They are
only useful when developing code and should only be enabled during
development. There is no point in testing the size and the name which are
typically constant when a slab is created with a stable kernel.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

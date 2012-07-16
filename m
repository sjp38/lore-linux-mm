Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 3ABB96B004D
	for <linux-mm@kvack.org>; Sun, 15 Jul 2012 23:04:04 -0400 (EDT)
Message-ID: <1342407840.3190.5.camel@lorien2>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
From: Shuah Khan <shuah.khan@hp.com>
Reply-To: shuah.khan@hp.com
Date: Sun, 15 Jul 2012 21:04:00 -0600
In-Reply-To: <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com>
References: <1342221125.17464.8.camel@lorien2>
	 <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com>
	 <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, cl@linux.com, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Sat, 2012-07-14 at 15:01 +0300, Pekka Enberg wrote:

> I'm not exactly loving that either.
> 
> It'd probably be better to reshuffle the code so that the debug checks
> end up in separate functions that are no-op for !CONFIG_DEBUG_VM. That
> way the _labels_ are used unconditionally although there's no actual
> code generated.

I can work on reshuffling the code. Do have a question though. This
following sanity check is currently done only when CONFIG_DEBUG_VM is
defined. However, it does appear to be something that is that should be
checked even in regular path.

struct kmem_cache *kmem_cache_create(const char *name, size_t size,
size_t align,
                unsigned long flags, void (*ctor)(void *))
{
        struct kmem_cache *s = NULL;

#ifdef CONFIG_DEBUG_VM
        if (!name || in_interrupt() || size < sizeof(void *) ||
                size > KMALLOC_MAX_SIZE) {
                printk(KERN_ERR "kmem_cache_create(%s) integrity check"
                        " failed\n", name);
                goto out;
        }
#endif



---

}

Am I reading this right?

Thanks,
-- Shuah

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

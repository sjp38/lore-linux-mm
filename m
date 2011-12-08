Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id F3FFC6B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 16:44:09 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so2402049vbb.14
        for <linux-mm@kvack.org>; Thu, 08 Dec 2011 13:44:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201112071340.35267.arnd@arndb.de>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<CAF6AEGto-+oSqguuWyPunUbtE65GpNiXh21srQzrChiBQMb1Nw@mail.gmail.com>
	<CAB2ybb-0mTdNXN82O1TUGVjhMZUQtQb07A3EVmmdxg3ngEc3Dw@mail.gmail.com>
	<201112071340.35267.arnd@arndb.de>
Date: Thu, 8 Dec 2011 22:44:08 +0100
Message-ID: <CAKMK7uFQiiUbkU-7c3Os0d0FJNyLbqS2HLPRLy3LGnOoCXV5Pw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
From: Daniel Vetter <daniel@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Semwal, Sumit" <sumit.semwal@ti.com>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Wed, Dec 7, 2011 at 14:40, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wednesday 07 December 2011, Semwal, Sumit wrote:
>> Thanks for the excellent discussion - it indeed is very good learning
>> for the relatively-inexperienced me :)
>>
>> So, for the purpose of dma-buf framework, could I summarize the
>> following and rework accordingly?:
>> 1. remove mmap() dma_buf_op [and mmap fop], and introduce cpu_start(),
>> cpu_finish() ops to bracket cpu accesses to the buffer. Also add
>> DMABUF_CPU_START / DMABUF_CPU_FINI IOCTLs?
>
> I think we'd be better off for now without the extra ioctls and
> just document that a shared buffer must not be exported to user
> space using mmap at all, to avoid those problems. Serialization
> between GPU and CPU is on a higher level than the dma_buf framework
> IMHO.

Agreed.

>> 2. remove sg_sync* ops for now (and we'll see if we need to add them
>> later if needed)
>
> Just removing the sg_sync_* operations is not enough. We have to make
> the decision whether we want to allow
> a) only coherent mappings of the buffer into kernel memory (requiring
> an extension to the dma_map_ops on ARM to not flush caches at map/unmap
> time)
> b) not allowing any in-kernel mappings (same requirement on ARM, also
> limits the usefulness of the dma_buf if we cannot access it from the
> kernel or from user space)
> c) only allowing streaming mappings, even if those are non-coherent
> (requiring strict serialization between CPU (in-kernel) and dma users of
> the buffer)

I think only allowing streaming access makes the most sense:
- I don't see much (if any need) for the kernel to access a dma_buf -
in all current usecases it just contains pixel data and no hw-specific
things (like sg tables, command buffers, ..). At most I see the need
for the kernel to access the buffer for dma bounce buffers, but that
is internal to the dma subsystem (and hence does not need to be
exposed).
- Userspace can still access the contents through the exporting
subsystem (e.g. use some gem mmap support). For efficiency reason gpu
drivers are already messing around with cache coherency in a platform
specific way (and hence violated the dma api a bit), so we could stuff
the mmap coherency in there, too. When we later on extend dma_buf
support so that other drivers than the gpu can export dma_bufs, we can
then extend the official dma api with already a few drivers with
use-patterns around.

But I still think that the kernel must not be required to enforce
correct access ordering for the reasons outlined in my other mail.
-Daniel
-- 
Daniel Vetter
daniel.vetter@ffwll.ch - +41 (0) 79 364 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

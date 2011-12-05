Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 0411C6B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 13:55:45 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so5527905vcb.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 10:55:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201112051718.48324.arnd@arndb.de>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<1322816252-19955-2-git-send-email-sumit.semwal@ti.com>
	<201112051718.48324.arnd@arndb.de>
Date: Mon, 5 Dec 2011 19:55:44 +0100
Message-ID: <CAKMK7uE-ZJ-VQRWy+zJJWsvr9nARWuf-4nupXhTJ0CLqC88CEw@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Daniel Vetter <daniel@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>

On Mon, Dec 05, 2011 at 05:18:48PM +0000, Arnd Bergmann wrote:
> On Friday 02 December 2011, Sumit Semwal wrote:
> > +	/* allow allocator to take care of cache ops */
> > +	void (*sync_sg_for_cpu) (struct dma_buf *, struct device *);
> > +	void (*sync_sg_for_device)(struct dma_buf *, struct device *);
>
> I don't see how this works with multiple consumers: For the streaming
> DMA mapping, there must be exactly one owner, either the device or
> the CPU. Obviously, this rule needs to be extended when you get to
> multiple devices and multiple device drivers, plus possibly user
> mappings. Simply assigning the buffer to "the device" from one
> driver does not block other drivers from touching the buffer, and
> assigning it to "the cpu" does not stop other hardware that the
> code calling sync_sg_for_cpu is not aware of.
>
> The only way to solve this that I can think of right now is to
> mandate that the mappings are all coherent (i.e. noncachable
> on noncoherent architectures like ARM). If you do that, you no
> longer need the sync_sg_for_* calls.

Woops, totally missed the addition of these. Can somebody explain to used
to rather coherent x86 what we need these for and the code-flow would look
like in a typical example. I was kinda assuming that devices would bracket
their use of a buffer with the attachment_map/unmap calls and any cache
coherency magic that might be needed would be somewhat transparent to
users of the interface?

The map call gets the dma_data_direction parameter, so it should be able
to do the right thing. And because we keep the attachement around, any
caching of mappings should be possible, too.

Yours, Daniel

PS: Slightly related, because it will make the coherency nightmare worse,
afaict: Can we kill mmap support?
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

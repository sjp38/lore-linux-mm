Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id E581C6B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 16:23:52 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so5702297vcb.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 13:23:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAF6AEGvyWV0DM2fjBbh-TNHiMmiLF4EQDJ6Uu0=NkopM6SXS6g@mail.gmail.com>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<1322816252-19955-2-git-send-email-sumit.semwal@ti.com>
	<201112051718.48324.arnd@arndb.de>
	<CAF6AEGvyWV0DM2fjBbh-TNHiMmiLF4EQDJ6Uu0=NkopM6SXS6g@mail.gmail.com>
Date: Mon, 5 Dec 2011 22:23:51 +0100
Message-ID: <CAKMK7uHw3OpMAtVib=e=s_us9Tx9TebzehGg59d4-g9dUXr+pQ@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Daniel Vetter <daniel@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <rob@ti.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, jesse.barker@linaro.org, m.szyprowski@samsung.com, daniel@ffwll.ch, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>

On Mon, Dec 05, 2011 at 02:46:47PM -0600, Rob Clark wrote:
> On Mon, Dec 5, 2011 at 11:18 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > In the patch 2, you have a section about migration that mentions that
> > it is possible to export a buffer that can be migrated after it
> > is already mapped into one user driver. How does that work when
> > the physical addresses are mapped into a consumer device already?
>
> I think you can do physical migration if you are attached, but
> probably not if you are mapped.

Yeah, that's very much how I see this, and also why map/unmap (at least
for simple users like v4l) should only bracket actual usage. GPU memory
managers need to be able to move around buffers while no one is using
them.

[snip]

> >> + =A0 =A0 /* allow allocator to take care of cache ops */
> >> + =A0 =A0 void (*sync_sg_for_cpu) (struct dma_buf *, struct device *);
> >> + =A0 =A0 void (*sync_sg_for_device)(struct dma_buf *, struct device *=
);
> >
> > I don't see how this works with multiple consumers: For the streaming
> > DMA mapping, there must be exactly one owner, either the device or
> > the CPU. Obviously, this rule needs to be extended when you get to
> > multiple devices and multiple device drivers, plus possibly user
> > mappings. Simply assigning the buffer to "the device" from one
> > driver does not block other drivers from touching the buffer, and
> > assigning it to "the cpu" does not stop other hardware that the
> > code calling sync_sg_for_cpu is not aware of.
> >
> > The only way to solve this that I can think of right now is to
> > mandate that the mappings are all coherent (i.e. noncachable
> > on noncoherent architectures like ARM). If you do that, you no
> > longer need the sync_sg_for_* calls.
>
> My original thinking was that you either need DMABUF_CPU_{PREP,FINI}
> ioctls and corresponding dmabuf ops, which userspace is required to
> call before / after CPU access.  Or just remove mmap() and do the
> mmap() via allocating device and use that device's equivalent
> DRM_XYZ_GEM_CPU_{PREP,FINI} or DRM_XYZ_GEM_SET_DOMAIN ioctls.  That
> would give you a way to (a) synchronize with gpu/asynchronous
> pipeline, (b) synchronize w/ multiple hw devices vs cpu accessing
> buffer (ie. wait all devices have dma_buf_unmap_attachment'd).  And
> that gives you a convenient place to do cache operations on
> noncoherent architecture.
>
> I sort of preferred having the DMABUF shim because that lets you pass
> a buffer around userspace without the receiving code knowing about a
> device specific API.  But the problem I eventually came around to: if
> your GL stack (or some other userspace component) is batching up
> commands before submission to kernel, the buffers you need to wait for
> completion might not even be submitted yet.  So from kernel
> perspective they are "ready" for cpu access.  Even though in fact they
> are not in a consistent state from rendering perspective.  I don't
> really know a sane way to deal with that.  Maybe the approach instead
> should be a userspace level API (in libkms/libdrm?) to provide
> abstraction for userspace access to buffers rather than dealing with
> this at the kernel level.

Well, there's a reason GL has an explicit flush and extensions for sync
objects. It's to support such scenarios where the driver batches up gpu
commands before actually submitting them. Also, recent gpus have all (or
shortly will grow) multiple execution pipelines, so it's also important
that you sync up with the right command stream. Syncing up with all of
them is generally frowned upon for obvious reasons ;-)

So any userspace that interacts with an OpenGL driver needs to take care
of this anyway. But I think for simpler stuff (v4l) kernel only coherency
should work and userspace just needs to take care of gl interactions and
call glflush and friends at the right points. I think we can flesh this
out precisely when we spec the dmabuf EGL extension ... (or implement one
of the preexisting ones already around).

On the topic of a coherency model for dmabuf, I think we need to look at
dma_buf_attachment_map/unmap (and also the mmap variants cpu_start and
cpu_finish or whatever they might get called) as barriers:

So after a dma_buf_map, all previsously completed dma operations (i.e.
unmap already called) and any cpu writes (i.e. cpu_finish called) will be
coherent. Similar rule holds for cpu access through the userspace mmap,
only writes completed before the cpu_start will show up.

Similar, writes done by the device are only guaranteed to show up after
the _unmap. Dito for cpu writes and cpu_finish.

In short we always need two function calls to denote the start/end of the
"critical section".

Any concurrent operations are allowed to yield garbage, meaning any
combination of the old or either of the newly written contents (i.e.
non-overlapping writes might not actually all end up in the buffer,
but instead some old contents). Maybe we even need to loosen that to
the real "undefined behaviour", but atm I can't think of an example.

-Daniel
--=20
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

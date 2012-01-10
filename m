Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id DDB1E6B0068
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 01:09:32 -0500 (EST)
Received: by mail-tul01m020-f177.google.com with SMTP id wn1so6751860obc.36
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 22:09:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAF6AEGsQdd+K6-OOsdyFi_VVnMCniZFk2QvYqv8m8GgU7bd7zQ@mail.gmail.com>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
 <1322816252-19955-2-git-send-email-sumit.semwal@ti.com> <CAAQKjZPFh6666JKc-XJfKYePQ_F0MNF6FkY=zKypWb52VVX3YQ@mail.gmail.com>
 <20120109081030.GA3723@phenom.ffwll.local> <CAAQKjZMEsuib18RYE7OvZPUqhKnvrZ8i3+EMuZSXr9KPVygo_Q@mail.gmail.com>
 <CAF6AEGsTGOxyTX6Xijvm8UXGjtVTtYg5X5xfJo8D+47o+xU+bA@mail.gmail.com>
 <CAAQKjZNM51Oenhi-S-9kyq_mLYHBEsMQA3M6=6L_XNnKu5pLbA@mail.gmail.com> <CAF6AEGsQdd+K6-OOsdyFi_VVnMCniZFk2QvYqv8m8GgU7bd7zQ@mail.gmail.com>
From: "Semwal, Sumit" <sumit.semwal@ti.com>
Date: Tue, 10 Jan 2012 11:39:11 +0530
Message-ID: <CAB2ybb-vZuriqE+KeBAkbc33y8YvNkT+f0xnMUeOdXmJH0dSag@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <rob@ti.com>
Cc: InKi Dae <daeinki@gmail.com>, t.stanislaws@samsung.com, linux@arm.linux.org.uk, arnd@arndb.de, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, m.szyprowski@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Tue, Jan 10, 2012 at 7:44 AM, Rob Clark <rob@ti.com> wrote:
> On Mon, Jan 9, 2012 at 7:34 PM, InKi Dae <daeinki@gmail.com> wrote:
>> 2012/1/10 Rob Clark <rob@ti.com>:
>> at least with no IOMMU, the memory information(containing physical
>> memory address) would be copied to vb2_xx_buf object if drm gem
>> exported its own buffer and vb2 wants to use that buffer at this time,
>> sg table is used to share that buffer. and the problem I pointed out
>> is that this buffer(also physical memory region) could be released by
>> vb2 framework(as you know, vb2_xx_buf object and the memory region for
>> buf->dma_addr pointing) but the Exporter(drm gem) couldn't know that
>> so some problems would be induced once drm gem tries to release or
>> access that buffer. and I have tried to resolve this issue adding
>> get_shared_cnt() callback to dma-buf.h but I'm not sure that this is
>> good way. maybe there would be better way.
Hi Inki,
As also mentioned in the documentation patch, importer (the user of
the buffer) - in this case for current RFC patches on
v4l2-as-a-user[1] vb2 framework - shouldn't release the backing memory
of the buffer directly - it should only use the dma-buf callbacks in
the right sequence to let the exporter know that it is done using this
buffer, so the exporter can release it if allowed and needed.
>
> the exporter (in this case your driver's drm/gem bits) shouldn't
> release that mapping / sgtable until the importer (in this case v4l2)
> calls dma_buf_unmap fxn..
>
> It would be an error if the importer did a dma_buf_put() without first
> calling dma_buf_unmap_attachment() (if currently mapped) and then
> dma_buf_detach() (if currently attached). =A0Perhaps somewhere there
> should be some sanity checking debug code which could be enabled to do
> a WARN_ON() if the importer does the wrong thing. =A0It shouldn't really
> be part of the API, I don't think, but it actually does seem like a
> good thing, esp. as new drivers start trying to use dmabuf, to have
> some debug options which could be enabled.
>
> It is entirely possible that something was missed on the vb2 patches,
> but the way it is intended to work is like this:
> https://github.com/robclark/kernel-omap4/blob/0961428143cd10269223e3d0f24=
bc3a66a96185f/drivers/media/video/videobuf2-core.c#L92
>
> where it does a detach() before the dma_buf_put(), and the vb2-contig
> backend checks here that it is also unmapped():
> https://github.com/robclark/kernel-omap4/blob/0961428143cd10269223e3d0f24=
bc3a66a96185f/drivers/media/video/videobuf2-dma-contig.c#L251

The proposed RFC for V4L2 adaptation at [1] does exactly the same
thing; detach() before dma_buf_put(), and check in vb2-contig backend
for unmapped() as mentioned above.

>
> BR,
> -R
>
BR,
Sumit.

[1]: V4l2 as a dma-buf user RFC:
http://comments.gmane.org/gmane.linux.drivers.video-input-infrastructure/42=
966

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

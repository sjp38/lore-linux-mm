Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CCE556B0172
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 09:28:47 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so68363bkb.14
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 06:28:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPM=9tzHOa5Dbe=SQz+AURMMbio4L7qoS8kUT3Ek0+HdtkrH4g@mail.gmail.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
	<1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
	<CAPM=9tzHOa5Dbe=SQz+AURMMbio4L7qoS8kUT3Ek0+HdtkrH4g@mail.gmail.com>
Date: Wed, 12 Oct 2011 08:28:44 -0500
Message-ID: <CAF6AEGs6kkGp85NoNVuq5W9i=WE86V8wvAtKydX=D3bQOc+6Pw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, daniel@ffwll.ch

On Wed, Oct 12, 2011 at 7:41 AM, Dave Airlie <airlied@gmail.com> wrote:
> On Tue, Oct 11, 2011 at 10:23 AM, Sumit Semwal <sumit.semwal@ti.com> wrot=
e:
>> This is the first step in defining a dma buffer sharing mechanism.
>>
>> A new buffer object dma_buf is added, with operations and API to allow e=
asy
>> sharing of this buffer object across devices.
>>
>> The framework allows:
>> - a new buffer-object to be created with fixed size.
>> - different devices to 'attach' themselves to this buffer, to facilitate
>> =A0backing storage negotiation, using dma_buf_attach() API.
>> - association of a file pointer with each user-buffer and associated
>> =A0 allocator-defined operations on that buffer. This operation is calle=
d the
>> =A0 'export' operation.
>> - this exported buffer-object to be shared with the other entity by aski=
ng for
>> =A0 its 'file-descriptor (fd)', and sharing the fd across.
>> - a received fd to get the buffer object back, where it can be accessed =
using
>> =A0 the associated exporter-defined operations.
>> - the exporter and user to share the scatterlist using get_scatterlist a=
nd
>> =A0 put_scatterlist operations.
>>
>> Atleast one 'attach()' call is required to be made prior to calling the
>> get_scatterlist() operation.
>>
>> Couple of building blocks in get_scatterlist() are added to ease introdu=
ction
>> of sync'ing across exporter and users, and late allocation by the export=
er.
>>
>> mmap() file operation is provided for the associated 'fd', as wrapper ov=
er the
>> optional allocator defined mmap(), to be used by devices that might need=
 one.
>
> Why is this needed? it really doesn't make sense to be mmaping objects
> independent of some front-end like drm or v4l.

well, the mmap is actually implemented by the buffer allocator
(v4l/drm).. although not sure if this was the point

> how will you know what contents are in them, how will you synchronise
> access. Unless someone has a hard use-case for this I'd say we drop it
> until someone does.

The intent was that this is for well defined formats.. ie. it would
need to be a format that both v4l and drm understood in the first
place for sharing to make sense at all..

Anyways, the basic reason is to handle random edge cases where you
need sw access to the buffer.  For example, you are decoding video and
pull out a frame to generate a thumbnail w/ a sw jpeg encoder..

On gstreamer 0.11 branch, for example, there is already a map/unmap
virtual method on the gst buffer for sw access (ie. same purpose as
PrepareAccess/FinishAccess in EXA).  The idea w/ dmabuf mmap() support
is that we could implement support to mmap()/munmap() before/after sw
access.

With this current scheme, synchronization could be handled in
dmabufops->mmap() and vm_ops->close()..  it is perhaps a bit heavy to
require mmap/munmap for each sw access, but I suppose this isn't
really for the high-performance use case.  It is just so that some
random bit of sw that gets passed a dmabuf handle without knowing who
allocated it can have sw access if really needed.

BR,
-R

> Dave.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4E02C6B0173
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 09:35:48 -0400 (EDT)
Received: by ywe9 with SMTP id 9so26688ywe.14
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 06:35:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAF6AEGs6kkGp85NoNVuq5W9i=WE86V8wvAtKydX=D3bQOc+6Pw@mail.gmail.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
	<1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
	<CAPM=9tzHOa5Dbe=SQz+AURMMbio4L7qoS8kUT3Ek0+HdtkrH4g@mail.gmail.com>
	<CAF6AEGs6kkGp85NoNVuq5W9i=WE86V8wvAtKydX=D3bQOc+6Pw@mail.gmail.com>
Date: Wed, 12 Oct 2011 14:35:45 +0100
Message-ID: <CAPM=9twft0eBEUoCD11a2gTZHwOaPzFmZvBfE032dfK10eQ27Q@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Dave Airlie <airlied@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, daniel@ffwll.ch

>
> well, the mmap is actually implemented by the buffer allocator
> (v4l/drm).. although not sure if this was the point

Then why not use the correct interface? doing some sort of not-quite
generic interface isn't really helping anyone except adding an ABI
that we have to support.

If someone wants to bypass the current kernel APIs we should add a new
API for them not shove it into this generic buffer sharing layer.

> The intent was that this is for well defined formats.. ie. it would
> need to be a format that both v4l and drm understood in the first
> place for sharing to make sense at all..

How will you know the stride to take a simple example? The userspace
had to create this buffer somehow and wants to share it with
"something", you sound like
you really needs another API that is a simple accessor API that can
handle mmaps.

> Anyways, the basic reason is to handle random edge cases where you
> need sw access to the buffer. =A0For example, you are decoding video and
> pull out a frame to generate a thumbnail w/ a sw jpeg encoder..

Again, doesn't sound like it should be part of this API, and also
sounds like the sw jpeg encoder will need more info about the buffer
anyways like stride and format.

> With this current scheme, synchronization could be handled in
> dmabufops->mmap() and vm_ops->close().. =A0it is perhaps a bit heavy to
> require mmap/munmap for each sw access, but I suppose this isn't
> really for the high-performance use case. =A0It is just so that some
> random bit of sw that gets passed a dmabuf handle without knowing who
> allocated it can have sw access if really needed.

So I think thats fine, write a sw accessor providers, don't go
overloading the buffer sharing code.

This API will limit what people can use this buffer sharing for with
pure hw accessors, you might say, oh buts its okay to fail the mmap
then, but the chances of sw handling that I'm not so sure off.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

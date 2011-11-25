Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 529446B0074
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 09:13:25 -0500 (EST)
Received: by ghrr17 with SMTP id r17so4631635ghr.14
        for <linux-mm@kvack.org>; Fri, 25 Nov 2011 06:13:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
	<1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
Date: Fri, 25 Nov 2011 14:13:22 +0000
Message-ID: <CAPM=9tzAgCSDgdvi=9QZa-gEVXwKp_gpCPTtQ10XS=Z9K4805w@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Dave Airlie <airlied@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, daniel@ffwll.ch

On Tue, Oct 11, 2011 at 10:23 AM, Sumit Semwal <sumit.semwal@ti.com> wrote:
> This is the first step in defining a dma buffer sharing mechanism.
>
> A new buffer object dma_buf is added, with operations and API to allow ea=
sy
> sharing of this buffer object across devices.
>
> The framework allows:
> - a new buffer-object to be created with fixed size.
> - different devices to 'attach' themselves to this buffer, to facilitate
> =A0backing storage negotiation, using dma_buf_attach() API.
> - association of a file pointer with each user-buffer and associated
> =A0 allocator-defined operations on that buffer. This operation is called=
 the
> =A0 'export' operation.
> - this exported buffer-object to be shared with the other entity by askin=
g for
> =A0 its 'file-descriptor (fd)', and sharing the fd across.
> - a received fd to get the buffer object back, where it can be accessed u=
sing
> =A0 the associated exporter-defined operations.
> - the exporter and user to share the scatterlist using get_scatterlist an=
d
> =A0 put_scatterlist operations.
>
> Atleast one 'attach()' call is required to be made prior to calling the
> get_scatterlist() operation.
>
> Couple of building blocks in get_scatterlist() are added to ease introduc=
tion
> of sync'ing across exporter and users, and late allocation by the exporte=
r.
>
> mmap() file operation is provided for the associated 'fd', as wrapper ove=
r the
> optional allocator defined mmap(), to be used by devices that might need =
one.
>
> More details are there in the documentation patch.
>

Some questions, I've started playing around with using this framework
to do buffer sharing between DRM devices,

Why struct scatterlist and not struct sg_table? it seems like I really
want to use an sg_table,

I'm not convinced fd's are really useful over just some idr allocated
handle, so far I'm just returning the "fd" to userspace as a handle,
and passing it back in the other side, so I'm not really sure what an
fd wins us here, apart from the mmap thing which I think shouldn't be
here anyways.
(if fd's do win us more we should probably record that in the docs patch).

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

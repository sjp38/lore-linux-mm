Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id CA0A96B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 08:57:16 -0500 (EST)
Received: by mail-tul01m020-f175.google.com with SMTP id uo9so6059613obb.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 05:57:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201201201423.46858.laurent.pinchart@ideasonboard.com>
References: <1324891397-10877-1-git-send-email-sumit.semwal@ti.com>
 <1324891397-10877-2-git-send-email-sumit.semwal@ti.com> <201201201423.46858.laurent.pinchart@ideasonboard.com>
From: "Semwal, Sumit" <sumit.semwal@ti.com>
Date: Wed, 25 Jan 2012 19:26:52 +0530
Message-ID: <CAB2ybb98BT8L569G_728x1ZXdFNaQCDZzW2+kB0ZNeFak5_g+Q@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 1/3] dma-buf: Introduce dma buffer sharing mechanism
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, arnd@arndb.de, airlied@redhat.com, linux@arm.linux.org.uk, patches@linaro.org, jesse.barker@linaro.org, daniel@ffwll.ch

On Fri, Jan 20, 2012 at 6:53 PM, Laurent Pinchart
<laurent.pinchart@ideasonboard.com> wrote:
> Hi Summit,
>
> Sorry for the late review. I know that this code is now in mainline, but =
I
> still have a couple of comments. I'll send patches if you agree with them=
.
Hi Laurent,

Thanks for your review; apologies for being late in replying - I was
OoO for last couple of days.
>
> On Monday 26 December 2011 10:23:15 Sumit Semwal wrote:
<snip>
>>
>
> [snip]
>
>> diff --git a/drivers/base/dma-buf.c b/drivers/base/dma-buf.c
>> new file mode 100644
>> index 0000000..e38ad24
>> --- /dev/null
>> +++ b/drivers/base/dma-buf.c
>> @@ -0,0 +1,291 @@
>
> [snip]
>
>> +/**
>> + * dma_buf_export - Creates a new dma_buf, and associates an anon file
>> + * with this buffer, so it can be exported.
>> + * Also connect the allocator specific data and ops to the buffer.
>> + *
>> + * @priv: =A0 =A0[in] =A0 =A0Attach private data of allocator to this b=
uffer
>> + * @ops: =A0 =A0 [in] =A0 =A0Attach allocator-defined dma buf ops to th=
e new buffer.
>> + * @size: =A0 =A0[in] =A0 =A0Size of the buffer
>> + * @flags: =A0 [in] =A0 =A0mode flags for the file.
>> + *
>> + * Returns, on success, a newly created dma_buf object, which wraps the
>> + * supplied private data and operations for dma_buf_ops. On either miss=
ing
>> + * ops, or error in allocating struct dma_buf, will return negative err=
or.
>> + *
>> + */
>> +struct dma_buf *dma_buf_export(void *priv, struct dma_buf_ops *ops,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, i=
nt flags)
>> +{
>> + =A0 =A0 struct dma_buf *dmabuf;
>> + =A0 =A0 struct file *file;
>> +
>> + =A0 =A0 if (WARN_ON(!priv || !ops
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || !ops->map_dma_buf
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || !ops->unmap_dma_buf
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || !ops->release)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
>> + =A0 =A0 }
>> +
>> + =A0 =A0 dmabuf =3D kzalloc(sizeof(struct dma_buf), GFP_KERNEL);
>> + =A0 =A0 if (dmabuf =3D=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENOMEM);
>> +
>> + =A0 =A0 dmabuf->priv =3D priv;
>> + =A0 =A0 dmabuf->ops =3D ops;
>
> dmabuf->ops will never but NULL, but (see below)
>
<snip>
>> +struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 struct device *dev)
>> +{
>> + =A0 =A0 struct dma_buf_attachment *attach;
>> + =A0 =A0 int ret;
>> +
>> + =A0 =A0 if (WARN_ON(!dmabuf || !dev || !dmabuf->ops))
>
> you still check dmabuf->ops here, as well as in several places below.
> Shouldn't these checks be removed ?
You're right - these can be removed.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
>> +
>> + =A0 =A0 attach =3D kzalloc(sizeof(struct dma_buf_attachment), GFP_KERN=
EL);
>> + =A0 =A0 if (attach =3D=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto err_alloc;
>
> What about returning ERR_PTR(-ENOMEM) directly here ?
>
Right; we can do that.
>> +
>> + =A0 =A0 mutex_lock(&dmabuf->lock);
>> +
>> + =A0 =A0 attach->dev =3D dev;
>> + =A0 =A0 attach->dmabuf =3D dmabuf;
>
> These two lines can be moved before mutex_lock().
>
:) Yes - thanks for catching this.
<snip>
> --
> Regards,
>
> Laurent Pinchart

Let me know if you'd send patches for these, or should I just go ahead
and correct.

Best regards,
~Sumit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

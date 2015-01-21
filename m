Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 148BD6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 13:57:06 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id y19so4446345wgg.11
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 10:57:05 -0800 (PST)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id t1si1452460wje.69.2015.01.21.10.57.04
        for <linux-mm@kvack.org>;
        Wed, 21 Jan 2015 10:57:04 -0800 (PST)
Message-ID: <54BFF679.6010705@arm.com>
Date: Wed, 21 Jan 2015 18:56:57 +0000
From: Robin Murphy <robin.murphy@arm.com>
MIME-Version: 1.0
Subject: Re: [RFCv2 1/2] device: add dma_params->max_segment_count
References: <1421813807-9178-1-git-send-email-sumit.semwal@linaro.org> <1421813807-9178-2-git-send-email-sumit.semwal@linaro.org>
In-Reply-To: <1421813807-9178-2-git-send-email-sumit.semwal@linaro.org>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "t.stanislaws@samsung.com" <t.stanislaws@samsung.com>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "robdclark@gmail.com" <robdclark@gmail.com>, "daniel@ffwll.ch" <daniel@ffwll.ch>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>

Hi Sumit,

On 21/01/15 04:16, Sumit Semwal wrote:
> From: Rob Clark <robdclark@gmail.com>
>
> For devices which have constraints about maximum number of segments in
> an sglist.  For example, a device which could only deal with contiguous
> buffers would set max_segment_count to 1.
>
> The initial motivation is for devices sharing buffers via dma-buf,
> to allow the buffer exporter to know the constraints of other
> devices which have attached to the buffer.  The dma_mask and fields
> in 'struct device_dma_parameters' tell the exporter everything else
> that is needed, except whether the importer has constraints about
> maximum number of segments.
>
> Signed-off-by: Rob Clark <robdclark@gmail.com>
>   [sumits: Minor updates wrt comments on the first version]
> Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
> ---
>   include/linux/device.h      |  1 +
>   include/linux/dma-mapping.h | 19 +++++++++++++++++++
>   2 files changed, 20 insertions(+)
>
> diff --git a/include/linux/device.h b/include/linux/device.h
> index fb50673..a32f9b6 100644
> --- a/include/linux/device.h
> +++ b/include/linux/device.h
> @@ -647,6 +647,7 @@ struct device_dma_parameters {
>   =09 * sg limitations.
>   =09 */
>   =09unsigned int max_segment_size;
> +=09unsigned int max_segment_count;    /* INT_MAX for unlimited */
>   =09unsigned long segment_boundary_mask;
>   };
>
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index c3007cb..38e2835 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -154,6 +154,25 @@ static inline unsigned int dma_set_max_seg_size(stru=
ct device *dev,
>   =09=09return -EIO;
>   }
>
> +#define DMA_SEGMENTS_MAX_SEG_COUNT ((unsigned int) INT_MAX)
> +
> +static inline unsigned int dma_get_max_seg_count(struct device *dev)
> +{
> +=09return dev->dma_parms ?
> +=09=09=09dev->dma_parms->max_segment_count :
> +=09=09=09DMA_SEGMENTS_MAX_SEG_COUNT;
> +}

I know this copies the style of the existing code, but unfortunately it=20
also copies the subtle brokenness. Plenty of drivers seem to set up a=20
dma_parms struct just for max_segment_size, thus chances are you'll come=20
across a max_segment_count of 0 sooner or later. How badly is that going=20
to break things? I posted a fix recently[1] having hit this problem with=20
segment_boundary_mask in IOMMU code.

> +
> +static inline int dma_set_max_seg_count(struct device *dev,
> +=09=09=09=09=09=09unsigned int count)
> +{
> +=09if (dev->dma_parms) {
> +=09=09dev->dma_parms->max_segment_count =3D count;
> +=09=09return 0;
> +=09} else

This "else" is just as unnecessary as the other two I've taken out ;)


Robin.

[1]:http://article.gmane.org/gmane.linux.kernel.iommu/8175/

> +=09=09return -EIO;
> +}
> +
>   static inline unsigned long dma_get_seg_boundary(struct device *dev)
>   {
>   =09return dev->dma_parms ?
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

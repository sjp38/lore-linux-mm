Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 81B7F6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 02:21:10 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M7G00A2I4B87Q00@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Jul 2012 15:21:08 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M7G00L714AS2470@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 20 Jul 2012 15:21:08 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1342715014-5316-1-git-send-email-rob.clark@linaro.org>
 <1342715014-5316-2-git-send-email-rob.clark@linaro.org>
In-reply-to: <1342715014-5316-2-git-send-email-rob.clark@linaro.org>
Subject: RE: [PATCH 1/2] device: add dma_params->max_segment_count
Date: Fri, 20 Jul 2012 08:20:50 +0200
Message-id: <018b01cd663f$d3a23c10$7ae6b430$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Rob Clark' <rob.clark@linaro.org>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org
Cc: patches@linaro.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, daniel@ffwll.ch, Tomasz Stanislawski <t.stanislaws@samsung.com>, sumit.semwal@ti.com, maarten.lankhorst@canonical.com, 'Rob Clark' <rob@ti.com>

Hello,

On Thursday, July 19, 2012 6:24 PM Rob Clark wrote:

> From: Rob Clark <rob@ti.com>
> 
> For devices which have constraints about maximum number of segments
> in an sglist.  For example, a device which could only deal with
> contiguous buffers would set max_segment_count to 1.
> 
> The initial motivation is for devices sharing buffers via dma-buf,
> to allow the buffer exporter to know the constraints of other
> devices which have attached to the buffer.  The dma_mask and fields
> in 'struct device_dma_parameters' tell the exporter everything else
> that is needed, except whether the importer has constraints about
> maximum number of segments.
> 
> Signed-off-by: Rob Clark <rob@ti.com>

Yea, it is a really good idea to add this to struct device_dma_parameters.
We only need to initialize it to '1' in platform startup code for all 
devices relevant to buffer sharing.

Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>

> ---
>  include/linux/device.h      |    1 +
>  include/linux/dma-mapping.h |   16 ++++++++++++++++
>  2 files changed, 17 insertions(+)
> 
> diff --git a/include/linux/device.h b/include/linux/device.h
> index 161d962..3813735 100644
> --- a/include/linux/device.h
> +++ b/include/linux/device.h
> @@ -568,6 +568,7 @@ struct device_dma_parameters {
>  	 * sg limitations.
>  	 */
>  	unsigned int max_segment_size;
> +	unsigned int max_segment_count;    /* zero for unlimited */
>  	unsigned long segment_boundary_mask;
>  };
> 
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index dfc099e..f380f79 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -111,6 +111,22 @@ static inline unsigned int dma_set_max_seg_size(struct device *dev,
>  		return -EIO;
>  }
> 
> +static inline unsigned int dma_get_max_seg_count(struct device *dev)
> +{
> +	return dev->dma_parms ? dev->dma_parms->max_segment_count : 0;
> +}
> +
> +static inline int dma_set_max_seg_count(struct device *dev,
> +						unsigned int count)
> +{
> +	if (dev->dma_parms) {
> +		dev->dma_parms->max_segment_count = count;
> +		return 0;
> +	} else
> +		return -EIO;
> +}
> +
> +
>  static inline unsigned long dma_get_seg_boundary(struct device *dev)
>  {
>  	return dev->dma_parms ?
> --
> 1.7.9.5

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

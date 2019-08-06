Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 912D4C41514
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:31:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6151F20818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:31:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6151F20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E04566B0003; Tue,  6 Aug 2019 07:31:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB47D6B000A; Tue,  6 Aug 2019 07:31:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA2256B000D; Tue,  6 Aug 2019 07:31:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A99936B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:31:21 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r58so78665020qtb.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:31:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=6MKE3WpJRvmKRFMaN2W9lDZcPJmjUwMQHP29v6g6oiE=;
        b=QF9rEmhTz/UEfhnQ7XMpsHghfYE1HCcqQAlgNcfOu34hs1vOFTofyz17IWbPc/Md7y
         /zul40lMbWj1ef0eLwGXSPyPNV5ozIYFlwhLAiEoMk6kp/q9Llj8lDZPcxVxfLcqzR0r
         xhJ7cy8vnkmeEp742LEoxJHQ+ksbC4BkaxuO7rQvziJsPEfj3Q9UeFo8BA1DXwvvXm6T
         jKln27rSi9xQwkPhBB5MJLuuLmKKpoccUqF2R6g0LvyzMROu7ketmekM+W3d212dwB/a
         4B/m0uvzhUxtVNos7kL1Sx0kMvXV78MaFz0EMnFKrmuaZ4CVlt2s4OIKOBJs4L232el+
         6LkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUnxmgwjICvFpg8zQ7OBzwhT6Az0+PHMszBmRE197ukS9BMqtpB
	CzpZpM5cGcVz49XYhJ+3Jt3B1LJbSamDojOcZ+4Fg4DO7RID60JLPxWTa9tfuZsoMUBHNmZ2C+R
	vOy0qMGSUcyAeRSKU6XF/qn6h4KCxgqOih8UimHtEbMgbEbOVnsC0YdIc47dNbzZuoA==
X-Received: by 2002:a05:620a:690:: with SMTP id f16mr2556535qkh.97.1565091081431;
        Tue, 06 Aug 2019 04:31:21 -0700 (PDT)
X-Received: by 2002:a05:620a:690:: with SMTP id f16mr2556485qkh.97.1565091080793;
        Tue, 06 Aug 2019 04:31:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565091080; cv=none;
        d=google.com; s=arc-20160816;
        b=PGO0SxJi1vEcBQAl32tBxbvYUQaE8fRSpR1+27lpbEPPFNya89wS73fDZsP2x+wxgK
         LHoc+r9p/jpRAwF5M/GN9AXlhr2X246bTWG5JVqFHlgIPx7Pv5w0QWqdGnmmYnsECeDx
         eiIVAmkWEpLcVK1qfboQ8jAjJTM9AQbP1VqmbEHIwvx6uQnU+15iAbWtvMcmN8wN3L95
         6wFT3VZoWES8vWvo1Wk6S8cfwckeG9ZZtkRcH3TF1pH5wcebUi6o6n18McnwEK+Tmlsr
         udaJNxe65zUkLTcrSTO1c54NBJMuZq1JcxmuCxZkXl7IaREySR1kw+OPClZJNZ5vTqgU
         6NBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=6MKE3WpJRvmKRFMaN2W9lDZcPJmjUwMQHP29v6g6oiE=;
        b=ukAAyWVaegcLjJLFhj40JB1LGBD4Y7v5CBHDEYHq8hMIFfwVaxohLo0jrOrApwW+D0
         XqZgrtUbWiW0ZcQHzGCoqF2Tb2EAivOhlUsT0540dUZW3xFY2ZpcQg8ivzZVLis4CQBJ
         aldJhHxftb4gffVLAOqfjlIl70a6l3lM+dVc2YwW6uxsV1SpIN+qAVGNMrI3UiCl3WU4
         bzWOAij8oo6Oo5RUAhyI8qiea/WOgMpfma3Cp+bdyUzfbWZywN23WWME+oPsPDDSaGHL
         YNXh3qKFqc9mI3/3Ec6u3Uyxbw3iCUtcHbz+4j/MQOPImhYOjughxOvnv2UbhzMcuyOe
         NObg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 56sor112732064qtp.70.2019.08.06.04.31.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:31:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzvrf13MUE19LiIf1x3M2bj2D6eaCY1fg59zYnBrXL5jz1U6+gizBe5cXM8McsO2BykNMm8bA==
X-Received: by 2002:ac8:7a9a:: with SMTP id x26mr2526029qtr.251.1565091080543;
        Tue, 06 Aug 2019 04:31:20 -0700 (PDT)
Received: from redhat.com ([147.234.38.1])
        by smtp.gmail.com with ESMTPSA id d31sm44554913qta.39.2019.08.06.04.31.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 04:31:19 -0700 (PDT)
Date: Tue, 6 Aug 2019 07:31:11 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
	david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	willy@infradead.org, lcapitulino@redhat.com, wei.w.wang@intel.com,
	aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com
Subject: Re: [PATCH v3 6/6] virtio-balloon: Add support for providing unused
 page reports to host
Message-ID: <20190806073047-mutt-send-email-mst@kernel.org>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
 <20190801223829.22190.36831.stgit@localhost.localdomain>
 <1cff09a4-d302-639c-ab08-9d82e5fc1383@redhat.com>
 <ed48ecdb833808bf6b08bc54fa98503cbad493f3.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ed48ecdb833808bf6b08bc54fa98503cbad493f3.camel@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 09:27:16AM -0700, Alexander Duyck wrote:
> On Mon, 2019-08-05 at 12:00 -0400, Nitesh Narayan Lal wrote:
> > On 8/1/19 6:38 PM, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > Add support for the page reporting feature provided by virtio-balloon.
> > > Reporting differs from the regular balloon functionality in that is is
> > > much less durable than a standard memory balloon. Instead of creating a
> > > list of pages that cannot be accessed the pages are only inaccessible
> > > while they are being indicated to the virtio interface. Once the
> > > interface has acknowledged them they are placed back into their respective
> > > free lists and are once again accessible by the guest system.
> > > 
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > ---
> > >  drivers/virtio/Kconfig              |    1 +
> > >  drivers/virtio/virtio_balloon.c     |   56 +++++++++++++++++++++++++++++++++++
> > >  include/uapi/linux/virtio_balloon.h |    1 +
> > >  3 files changed, 58 insertions(+)
> > > 
> > > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > > index 078615cf2afc..4b2dd8259ff5 100644
> > > --- a/drivers/virtio/Kconfig
> > > +++ b/drivers/virtio/Kconfig
> > > @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
> > >  	tristate "Virtio balloon driver"
> > >  	depends on VIRTIO
> > >  	select MEMORY_BALLOON
> > > +	select PAGE_REPORTING
> > >  	---help---
> > >  	 This driver supports increasing and decreasing the amount
> > >  	 of memory within a KVM guest.
> > > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > > index 2c19457ab573..971fe924e34f 100644
> > > --- a/drivers/virtio/virtio_balloon.c
> > > +++ b/drivers/virtio/virtio_balloon.c
> > > @@ -19,6 +19,7 @@
> > >  #include <linux/mount.h>
> > >  #include <linux/magic.h>
> > >  #include <linux/pseudo_fs.h>
> > > +#include <linux/page_reporting.h>
> > >  
> > >  /*
> > >   * Balloon device works in 4K page units.  So each page is pointed to by
> > > @@ -37,6 +38,9 @@
> > >  #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
> > >  	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
> > >  
> > > +/*  limit on the number of pages that can be on the reporting vq */
> > > +#define VIRTIO_BALLOON_VRING_HINTS_MAX	16
> > > +
> > >  #ifdef CONFIG_BALLOON_COMPACTION
> > >  static struct vfsmount *balloon_mnt;
> > >  #endif
> > > @@ -46,6 +50,7 @@ enum virtio_balloon_vq {
> > >  	VIRTIO_BALLOON_VQ_DEFLATE,
> > >  	VIRTIO_BALLOON_VQ_STATS,
> > >  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> > > +	VIRTIO_BALLOON_VQ_REPORTING,
> > >  	VIRTIO_BALLOON_VQ_MAX
> > >  };
> > >  
> > > @@ -113,6 +118,10 @@ struct virtio_balloon {
> > >  
> > >  	/* To register a shrinker to shrink memory upon memory pressure */
> > >  	struct shrinker shrinker;
> > > +
> > > +	/* Unused page reporting device */
> > > +	struct virtqueue *reporting_vq;
> > > +	struct page_reporting_dev_info ph_dev_info;
> > >  };
> > >  
> > >  static struct virtio_device_id id_table[] = {
> > > @@ -152,6 +161,23 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> > >  
> > >  }
> > >  
> > > +void virtballoon_unused_page_report(struct page_reporting_dev_info *ph_dev_info,
> > > +				    unsigned int nents)
> > > +{
> > > +	struct virtio_balloon *vb =
> > > +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> > > +	struct virtqueue *vq = vb->reporting_vq;
> > > +	unsigned int unused;
> > > +
> > > +	/* We should always be able to add these buffers to an empty queue. */
> > > +	virtqueue_add_inbuf(vq, ph_dev_info->sg, nents, vb,
> > > +			    GFP_NOWAIT | __GFP_NOWARN);
> > 
> > I think you should handle allocation failure here. It is a possibility, isn't?
> > Maybe return an error or even disable page hinting/reporting?
> > 
> 
> I don't think it is an issue I have to worry about. Specifically I am
> limiting the size of the scatterlist based on the size of the vq. As such
> I will never exceed the size and should be able to use it to store the
> scatterlist directly.

I agree. But it can't hurt to BUG_ON for good measure.

-- 
MST


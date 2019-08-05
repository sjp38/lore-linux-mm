Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA721C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 16:36:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 533872086D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 16:36:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 533872086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A043D6B0005; Mon,  5 Aug 2019 12:36:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B4B86B0006; Mon,  5 Aug 2019 12:36:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87C2B6B0007; Mon,  5 Aug 2019 12:36:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDD26B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 12:36:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k20so53052005pgg.15
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 09:36:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=GLF3xAIayfgXT+v4rLYxKNTX/C/b+0YPxmm68b2cQBA=;
        b=U6h+n05Iow7Y5rzbVMsQ68luCiYzZfzX/GaUjNF1Cr5acpkbUiqQw7VtH4N70kamiD
         c4cgrthBB1oBU4/yyQ09tjJIVlgOKySw8i3UHWN7wdxLNQUN7VT08AD1rrh2iOAB7ztg
         OiipcLaI6HBstMKJnYMpn5bmHYo8LuCHPZg95/dYvUm19KF6TH1kBn+8cbcxDIzZSESS
         EcflYmv2vjiLld7NuYpOqTdygsdhRLubY2HGbMQv3gC3UOltE84PuWHWrbgfZ6G5Nua/
         57dmlSLHmzltpBU2CoYrIRBOUoqW8PlrnmXNFnUjGbltnSe0igAmOFmWP0kP6jI67dmR
         RJqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVy6TT74j3uAE0htSblsJbv3VKYtbOIm18BZvnMXKS7quCvszxq
	fop0h/Po4WL+YlRyNXzXIIE4PZ4lX76b9R+QuiC361K9flQZuehg/COMHvqs6SS3YVmlN5T/1tz
	whkcBOQVRMiq3eNyL8Q351BNy9dUiGfQbbfhIJCk2Fqa1+MvGR4G9JR/0YiGr472Tcw==
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr61611144plp.126.1565022999976;
        Mon, 05 Aug 2019 09:36:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfaQR3GX9jRxIMuL5F1UIlcvtyBNvAA92SMklfZ6JTzuyvEkyIiAlgmFvH03GSFU5mJ39R
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr61611101plp.126.1565022998973;
        Mon, 05 Aug 2019 09:36:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565022998; cv=none;
        d=google.com; s=arc-20160816;
        b=NlHCo5WwrNibIszo0P67MuqBkk/DPAR2RNPmh42c0JL9WNiu/orbI50DmvW2MZS3CT
         bMoJ8xc2LXBrZBcz9CglpDUMLZWWACuN/ID6P2BxSu16J/wx13fwWFXFlzLlAITeW/p/
         5W82Lc5RTIUHiXurre5jYd+a73xQUAI+WWc+Gf/RfqZgZtRz/+4Q4difVF4roULbgiG9
         r8cenuDufd/tFlqLNHnHt9YGlFiIAphqD2dvI6pGJTiijVd5vkC7MGf736sspndmSnvo
         LCmpEyc8BPcUhJ6d6IQBup8HP8bd73GS1CJfCO4YveVKTCCeCogWpSOtOUUG7rAXTlXU
         X+Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=GLF3xAIayfgXT+v4rLYxKNTX/C/b+0YPxmm68b2cQBA=;
        b=fT9KPurDlf0HP582fWwuq8EUDVKONH0LunBMksy4P93HD61J8bzgY+xoFMqePArpQT
         uUQDV0aGdnUjbOnO8GFz8MTLY0j78gL7OLPvcOLQFQhCzPf/RaZEBjAasB1pz/+sUODF
         X5WnakXj7sU8+IxnMuaE2SgkoFCGe8iKtlT0KjsPc+8Eb8LvJw5KmqzJvkXL5+tmoCc0
         xc7UxLHUncXc+m+ajYBw3Q4+kTuWQRuCHLG/43Nblqs298FJXGY/rIxhmy/fsg0iOFBW
         XBC680V0FMh9ct8yGZXFj3l5zdmmcTyG7Pz90jnS8iwruwe5Yr/aFB4bXHd+4fzFppxf
         eFPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d5si39759370pla.17.2019.08.05.09.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 09:36:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 09:27:17 -0700
X-IronPort-AV: E=Sophos;i="5.64,350,1559545200"; 
   d="scan'208";a="185363930"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga002-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 09:27:17 -0700
Message-ID: <ed48ecdb833808bf6b08bc54fa98503cbad493f3.camel@linux.intel.com>
Subject: Re: [PATCH v3 6/6] virtio-balloon: Add support for providing unused
 page reports to host
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com, 
	dan.j.williams@intel.com
Date: Mon, 05 Aug 2019 09:27:16 -0700
In-Reply-To: <1cff09a4-d302-639c-ab08-9d82e5fc1383@redhat.com>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
	 <20190801223829.22190.36831.stgit@localhost.localdomain>
	 <1cff09a4-d302-639c-ab08-9d82e5fc1383@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-05 at 12:00 -0400, Nitesh Narayan Lal wrote:
> On 8/1/19 6:38 PM, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Add support for the page reporting feature provided by virtio-balloon.
> > Reporting differs from the regular balloon functionality in that is is
> > much less durable than a standard memory balloon. Instead of creating a
> > list of pages that cannot be accessed the pages are only inaccessible
> > while they are being indicated to the virtio interface. Once the
> > interface has acknowledged them they are placed back into their respective
> > free lists and are once again accessible by the guest system.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  drivers/virtio/Kconfig              |    1 +
> >  drivers/virtio/virtio_balloon.c     |   56 +++++++++++++++++++++++++++++++++++
> >  include/uapi/linux/virtio_balloon.h |    1 +
> >  3 files changed, 58 insertions(+)
> > 
> > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > index 078615cf2afc..4b2dd8259ff5 100644
> > --- a/drivers/virtio/Kconfig
> > +++ b/drivers/virtio/Kconfig
> > @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
> >  	tristate "Virtio balloon driver"
> >  	depends on VIRTIO
> >  	select MEMORY_BALLOON
> > +	select PAGE_REPORTING
> >  	---help---
> >  	 This driver supports increasing and decreasing the amount
> >  	 of memory within a KVM guest.
> > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > index 2c19457ab573..971fe924e34f 100644
> > --- a/drivers/virtio/virtio_balloon.c
> > +++ b/drivers/virtio/virtio_balloon.c
> > @@ -19,6 +19,7 @@
> >  #include <linux/mount.h>
> >  #include <linux/magic.h>
> >  #include <linux/pseudo_fs.h>
> > +#include <linux/page_reporting.h>
> >  
> >  /*
> >   * Balloon device works in 4K page units.  So each page is pointed to by
> > @@ -37,6 +38,9 @@
> >  #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
> >  	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
> >  
> > +/*  limit on the number of pages that can be on the reporting vq */
> > +#define VIRTIO_BALLOON_VRING_HINTS_MAX	16
> > +
> >  #ifdef CONFIG_BALLOON_COMPACTION
> >  static struct vfsmount *balloon_mnt;
> >  #endif
> > @@ -46,6 +50,7 @@ enum virtio_balloon_vq {
> >  	VIRTIO_BALLOON_VQ_DEFLATE,
> >  	VIRTIO_BALLOON_VQ_STATS,
> >  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> > +	VIRTIO_BALLOON_VQ_REPORTING,
> >  	VIRTIO_BALLOON_VQ_MAX
> >  };
> >  
> > @@ -113,6 +118,10 @@ struct virtio_balloon {
> >  
> >  	/* To register a shrinker to shrink memory upon memory pressure */
> >  	struct shrinker shrinker;
> > +
> > +	/* Unused page reporting device */
> > +	struct virtqueue *reporting_vq;
> > +	struct page_reporting_dev_info ph_dev_info;
> >  };
> >  
> >  static struct virtio_device_id id_table[] = {
> > @@ -152,6 +161,23 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> >  
> >  }
> >  
> > +void virtballoon_unused_page_report(struct page_reporting_dev_info *ph_dev_info,
> > +				    unsigned int nents)
> > +{
> > +	struct virtio_balloon *vb =
> > +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> > +	struct virtqueue *vq = vb->reporting_vq;
> > +	unsigned int unused;
> > +
> > +	/* We should always be able to add these buffers to an empty queue. */
> > +	virtqueue_add_inbuf(vq, ph_dev_info->sg, nents, vb,
> > +			    GFP_NOWAIT | __GFP_NOWARN);
> 
> I think you should handle allocation failure here. It is a possibility, isn't?
> Maybe return an error or even disable page hinting/reporting?
> 

I don't think it is an issue I have to worry about. Specifically I am
limiting the size of the scatterlist based on the size of the vq. As such
I will never exceed the size and should be able to use it to store the
scatterlist directly.


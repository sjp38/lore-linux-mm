Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DCBCC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:16:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C053A20717
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:16:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C053A20717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 719EC6B0007; Tue,  6 Aug 2019 11:16:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CA1A6B0008; Tue,  6 Aug 2019 11:16:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DFD26B000A; Tue,  6 Aug 2019 11:16:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 244726B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:16:39 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h5so55119240pgq.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:16:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=t5utYjK2IgovkZjkelguTsCtsgYZG52HIH6Pxqs1L48=;
        b=eWffwXRlOfXoIo0nAX1BRSS9c7JDrx5jGH8Ql30kBNfZ1kZ0178N0bQylf22xF3HRk
         w9uYBtm37sy9aUTxedutP13+3tZ5knXAFHcp29vWuOdS6vADhQHtItS6Fk2kMTYSpVUT
         I4O8rvMnfHWkQPAuK7zl7o2SLq4dJVvX4rTKF7gs/EZhQ8eP2rTDDGzDBsvd9Wggarj1
         85Z8JtCToHHMeBhjopGJD+Egaln46Zlu1qQ8Xj6WxKDAm9fjPDKO6ZKe/eCxEvJLLTJb
         yNgmg2U4QEES2h6YIAPpRZ+A0YRmq/Rfmg00qrwTNZn2d+25RtWR99ozjt5iF0R+v2Vn
         vxMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWpWiBNGXw+xv7TCOB9Au7596VPEPv5nqjVB96rd9nULiLiykmL
	mCy21d2CdGUE3XhqMDFTnh1OlVQukryIztix9O06AUyguRs0jdrowc+YcvP03kRhebBJUIEkhSB
	W3gzQE/6i9mt0EiWyC2rNcX9o8B+kPWXi8cxWbT6t16gLVqQlqIg5Q4v9jXkPNJiQVg==
X-Received: by 2002:a17:90a:6097:: with SMTP id z23mr3753923pji.75.1565104598764;
        Tue, 06 Aug 2019 08:16:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDPEr2Y00hahB0f36Pz7Ht3/ydXV8CMk2Z1codFrjFiLV3viNiOH/JjlBwHu/LxGAtZmPY
X-Received: by 2002:a17:90a:6097:: with SMTP id z23mr3753846pji.75.1565104597750;
        Tue, 06 Aug 2019 08:16:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565104597; cv=none;
        d=google.com; s=arc-20160816;
        b=WFj0PJe7ttmga9y2pHJ+EHQY6vnnSfJjqGDHLp+iedhTXkJN80l53ixWNdxqOY3fLZ
         csVIog7YQrVd8LTS4bOPDNHYg4fwMicuQqkEHdk60uXdMa7m+lTaH6J0DS86wVJ+/gfz
         Xn3+1fBYaBRH/TJV0vHUuIZcyLunVrAtigNbbaUrQqZZv2CLlKrAeqHwVIr/HgANO9Sm
         /1A8arZf7i2nXHcCZExXuE7j0OMmbH+PNBbFn0A2vlf+/5FTb1drHNnyjgvYNsysvGjb
         T3MG5Iudrxu31BqpP8KLb54lFiHY3cj9tBOuGPZRVSI8OvazmvndRrqdWGiSeYYqVtuR
         S/4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=t5utYjK2IgovkZjkelguTsCtsgYZG52HIH6Pxqs1L48=;
        b=sWCLL/smxTCsgvks1lGKKOUlPwpSggAUPMQ3PGWppGPyoOaxuFmFenolc3oAmZXVys
         BKbLfB+ktqrVQDEDGRGuZ8ke4EHvLEWAq5SEqpH4Ed9VwGqv3VdPNQeat8ZVMUxxllpv
         ViLeyHaftmmOQN1PNCyWbJSfcgHTHgfvnyoQtfgjNvyElZ5iN4vh4mMGJcT+VD/DX/TF
         6YLoKJcZrNQJkBnkWllvx7Hu0TZ7UCPM4MuE30bJwqAYmWlNS/cieo7ynXH/rLEy+iOG
         Knp4t19b9Uto6s8DX5kRc8oAgYkywrHkVMrcjEirdLAX84DDaVCCLAZABGlOY3nJFkGx
         h6CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b18si48894560pgl.52.2019.08.06.08.16.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 08:16:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 08:16:37 -0700
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="185676339"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga002-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 08:16:36 -0700
Message-ID: <dcd778623685079f66bfccb5dc0195e6f5bc992d.camel@linux.intel.com>
Subject: Re: [PATCH v3 6/6] virtio-balloon: Add support for providing unused
 page reports to host
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com, pagupta@redhat.com, 
	riel@surriel.com, konrad.wilk@oracle.com, willy@infradead.org, 
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com, 
	pbonzini@redhat.com, dan.j.williams@intel.com
Date: Tue, 06 Aug 2019 08:16:36 -0700
In-Reply-To: <20190806073047-mutt-send-email-mst@kernel.org>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
	 <20190801223829.22190.36831.stgit@localhost.localdomain>
	 <1cff09a4-d302-639c-ab08-9d82e5fc1383@redhat.com>
	 <ed48ecdb833808bf6b08bc54fa98503cbad493f3.camel@linux.intel.com>
	 <20190806073047-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-08-06 at 07:31 -0400, Michael S. Tsirkin wrote:
> On Mon, Aug 05, 2019 at 09:27:16AM -0700, Alexander Duyck wrote:
> > On Mon, 2019-08-05 at 12:00 -0400, Nitesh Narayan Lal wrote:
> > > On 8/1/19 6:38 PM, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > Add support for the page reporting feature provided by virtio-balloon.
> > > > Reporting differs from the regular balloon functionality in that is is
> > > > much less durable than a standard memory balloon. Instead of creating a
> > > > list of pages that cannot be accessed the pages are only inaccessible
> > > > while they are being indicated to the virtio interface. Once the
> > > > interface has acknowledged them they are placed back into their respective
> > > > free lists and are once again accessible by the guest system.
> > > > 
> > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > ---
> > > >  drivers/virtio/Kconfig              |    1 +
> > > >  drivers/virtio/virtio_balloon.c     |   56 +++++++++++++++++++++++++++++++++++
> > > >  include/uapi/linux/virtio_balloon.h |    1 +
> > > >  3 files changed, 58 insertions(+)
> > > > 
> > > > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > > > index 078615cf2afc..4b2dd8259ff5 100644
> > > > --- a/drivers/virtio/Kconfig
> > > > +++ b/drivers/virtio/Kconfig
> > > > @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
> > > >  	tristate "Virtio balloon driver"
> > > >  	depends on VIRTIO
> > > >  	select MEMORY_BALLOON
> > > > +	select PAGE_REPORTING
> > > >  	---help---
> > > >  	 This driver supports increasing and decreasing the amount
> > > >  	 of memory within a KVM guest.
> > > > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > > > index 2c19457ab573..971fe924e34f 100644
> > > > --- a/drivers/virtio/virtio_balloon.c
> > > > +++ b/drivers/virtio/virtio_balloon.c
> > > > @@ -19,6 +19,7 @@
> > > >  #include <linux/mount.h>
> > > >  #include <linux/magic.h>
> > > >  #include <linux/pseudo_fs.h>
> > > > +#include <linux/page_reporting.h>
> > > >  
> > > >  /*
> > > >   * Balloon device works in 4K page units.  So each page is pointed to by
> > > > @@ -37,6 +38,9 @@
> > > >  #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
> > > >  	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
> > > >  
> > > > +/*  limit on the number of pages that can be on the reporting vq */
> > > > +#define VIRTIO_BALLOON_VRING_HINTS_MAX	16
> > > > +
> > > >  #ifdef CONFIG_BALLOON_COMPACTION
> > > >  static struct vfsmount *balloon_mnt;
> > > >  #endif
> > > > @@ -46,6 +50,7 @@ enum virtio_balloon_vq {
> > > >  	VIRTIO_BALLOON_VQ_DEFLATE,
> > > >  	VIRTIO_BALLOON_VQ_STATS,
> > > >  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> > > > +	VIRTIO_BALLOON_VQ_REPORTING,
> > > >  	VIRTIO_BALLOON_VQ_MAX
> > > >  };
> > > >  
> > > > @@ -113,6 +118,10 @@ struct virtio_balloon {
> > > >  
> > > >  	/* To register a shrinker to shrink memory upon memory pressure */
> > > >  	struct shrinker shrinker;
> > > > +
> > > > +	/* Unused page reporting device */
> > > > +	struct virtqueue *reporting_vq;
> > > > +	struct page_reporting_dev_info ph_dev_info;
> > > >  };
> > > >  
> > > >  static struct virtio_device_id id_table[] = {
> > > > @@ -152,6 +161,23 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> > > >  
> > > >  }
> > > >  
> > > > +void virtballoon_unused_page_report(struct page_reporting_dev_info *ph_dev_info,
> > > > +				    unsigned int nents)
> > > > +{
> > > > +	struct virtio_balloon *vb =
> > > > +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> > > > +	struct virtqueue *vq = vb->reporting_vq;
> > > > +	unsigned int unused;
> > > > +
> > > > +	/* We should always be able to add these buffers to an empty queue. */
> > > > +	virtqueue_add_inbuf(vq, ph_dev_info->sg, nents, vb,
> > > > +			    GFP_NOWAIT | __GFP_NOWARN);
> > > 
> > > I think you should handle allocation failure here. It is a possibility, isn't?
> > > Maybe return an error or even disable page hinting/reporting?
> > > 
> > 
> > I don't think it is an issue I have to worry about. Specifically I am
> > limiting the size of the scatterlist based on the size of the vq. As such
> > I will never exceed the size and should be able to use it to store the
> > scatterlist directly.
> 
> I agree. But it can't hurt to BUG_ON for good measure.
> 

I wouldn't use a BUG_ON as that seems overkill. No need to panic the
kernel just because we couldn't report some idle pages.

I can probably do something like:
	if (WARN_ON(err))
		return;

That way the unused page reporting can run to completion still and the
fact that we aren't really hinting on the pages would effectively be no
different then if we had a direct assigned device or shared memory in the
hypervisor.


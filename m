Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9D2EC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:59:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 962A8229F9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:59:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 962A8229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3277B8E0002; Thu, 25 Jul 2019 10:59:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D6766B026C; Thu, 25 Jul 2019 10:59:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C5B78E0002; Thu, 25 Jul 2019 10:59:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF3E46B026B
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:59:48 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k125so42499607qkc.12
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:59:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=Rmm6yLiguxnk1HEaBFpodRlU5b5ba8DS6Z2s5rRsdl0=;
        b=ICpYfiR6A5TzPRUGdE00HCGm/CQD2fFeZHYtirvJvi4wWxz4Kt4MAS41V8aT3LTPYH
         iY+9PeAVfzyrHlLKYWDieErjNcesA9Mu6ib8eLxsrFHI1AL/7hIHTuxoboX9sWTF+7zJ
         eGlR1QyaW037Rvbnnnkwxd9C6QHboA8hNmIC0+EUCRz99vazHSfYc4eW5DoKcbfG728B
         rZl+sYk71tAdLHoSUw/6nX8gttOG1uEpKW2HR3Z5oRBVfcOdeFBAy1wbXPbJ5Q9b3jyV
         fgRfESzkikQvAHb9uF8Wk5M5F7KNV0M0bF7JR8elm3OxFYNet3o9z0XfD5ds4FQ+qgCF
         puDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWn+Y/ALULx8YXpbQ8uZ56oq5/l7Gi+WM4kAp8AeEnIS2IGMSLg
	k6072ualbMtVsJnXDfEfMonwF6GL9tOwdvcEH+7uwHoOCzkzJf3aJCRVCx+SYLT13wVCvpGYYTe
	3atYjxvaKp+N0JY+IrLR8cLdSD+7zZC8O2obvcQX48LLi6Ysy2HHwkfSpzzmq2qywnQ==
X-Received: by 2002:a37:9b92:: with SMTP id d140mr57927412qke.443.1564066788732;
        Thu, 25 Jul 2019 07:59:48 -0700 (PDT)
X-Received: by 2002:a37:9b92:: with SMTP id d140mr57927378qke.443.1564066788114;
        Thu, 25 Jul 2019 07:59:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564066788; cv=none;
        d=google.com; s=arc-20160816;
        b=ypzspvoU69nGYhAteK8LXxjP24Bro/krOndl1mVZj5xDsLgy3zBtiOzUdrxkJThIZy
         ET0pt4N0yNRxXmOPkjpSksU9V2Q1EXy4RKU8LPDZDfbErMmUpRdsJ5WC22JTQRyHm/R2
         WZ+ThqR6+HPh/tYZJAaWDmE/OqqH8XsBWiAs016W4Bh/TfAOCpPGtkkC46kQDNw9hPVo
         do+j/dJPE47tknC5r+mBgeJnNnGgO4tc/1tyJDGAgP++Z/z7LzJs2+Roonr7nIIqio/y
         ayrIwLnwOn4QvxguESXkbqw3ewX9fjGxJ974BfgD3KgiCD204VECbA6kq2ENsjKVa8G2
         sgSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=Rmm6yLiguxnk1HEaBFpodRlU5b5ba8DS6Z2s5rRsdl0=;
        b=LO+P+9BkKwfp6udXAqPePVp4qJURA3nhq3RfEQdLQoBg3nGoUdPdkI72M42Z5BVXM5
         bnEzgkvbTp51OhKBKBil4apVvxi34aJ+HBrn4aQ2pbyBq8k4IaLO0e2lCxQFd4lz0qS+
         CeeIBkpZepPTfRrYFzYPO5DFikfF4lNKIpzMLEDRZIU1yDrs9pYZ9JimdudMBqTftaHW
         wq96RjuHGjvfH48IVVG0WHbwWZlZ79nKHBzKCnT06dOa/yF8rieLgvJw6mT37XX6NqBX
         4WGHH637tPbJFFLM5Au+e9kliTDlJQsLMFbIvF+KYCv+Gt+x6FCWTVZpftxwBIAuX5QF
         fP0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t7sor66395741qtr.14.2019.07.25.07.59.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 07:59:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzoIpindOeRtA1tCkHO4cy0qQv+nosyivtBgk+2pOYdPVUj3ArumomPLobNHAIjfwa4IloqWA==
X-Received: by 2002:ac8:3907:: with SMTP id s7mr64407808qtb.374.1564066787847;
        Thu, 25 Jul 2019 07:59:47 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id v75sm24506057qka.38.2019.07.25.07.59.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 07:59:47 -0700 (PDT)
Date: Thu, 25 Jul 2019 10:59:40 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
	david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2 5/5] virtio-balloon: Add support for providing page
 hints to host
Message-ID: <20190725105852-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724170514.6685.17161.stgit@localhost.localdomain>
 <20190724143902-mutt-send-email-mst@kernel.org>
 <21cc88cd-3577-e8b4-376f-26c7848f5764@redhat.com>
 <d75ba86f0cab44562148f3ffd66684c167952079.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d75ba86f0cab44562148f3ffd66684c167952079.camel@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 07:56:15AM -0700, Alexander Duyck wrote:
> On Thu, 2019-07-25 at 10:44 -0400, Nitesh Narayan Lal wrote:
> > On 7/24/19 3:02 PM, Michael S. Tsirkin wrote:
> > > On Wed, Jul 24, 2019 at 10:05:14AM -0700, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > Add support for the page hinting feature provided by virtio-balloon.
> > > > Hinting differs from the regular balloon functionality in that is is
> > > > much less durable than a standard memory balloon. Instead of creating a
> > > > list of pages that cannot be accessed the pages are only inaccessible
> > > > while they are being indicated to the virtio interface. Once the
> > > > interface has acknowledged them they are placed back into their respective
> > > > free lists and are once again accessible by the guest system.
> > > > 
> > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > Looking at the design, it seems that hinted pages can immediately be
> > > reused. I wonder how we can efficiently support this
> > > with kvm when poisoning is in effect. Of course we can just
> > > ignore the poison. However it seems cleaner to
> > > 1. verify page is poisoned with the correct value
> > > 2. fill the page with the correct value on fault
> > > 
> > > Requirement 2 requires some kind of madvise that
> > > will save the poison e.g. in the VMA.
> > > 
> > > Not a blocker for sure ... 
> > > 
> > > 
> > > > ---
> > > >  drivers/virtio/Kconfig              |    1 +
> > > >  drivers/virtio/virtio_balloon.c     |   47 +++++++++++++++++++++++++++++++++++
> > > >  include/uapi/linux/virtio_balloon.h |    1 +
> > > >  3 files changed, 49 insertions(+)
> > > > 
> > > > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > > > index 078615cf2afc..d45556ae1f81 100644
> > > > --- a/drivers/virtio/Kconfig
> > > > +++ b/drivers/virtio/Kconfig
> > > > @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
> > > >  	tristate "Virtio balloon driver"
> > > >  	depends on VIRTIO
> > > >  	select MEMORY_BALLOON
> > > > +	select PAGE_HINTING
> > > >  	---help---
> > > >  	 This driver supports increasing and decreasing the amount
> > > >  	 of memory within a KVM guest.
> > > > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > > > index 226fbb995fb0..dee9f8f3ad09 100644
> > > > --- a/drivers/virtio/virtio_balloon.c
> > > > +++ b/drivers/virtio/virtio_balloon.c
> > > > @@ -19,6 +19,7 @@
> > > >  #include <linux/mount.h>
> > > >  #include <linux/magic.h>
> > > >  #include <linux/pseudo_fs.h>
> > > > +#include <linux/page_hinting.h>
> > > >  
> > > >  /*
> > > >   * Balloon device works in 4K page units.  So each page is pointed to by
> > > > @@ -27,6 +28,7 @@
> > > >   */
> > > >  #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
> > > >  #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
> > > > +#define VIRTIO_BALLOON_ARRAY_HINTS_MAX	32
> > > >  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
> > > >  
> > > >  #define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
> > > > @@ -46,6 +48,7 @@ enum virtio_balloon_vq {
> > > >  	VIRTIO_BALLOON_VQ_DEFLATE,
> > > >  	VIRTIO_BALLOON_VQ_STATS,
> > > >  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> > > > +	VIRTIO_BALLOON_VQ_HINTING,
> > > >  	VIRTIO_BALLOON_VQ_MAX
> > > >  };
> > > >  
> > > > @@ -113,6 +116,10 @@ struct virtio_balloon {
> > > >  
> > > >  	/* To register a shrinker to shrink memory upon memory pressure */
> > > >  	struct shrinker shrinker;
> > > > +
> > > > +	/* Unused page hinting device */
> > > > +	struct virtqueue *hinting_vq;
> > > > +	struct page_hinting_dev_info ph_dev_info;
> > > >  };
> > > >  
> > > >  static struct virtio_device_id id_table[] = {
> > > > @@ -152,6 +159,22 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> > > >  
> > > >  }
> > > >  
> > > > +void virtballoon_page_hinting_react(struct page_hinting_dev_info *ph_dev_info,
> > > > +				    unsigned int num_hints)
> > > > +{
> > > > +	struct virtio_balloon *vb =
> > > > +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> > > > +	struct virtqueue *vq = vb->hinting_vq;
> > > > +	unsigned int unused;
> > > > +
> > > > +	/* We should always be able to add these buffers to an empty queue. */
> > > 
> > > can be an out of memory condition, and then ...
> > 
> > Do we need an error check here?
> > 
> > For situations where this fails we should disable hinting completely, maybe?
> 
> No. Instead I will just limit the capacity to no more than the vq size.
> Doing that should allow us to avoid the out of memory issue here if I am
> understanding things correctly.
> 
> I'm assuming the allocation being referred to is alloc_indirect_split(),
> if so then it looks like it can fail and then we just fall back to using
> the vring.desc directly which will work for my purposes as long as I limit
> the capacity of the scatterlist to no more than the size of the vring.
> 


Right. And maybe tweak the GFP mask - no reason to try to
allocate memory aggressively with just 1 element in flight.

> 


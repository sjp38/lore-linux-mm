Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46845C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:56:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AFEA21734
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:56:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AFEA21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A06306B0003; Thu, 25 Jul 2019 10:56:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B7748E0002; Thu, 25 Jul 2019 10:56:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87FEA6B026C; Thu, 25 Jul 2019 10:56:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51B406B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:56:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 191so31026193pfy.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:56:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=OqSdYLNp3QEtJFrfzpK5pNge56bxyGG+CtvF4Ygj4Hw=;
        b=eKHexgv1wZqnFEHtoef6JnVrZqX/N26qTkH/tV/1CQ6mGvMV/bvG31bOdtO4VCURnD
         Lzqyv1BHc1CgSkBR6h1Yr0vhOebmam5SF/TDIbdfxnoCYu0W/V2fZvSP058UTCoe2tZe
         azLYUjEG6pv5+/bXHHcGZJtwWNQMpATcbzwJUcL40KTSFTue3UDvceJo6nTzolaJlRdj
         I2ucmZmmlEmbtnXZvTQBRkggU1UFUEE73NQeMHqVlkP3sZy3XdTIPnxe3mVIeMpJAEX+
         YekjdvwAygxdhyON4eb5wfGmx4vO+e1sSTdiOSNaBlF3g+dd+YXC5aaPweRma7kK8keL
         Xxag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXVQJ8pwkoAUaragb+o08F69Vcpvlao8oeeENRPFDHaEwBeGyPU
	EKI8XDfdBRE074FwiInD1g1Zv7LXMP/4vYTQmw+jHqAR3KoW0+Q6HbdKaagHR7aFmDs7WJQO3oi
	oDugHbWX9LBKuYsIozYxIyy8D4ppaHvyQ5KucFi6MMv9YEuXQO2CM3NRvinhttfFWWQ==
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr93685891plb.158.1564066576970;
        Thu, 25 Jul 2019 07:56:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLWGI4yGGDiC/6ZzArcApprzW6RFW6Tpjti02O/RfcVymDYnQnw5XKbL2Qnx5wPwuWs+fm
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr93685859plb.158.1564066576285;
        Thu, 25 Jul 2019 07:56:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564066576; cv=none;
        d=google.com; s=arc-20160816;
        b=Jv2QKduxd09xl/acy6Bc4n1RDmeO3BbcFVFJxNGzikK7rEBIYqlXU2vZ15UwYv2sZ9
         v8YLQw87t+2aJBc95OVLWitTs0t0z2K4Jts+HS01/7WZ6BV2XibuzJqCl92jo6GOxJbU
         FaHUFzkM8o7CAgXkNt8hX8DSXnqm22yrqUe4Y+KTx2rrqfo06InLhXxUaiQ+2A7OXzsG
         dU0SAgZ19Vx2VjgCpaqAAUWZ0wKn8xpqd488RA/j5un3IOiF8Fd7pDwDQAeb+cKJCrC7
         LheUNOqJmljiAijjAxHsiWV8V05hxinQyE+6lUUDtr4kqEx9nJkHTtgroBVmRyJpRag+
         2J6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=OqSdYLNp3QEtJFrfzpK5pNge56bxyGG+CtvF4Ygj4Hw=;
        b=vUP6jjvlv82237bB528CARydGMrS2Hq4au5PI6O91oQPddhXtYB5ovi2jU0TiYn5vX
         UDe6EWc6NACBxvdxZngsDR8iRxgFgrzlBNAv+KcrlqV5hjL/GAA3E3/VZqdXpfDSWE4I
         KyrICYCLW2BDPafW1/odrRQ/hIkzIWdbhJX7Zu13Ob9MSpEx588HWykT/qhl9bKFd7Qc
         5W64ROhg4e9PN9CIGkFU1ZVTy10kaloD61k5OV1OcBtc2uF5DpzeAoShAkVavIOZmWPp
         HgirJhjtnfoKyW9L9Tnr0hD6V2/gyE3WX5EZ/LX/j8glPo2vfD2oUBgroTWp6Y/Q5Odw
         APKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id cl7si17787726plb.267.2019.07.25.07.56.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 07:56:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 07:56:15 -0700
X-IronPort-AV: E=Sophos;i="5.64,307,1559545200"; 
   d="scan'208";a="321687109"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga004-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 07:56:15 -0700
Message-ID: <d75ba86f0cab44562148f3ffd66684c167952079.camel@linux.intel.com>
Subject: Re: [PATCH v2 5/5] virtio-balloon: Add support for providing page
 hints to host
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, "Michael S. Tsirkin"
	 <mst@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com, 
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org,  yang.zhang.wz@gmail.com, pagupta@redhat.com,
 riel@surriel.com,  konrad.wilk@oracle.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com,  aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com
Date: Thu, 25 Jul 2019 07:56:15 -0700
In-Reply-To: <21cc88cd-3577-e8b4-376f-26c7848f5764@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724170514.6685.17161.stgit@localhost.localdomain>
	 <20190724143902-mutt-send-email-mst@kernel.org>
	 <21cc88cd-3577-e8b4-376f-26c7848f5764@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-25 at 10:44 -0400, Nitesh Narayan Lal wrote:
> On 7/24/19 3:02 PM, Michael S. Tsirkin wrote:
> > On Wed, Jul 24, 2019 at 10:05:14AM -0700, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > Add support for the page hinting feature provided by virtio-balloon.
> > > Hinting differs from the regular balloon functionality in that is is
> > > much less durable than a standard memory balloon. Instead of creating a
> > > list of pages that cannot be accessed the pages are only inaccessible
> > > while they are being indicated to the virtio interface. Once the
> > > interface has acknowledged them they are placed back into their respective
> > > free lists and are once again accessible by the guest system.
> > > 
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > Looking at the design, it seems that hinted pages can immediately be
> > reused. I wonder how we can efficiently support this
> > with kvm when poisoning is in effect. Of course we can just
> > ignore the poison. However it seems cleaner to
> > 1. verify page is poisoned with the correct value
> > 2. fill the page with the correct value on fault
> > 
> > Requirement 2 requires some kind of madvise that
> > will save the poison e.g. in the VMA.
> > 
> > Not a blocker for sure ... 
> > 
> > 
> > > ---
> > >  drivers/virtio/Kconfig              |    1 +
> > >  drivers/virtio/virtio_balloon.c     |   47 +++++++++++++++++++++++++++++++++++
> > >  include/uapi/linux/virtio_balloon.h |    1 +
> > >  3 files changed, 49 insertions(+)
> > > 
> > > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > > index 078615cf2afc..d45556ae1f81 100644
> > > --- a/drivers/virtio/Kconfig
> > > +++ b/drivers/virtio/Kconfig
> > > @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
> > >  	tristate "Virtio balloon driver"
> > >  	depends on VIRTIO
> > >  	select MEMORY_BALLOON
> > > +	select PAGE_HINTING
> > >  	---help---
> > >  	 This driver supports increasing and decreasing the amount
> > >  	 of memory within a KVM guest.
> > > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > > index 226fbb995fb0..dee9f8f3ad09 100644
> > > --- a/drivers/virtio/virtio_balloon.c
> > > +++ b/drivers/virtio/virtio_balloon.c
> > > @@ -19,6 +19,7 @@
> > >  #include <linux/mount.h>
> > >  #include <linux/magic.h>
> > >  #include <linux/pseudo_fs.h>
> > > +#include <linux/page_hinting.h>
> > >  
> > >  /*
> > >   * Balloon device works in 4K page units.  So each page is pointed to by
> > > @@ -27,6 +28,7 @@
> > >   */
> > >  #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
> > >  #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
> > > +#define VIRTIO_BALLOON_ARRAY_HINTS_MAX	32
> > >  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
> > >  
> > >  #define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
> > > @@ -46,6 +48,7 @@ enum virtio_balloon_vq {
> > >  	VIRTIO_BALLOON_VQ_DEFLATE,
> > >  	VIRTIO_BALLOON_VQ_STATS,
> > >  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> > > +	VIRTIO_BALLOON_VQ_HINTING,
> > >  	VIRTIO_BALLOON_VQ_MAX
> > >  };
> > >  
> > > @@ -113,6 +116,10 @@ struct virtio_balloon {
> > >  
> > >  	/* To register a shrinker to shrink memory upon memory pressure */
> > >  	struct shrinker shrinker;
> > > +
> > > +	/* Unused page hinting device */
> > > +	struct virtqueue *hinting_vq;
> > > +	struct page_hinting_dev_info ph_dev_info;
> > >  };
> > >  
> > >  static struct virtio_device_id id_table[] = {
> > > @@ -152,6 +159,22 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> > >  
> > >  }
> > >  
> > > +void virtballoon_page_hinting_react(struct page_hinting_dev_info *ph_dev_info,
> > > +				    unsigned int num_hints)
> > > +{
> > > +	struct virtio_balloon *vb =
> > > +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> > > +	struct virtqueue *vq = vb->hinting_vq;
> > > +	unsigned int unused;
> > > +
> > > +	/* We should always be able to add these buffers to an empty queue. */
> > 
> > can be an out of memory condition, and then ...
> 
> Do we need an error check here?
> 
> For situations where this fails we should disable hinting completely, maybe?

No. Instead I will just limit the capacity to no more than the vq size.
Doing that should allow us to avoid the out of memory issue here if I am
understanding things correctly.

I'm assuming the allocation being referred to is alloc_indirect_split(),
if so then it looks like it can fail and then we just fall back to using
the vring.desc directly which will work for my purposes as long as I limit
the capacity of the scatterlist to no more than the size of the vring.





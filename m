Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3378FC76194
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:26:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E60A322ADB
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:26:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E60A322ADB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81CB26B0006; Wed, 24 Jul 2019 15:26:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F3EB8E0002; Wed, 24 Jul 2019 15:26:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7093E6B0008; Wed, 24 Jul 2019 15:26:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA416B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:26:32 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q26so42452840qtr.3
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:26:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=hA+7cXTZvKB0lrb7iuAd//3uxxBDZMaqYXLy6i/gDpw=;
        b=e/jK3YfTR2XlGdxFg+z+gJypI22H3WEcTBWM48rD/nzQU4K7yqzl+NDY3m+pkFHEog
         kLBK6Gd63Q7uY3PduPY92S4nLjHT2pPPOIMx6J+AbTWafXY+m9vlclKPd2OweyDTSfpN
         leI93Up081Cmg016ZGkTYpGoE/Oan3/kIKWAch95ue13aq0ktq3b4Cr4BDICfNSXzNQF
         16zF3z6NGGmmg+2Mz7ryiXI1MocMiJkvlhK4w3v0jD7lH9+uA5KYN3OhT9AWELTjNTU/
         1v9Vi/8VkCS7i8NIp+0z8t1rPBJ/eVoglD5xKOL92P6zevNpCxIRDPH0WnUiy0Q4mx/q
         NqYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUYZkOXGUp1jGEtKYsIbQOeH/TB5QCOZVyEXALkZs358fDxa20O
	lTRCqRIW699gYzpPMi5AK4Czj56l/0xy5L5Pir98yCpbMn+PxrrhuXZSsssd+Phswk7aHlRe1CQ
	EiitqJo4ubuWklroHNLWZFiWGlnjIp+FymYMEEv5PFlhm7zJCt5PWtyxVGV0A6YEpIA==
X-Received: by 2002:a0c:b148:: with SMTP id r8mr59007997qvc.240.1563996392049;
        Wed, 24 Jul 2019 12:26:32 -0700 (PDT)
X-Received: by 2002:a0c:b148:: with SMTP id r8mr59007973qvc.240.1563996391289;
        Wed, 24 Jul 2019 12:26:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563996391; cv=none;
        d=google.com; s=arc-20160816;
        b=UJs/NKCtE3J6z1sbNJzCnJjfqBAv5ZbwiCDygDb2PxF+KMCiP4xzQdLgDzD1RM2tSe
         pifcNfevnw8awcRzoYfSO59W0xfE+KqoXLOW3Q4S2pmZDftlEhOWRbXdVgeIeTumUbt+
         DO9Gf0aq7XcDWJU8U5jX0+FghTePJn2odM16nnnpHFs15SoPQmeb95qAzJMWwp+uTCnz
         w6DuhUFkpbP7RmsT093b5QTj8TEqlYSZAoEMVhiLXveZgqImORuekWDY4FqbE2jANU8R
         aIEK6/DxAkOPDcgNmkYrRIZY3zrZUjSDBJxdEVQjbc6z9tRtMv5Lbq6b9oCUn8600/df
         nlng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=hA+7cXTZvKB0lrb7iuAd//3uxxBDZMaqYXLy6i/gDpw=;
        b=MLWrCWBR+deCe8VEYK3I7kqVKW4ge7W+EdGdkZQVNqqqw0iZOdVYDwefOv5GgCEZFk
         78sdO7CN70Z7D+bLApXuTeSZJ4Wb0eLkfPnqSzlLtn1tcZaKLjwNjeNcW0Md/xfB1GUr
         Lz+2SJc/qzRD8HB/qAlABt+D+z/haTBciyPlvxIxTDDxZL8Fe7HgT7zmT8lWpsgZrS9N
         oLN5ZfvIXxS3jQoC1rF8NyJpBtT5SHjvT5XtN6iCKCsp25DeoeWXB5mfZwykS5zEv6dt
         OF+A3sM2zcWAVGwkOwVhen01MCZa7wPS9ABTBRbXAOHYgTJb81QAMWGpn+5Sh55ukB9R
         zwew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4sor26654813qkf.164.2019.07.24.12.26.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:26:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzXX12FV0NR/wa2f9ui/1wQP7z1Ww1JuHGRLxmESSJAT2qlUM8jIdt12JuSwylbDC/TNmifRA==
X-Received: by 2002:ae9:f017:: with SMTP id l23mr55791769qkg.457.1563996390930;
        Wed, 24 Jul 2019 12:26:30 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id u1sm26309762qth.21.2019.07.24.12.26.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 12:26:30 -0700 (PDT)
Date: Wed, 24 Jul 2019 15:26:23 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
	david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com,
	alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v2 5/5] virtio-balloon: Add support for providing page
 hints to host
Message-ID: <20190724152501-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724170514.6685.17161.stgit@localhost.localdomain>
 <20190724143902-mutt-send-email-mst@kernel.org>
 <33e41a02-7a9c-f166-8eb3-50abacb9d2cc@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33e41a02-7a9c-f166-8eb3-50abacb9d2cc@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 03:07:42PM -0400, Nitesh Narayan Lal wrote:
> 
> On 7/24/19 3:02 PM, Michael S. Tsirkin wrote:
> > On Wed, Jul 24, 2019 at 10:05:14AM -0700, Alexander Duyck wrote:
> >> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >>
> >> Add support for the page hinting feature provided by virtio-balloon.
> >> Hinting differs from the regular balloon functionality in that is is
> >> much less durable than a standard memory balloon. Instead of creating a
> >> list of pages that cannot be accessed the pages are only inaccessible
> >> while they are being indicated to the virtio interface. Once the
> >> interface has acknowledged them they are placed back into their respective
> >> free lists and are once again accessible by the guest system.
> >>
> >> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > Looking at the design, it seems that hinted pages can immediately be
> > reused. I wonder how we can efficiently support this
> > with kvm when poisoning is in effect. Of course we can just
> > ignore the poison. However it seems cleaner to
> > 1. verify page is poisoned with the correct value
> > 2. fill the page with the correct value on fault
> Once VIRTIO_BALLOON_F_PAGE_POISON user side support is available.
> Can't we just use that at the time of initialization?

ATM VIRTIO_BALLOON_F_PAGE_POISON simply avoids freeing the pages at the
moment.

1+2 above are exactly a way to implement VIRTIO_BALLOON_F_PAGE_POISON
such that will still bring performance gains.

> > Requirement 2 requires some kind of madvise that
> > will save the poison e.g. in the VMA.
> >
> > Not a blocker for sure ... 
> >
> >
> >> ---
> >>  drivers/virtio/Kconfig              |    1 +
> >>  drivers/virtio/virtio_balloon.c     |   47 +++++++++++++++++++++++++++++++++++
> >>  include/uapi/linux/virtio_balloon.h |    1 +
> >>  3 files changed, 49 insertions(+)
> >>
> >> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> >> index 078615cf2afc..d45556ae1f81 100644
> >> --- a/drivers/virtio/Kconfig
> >> +++ b/drivers/virtio/Kconfig
> >> @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
> >>  	tristate "Virtio balloon driver"
> >>  	depends on VIRTIO
> >>  	select MEMORY_BALLOON
> >> +	select PAGE_HINTING
> >>  	---help---
> >>  	 This driver supports increasing and decreasing the amount
> >>  	 of memory within a KVM guest.
> >> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> >> index 226fbb995fb0..dee9f8f3ad09 100644
> >> --- a/drivers/virtio/virtio_balloon.c
> >> +++ b/drivers/virtio/virtio_balloon.c
> >> @@ -19,6 +19,7 @@
> >>  #include <linux/mount.h>
> >>  #include <linux/magic.h>
> >>  #include <linux/pseudo_fs.h>
> >> +#include <linux/page_hinting.h>
> >>  
> >>  /*
> >>   * Balloon device works in 4K page units.  So each page is pointed to by
> >> @@ -27,6 +28,7 @@
> >>   */
> >>  #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
> >>  #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
> >> +#define VIRTIO_BALLOON_ARRAY_HINTS_MAX	32
> >>  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
> >>  
> >>  #define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
> >> @@ -46,6 +48,7 @@ enum virtio_balloon_vq {
> >>  	VIRTIO_BALLOON_VQ_DEFLATE,
> >>  	VIRTIO_BALLOON_VQ_STATS,
> >>  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> >> +	VIRTIO_BALLOON_VQ_HINTING,
> >>  	VIRTIO_BALLOON_VQ_MAX
> >>  };
> >>  
> >> @@ -113,6 +116,10 @@ struct virtio_balloon {
> >>  
> >>  	/* To register a shrinker to shrink memory upon memory pressure */
> >>  	struct shrinker shrinker;
> >> +
> >> +	/* Unused page hinting device */
> >> +	struct virtqueue *hinting_vq;
> >> +	struct page_hinting_dev_info ph_dev_info;
> >>  };
> >>  
> >>  static struct virtio_device_id id_table[] = {
> >> @@ -152,6 +159,22 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> >>  
> >>  }
> >>  
> >> +void virtballoon_page_hinting_react(struct page_hinting_dev_info *ph_dev_info,
> >> +				    unsigned int num_hints)
> >> +{
> >> +	struct virtio_balloon *vb =
> >> +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> >> +	struct virtqueue *vq = vb->hinting_vq;
> >> +	unsigned int unused;
> >> +
> >> +	/* We should always be able to add these buffers to an empty queue. */
> >
> > can be an out of memory condition, and then ...
> >
> >> +	virtqueue_add_inbuf(vq, ph_dev_info->sg, num_hints, vb, GFP_KERNEL);
> >> +	virtqueue_kick(vq);
> > ... this will block forever.
> >
> >> +	/* When host has read buffer, this completes via balloon_ack */
> >> +	wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
> > However below I suggest limiting capacity which will solve
> > this problem for you.
> >
> >
> >
> >> +}
> >> +
> >>  static void set_page_pfns(struct virtio_balloon *vb,
> >>  			  __virtio32 pfns[], struct page *page)
> >>  {
> >> @@ -476,6 +499,7 @@ static int init_vqs(struct virtio_balloon *vb)
> >>  	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
> >>  	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
> >>  	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> >> +	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
> >>  
> >>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> >>  		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> >> @@ -487,11 +511,19 @@ static int init_vqs(struct virtio_balloon *vb)
> >>  		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> >>  	}
> >>  
> >> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> >> +		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
> >> +		callbacks[VIRTIO_BALLOON_VQ_HINTING] = balloon_ack;
> >> +	}
> >> +
> >>  	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
> >>  					 vqs, callbacks, names, NULL, NULL);
> >>  	if (err)
> >>  		return err;
> >>  
> >> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> >> +		vb->hinting_vq = vqs[VIRTIO_BALLOON_VQ_HINTING];
> >> +
> >>  	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
> >>  	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
> >>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> >> @@ -924,12 +956,24 @@ static int virtballoon_probe(struct virtio_device *vdev)
> >>  		if (err)
> >>  			goto out_del_balloon_wq;
> >>  	}
> >> +
> >> +	vb->ph_dev_info.react = virtballoon_page_hinting_react;
> >> +	vb->ph_dev_info.capacity = VIRTIO_BALLOON_ARRAY_HINTS_MAX;
> > As explained above I think you should limit this by vq size.
> > Otherwise virtqueue add buf might fail.
> > In fact by struct spec reading you need to limit it
> > anyway otherwise it will fail unconditionally.
> > In practice on most hypervisors it will typically work ...
> >
> >> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> >> +		err = page_hinting_startup(&vb->ph_dev_info);
> >> +		if (err)
> >> +			goto out_unregister_shrinker;
> >> +	}
> >> +
> >>  	virtio_device_ready(vdev);
> >>  
> >>  	if (towards_target(vb))
> >>  		virtballoon_changed(vdev);
> >>  	return 0;
> >>  
> >> +out_unregister_shrinker:
> >> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> >> +		virtio_balloon_unregister_shrinker(vb);
> >>  out_del_balloon_wq:
> >>  	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
> >>  		destroy_workqueue(vb->balloon_wq);
> >> @@ -958,6 +1002,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
> >>  {
> >>  	struct virtio_balloon *vb = vdev->priv;
> >>  
> >> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> >> +		page_hinting_shutdown(&vb->ph_dev_info);
> >>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> >>  		virtio_balloon_unregister_shrinker(vb);
> >>  	spin_lock_irq(&vb->stop_update_lock);
> >> @@ -1027,6 +1073,7 @@ static int virtballoon_validate(struct virtio_device *vdev)
> >>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> >>  	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
> >>  	VIRTIO_BALLOON_F_PAGE_POISON,
> >> +	VIRTIO_BALLOON_F_HINTING,
> >>  };
> >>  
> >>  static struct virtio_driver virtio_balloon_driver = {
> >> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> >> index a1966cd7b677..2b0f62814e22 100644
> >> --- a/include/uapi/linux/virtio_balloon.h
> >> +++ b/include/uapi/linux/virtio_balloon.h
> >> @@ -36,6 +36,7 @@
> >>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> >>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
> >>  #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
> >> +#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
> >>  
> >>  /* Size of a PFN in the balloon interface. */
> >>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> -- 
> Thanks
> Nitesh


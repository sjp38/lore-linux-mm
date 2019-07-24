Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96F8FC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:43:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45054217F4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:43:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45054217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC0CE8E000B; Wed, 24 Jul 2019 16:43:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E70BF8E0002; Wed, 24 Jul 2019 16:43:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D620C8E000B; Wed, 24 Jul 2019 16:43:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4F188E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:43:48 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c79so40508222qkg.13
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:43:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=6mbl4cvFr3tkTjHYbLZEhboHXxucjTz00G95IPubTjg=;
        b=a0YYYQEm/ug5x2hrl1fcbR4fkRJWM+6iGhzUeCDHQVDb+DTuY/jV3yxIlIc2OjdBd+
         LiUG8MHfaSumORSrTPclhbgIMYgtZDc1bTxvaGA+QVkkyuCMqV7jO3k31YAjgPCvbnmQ
         ei2L/6z8OyrlvMo73PM5DIjjjW/6NHAuB0cfn1psRxnMYPwiLGzcDaXhYIKqq/AuO5hf
         A+U3cVbN0Lt9xjJ7hFLC2T96BNf5z3oCyAMPKVicg74DG178qVFnzJ9aXeITbIEL8hmM
         L7RIP8xLaHni1nriEjOOmxL85sA1yOnZtbxtcaKPhwbkNl9Qbaxg6R3UEOd2X4HMKzhU
         DOYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXyTLAjKTcBcggbwB4PZI9AUYEPE8AZuD1MepsZFjZ3Cdv2K3bm
	Tc/7rkbBADvYG2+EEfvCS0mhD1QbGdwo1vWZgp3UyNTuhOT6+8M5/QiGTgc+H6/UQ8pNuCPSuob
	QjjvdaGIYfr0n1A3UZh3jbTHTvU6NqPMqcxymC3omc6elYRfeQp0xrZetJ1oCXOZOdg==
X-Received: by 2002:a05:620a:12d2:: with SMTP id e18mr55273544qkl.176.1564001028478;
        Wed, 24 Jul 2019 13:43:48 -0700 (PDT)
X-Received: by 2002:a05:620a:12d2:: with SMTP id e18mr55273513qkl.176.1564001027675;
        Wed, 24 Jul 2019 13:43:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564001027; cv=none;
        d=google.com; s=arc-20160816;
        b=SXR6D0iJN2rU6zwVPgVROKlO+EMdsBpO73jMyTXkJ2T5VWNn9TYjcxlizYE3kW0Vnb
         AQ7SSN+zNXXw/OTOH06U1q5boWt2LypJVO0MGEBfnJHrmMiMFMzu2FZV8KzBSId+Ywh4
         FPQe9V2HJMJK0NRlu/Waw3gEISBb+aLBR7WVvySHJkrhD1dRJioBvRSTUr1Ol145Y5aV
         rRg6rcGPDHNmEuQwMUz1Dlt/Ejo28NpWpHVWr9WKNGU0MZPFhXcS+yJa0r51DgQMei9s
         4y87Imxx0fiEICZIAemG8g6IZL9e35CNkoWXzsUrJ1sTvftd8t/aH2benTomce+zqyRs
         4yXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=6mbl4cvFr3tkTjHYbLZEhboHXxucjTz00G95IPubTjg=;
        b=lqqQXyQELR57/kxuXXYt07KdIp7NWzNAiZTWotronYl+ODPr/JL/260ah1wg49bjWW
         0k7fkFtLiM1gYtH+/SxCvE94NSzWoPbEcn5ocIntgm7RHJWYC5cJcW7ULqXFUdgMBH48
         xQOT4ywkL6z8Z8+X7/aKLLNW5tOyynyZYUU6azpZU4wl1Z4RnL6v66+xZD+xqaolO4n7
         1n5n5ljXOKfGX+UFvHF/wIf8WTtLSlqZkqSKENl6aRF2yn4BjZRF48gxxyoeKbq5mhMu
         3suGAs0YcaBjh75baeMq9fKFOdUTiAMNMALmibVGFPSMvPSPnktT8dG328HZzdKi7c6v
         QUcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor62834434qto.35.2019.07.24.13.43.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 13:43:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw/Agvw8u+t/A78ymyyv+/eCo+7Y7048LFfCzvyrKDR0GjDoyB+OnJ2DXh8w0hKvdfUxgL4oQ==
X-Received: by 2002:ac8:6717:: with SMTP id e23mr56079941qtp.27.1564001027399;
        Wed, 24 Jul 2019 13:43:47 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id b23sm29124888qte.19.2019.07.24.13.43.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 13:43:46 -0700 (PDT)
Date: Wed, 24 Jul 2019 16:43:39 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
	kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2 5/5] virtio-balloon: Add support for providing page
 hints to host
Message-ID: <20190724164255-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724170514.6685.17161.stgit@localhost.localdomain>
 <20190724143902-mutt-send-email-mst@kernel.org>
 <e11ba530cda97d3cc8efaeb105290cfe32db6cba.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e11ba530cda97d3cc8efaeb105290cfe32db6cba.camel@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 01:37:47PM -0700, Alexander Duyck wrote:
> On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
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
> > 
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
> 
> As per our discussion in the other patch I agree that we should either
> ignore the hint/report if page poisoning is enabled, or page poisoning
> should result in us poisoning the page when it is faulted back in. I had
> assumed we were doing the latter, I didn't realize that is was just
> disabling the free page hinting.

In fact I see that the latest versions of qemu don't seem to do
the later either. Need to fix that ASAP...


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
> > 
> > > +	virtqueue_add_inbuf(vq, ph_dev_info->sg, num_hints, vb, GFP_KERNEL);
> > > +	virtqueue_kick(vq);
> > 
> > ... this will block forever.
> > 
> > > +	/* When host has read buffer, this completes via balloon_ack */
> > > +	wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
> > 
> > However below I suggest limiting capacity which will solve
> > this problem for you.
> 
> I wasn't aware that virtqueue_add_inbuf actually performed an allocation.
> 
> > > +}
> > > +
> > >  static void set_page_pfns(struct virtio_balloon *vb,
> > >  			  __virtio32 pfns[], struct page *page)
> > >  {
> > > @@ -476,6 +499,7 @@ static int init_vqs(struct virtio_balloon *vb)
> > >  	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
> > >  	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
> > >  	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> > > +	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
> > >  
> > >  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > >  		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> > > @@ -487,11 +511,19 @@ static int init_vqs(struct virtio_balloon *vb)
> > >  		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> > >  	}
> > >  
> > > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> > > +		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
> > > +		callbacks[VIRTIO_BALLOON_VQ_HINTING] = balloon_ack;
> > > +	}
> > > +
> > >  	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
> > >  					 vqs, callbacks, names, NULL, NULL);
> > >  	if (err)
> > >  		return err;
> > >  
> > > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> > > +		vb->hinting_vq = vqs[VIRTIO_BALLOON_VQ_HINTING];
> > > +
> > >  	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
> > >  	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
> > >  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > > @@ -924,12 +956,24 @@ static int virtballoon_probe(struct virtio_device *vdev)
> > >  		if (err)
> > >  			goto out_del_balloon_wq;
> > >  	}
> > > +
> > > +	vb->ph_dev_info.react = virtballoon_page_hinting_react;
> > > +	vb->ph_dev_info.capacity = VIRTIO_BALLOON_ARRAY_HINTS_MAX;
> > 
> > As explained above I think you should limit this by vq size.
> > Otherwise virtqueue add buf might fail.
> > In fact by struct spec reading you need to limit it
> > anyway otherwise it will fail unconditionally.
> > In practice on most hypervisors it will typically work ...
> 
> So I would just need to query that via the virtqueue_get_vring_size
> function correct? I could probably just set capacity to the minimum of the
> HINTS_MAX and that value right?
> 
> 


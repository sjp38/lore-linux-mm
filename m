Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E7B0C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:37:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2DB6217F4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:37:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2DB6217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5505E8E0007; Wed, 24 Jul 2019 16:37:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5010B8E0002; Wed, 24 Jul 2019 16:37:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C9708E0007; Wed, 24 Jul 2019 16:37:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 049908E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:37:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s21so24783676plr.2
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=yatPCdn9kIGsFHU0tpFd+Z2qlyQUBv0oLEbeEUXg67I=;
        b=bbfFkFPX5E0XU97h/UsJ+HQ7zSxBS4YZqaWOnH++ERGBhLbAYv8DRiWFNTEbau/PyC
         UxYYFwYtK9ZIj/IGw2xOaLtT+DBxhhfwA0aOiNVnwyu4+m+BsU4gLbL7rEIeATH/9B7V
         +trxWFySX4SerGdVapVKgV102BwOpQSHTf6//3lmU0ylzf5YJeVQIauSVMbKH6w/YuPf
         hXqmZqgxSDw7VnfenVA0PaczjEaiS6mSI90HZbBMboBqfWTqykUCAUYKPXveBYEv5wVr
         CGSOcDiRWu30jNHRIjhJmMmPUKrO910IiS26f3SFd7WbjrmpoDOJoZrCag0Qyr1IswVX
         h79w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW7BLdHLDJ23ldAor+hHWUe0gBV2zLnXMPqR74TNLi4qKtKbF4t
	sCAlFcDe9a/Y1KLHcL4o5R9tsh/ylpc/3CQSa2ISO1JhWzyXMjlaJnXPnmiTBo6aTUHBQ93qBcy
	glJd95w0nk/hIxxi5vA2AOlelGWjeUvjqs4NBhsolgHuiw9WzsyK2PCrfuw6FvAwxQw==
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr86930902plt.152.1564000669577;
        Wed, 24 Jul 2019 13:37:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRicYvPgC+bkzYh9eQ3QP1Gt22gUpjHYSowz77KyKoAMMzz7WA0N4ihMoqDNpfq5he6WJ2
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr86930861plt.152.1564000668769;
        Wed, 24 Jul 2019 13:37:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564000668; cv=none;
        d=google.com; s=arc-20160816;
        b=cYdxeTU/EdNOdb+qS1KVvf/pep/OSFHXUsxbW+WQ05K0p9bp+jLgSm1ck/JUxn/wRj
         fpGbrL1Q8VXW+SVG1rfEjX6CyPKF3TkiKMjrI9CvVJuPPFMgcV+C+wWl8v0WbxtgAgwd
         VcfcaHXv/RHGcssVTl9s5vGuWlil3wa0r1VWuQIoUL62bujjOQ+zmDNAK80cT0T/fYlx
         7gLuRpqC1iCQeU9VdgX9wzg3KTD7nki0nTQUBnqe4/1HTiIiCGSeETMnLpR83aaiV9Vm
         G0mx+saKreFIL+jCM+6UPji0ZXRAXZAtlmxC89JGUbPSjtqb3yU0PjiimOUlQfIR86bK
         z+rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=yatPCdn9kIGsFHU0tpFd+Z2qlyQUBv0oLEbeEUXg67I=;
        b=MN3Fqy1w1JQUB1QLmSM2PWTrJu3/bbph/g/Z/IgWBUnbbpSPFjqEf3mhVXl9WTZ2cX
         FfGL6I1ct/smerfnUTl42CVISSyKSye9zi+wswZoZd4JssaTcB4EQ6dHs+WbSdU8l/Wu
         N1BBEFP0f+lPtrjjI9+v2++DYxmoyMcimaK7TJJM7nMTAmTcrqY9JxTDgRqVOjtu46T2
         9v2xUIGA6Zjl5jn1EOU0NFju39bCxnU899db7e3GzVvFWnwmLbSULt6EBYzRd/X4hKOq
         OP4p4MqdEciB2XtTtTmZVYN96GPNcLu/eOX1BEGIlWXt5Vhb5DzzTL4/og0hEn1BqUV2
         vcgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z185si14469520pfz.248.2019.07.24.13.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 13:37:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 13:37:48 -0700
X-IronPort-AV: E=Sophos;i="5.64,304,1559545200"; 
   d="scan'208";a="160685252"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga007-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 13:37:47 -0700
Message-ID: <e11ba530cda97d3cc8efaeb105290cfe32db6cba.camel@linux.intel.com>
Subject: Re: [PATCH v2 5/5] virtio-balloon: Add support for providing page
 hints to host
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, 
	dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com, pagupta@redhat.com, 
	riel@surriel.com, konrad.wilk@oracle.com, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com, 
	dan.j.williams@intel.com
Date: Wed, 24 Jul 2019 13:37:47 -0700
In-Reply-To: <20190724143902-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724170514.6685.17161.stgit@localhost.localdomain>
	 <20190724143902-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
> On Wed, Jul 24, 2019 at 10:05:14AM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Add support for the page hinting feature provided by virtio-balloon.
> > Hinting differs from the regular balloon functionality in that is is
> > much less durable than a standard memory balloon. Instead of creating a
> > list of pages that cannot be accessed the pages are only inaccessible
> > while they are being indicated to the virtio interface. Once the
> > interface has acknowledged them they are placed back into their respective
> > free lists and are once again accessible by the guest system.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Looking at the design, it seems that hinted pages can immediately be
> reused. I wonder how we can efficiently support this
> with kvm when poisoning is in effect. Of course we can just
> ignore the poison. However it seems cleaner to
> 1. verify page is poisoned with the correct value
> 2. fill the page with the correct value on fault
> 
> Requirement 2 requires some kind of madvise that
> will save the poison e.g. in the VMA.
> 
> Not a blocker for sure ... 

As per our discussion in the other patch I agree that we should either
ignore the hint/report if page poisoning is enabled, or page poisoning
should result in us poisoning the page when it is faulted back in. I had
assumed we were doing the latter, I didn't realize that is was just
disabling the free page hinting.

> > ---
> >  drivers/virtio/Kconfig              |    1 +
> >  drivers/virtio/virtio_balloon.c     |   47 +++++++++++++++++++++++++++++++++++
> >  include/uapi/linux/virtio_balloon.h |    1 +
> >  3 files changed, 49 insertions(+)
> > 
> > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > index 078615cf2afc..d45556ae1f81 100644
> > --- a/drivers/virtio/Kconfig
> > +++ b/drivers/virtio/Kconfig
> > @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
> >  	tristate "Virtio balloon driver"
> >  	depends on VIRTIO
> >  	select MEMORY_BALLOON
> > +	select PAGE_HINTING
> >  	---help---
> >  	 This driver supports increasing and decreasing the amount
> >  	 of memory within a KVM guest.
> > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > index 226fbb995fb0..dee9f8f3ad09 100644
> > --- a/drivers/virtio/virtio_balloon.c
> > +++ b/drivers/virtio/virtio_balloon.c
> > @@ -19,6 +19,7 @@
> >  #include <linux/mount.h>
> >  #include <linux/magic.h>
> >  #include <linux/pseudo_fs.h>
> > +#include <linux/page_hinting.h>
> >  
> >  /*
> >   * Balloon device works in 4K page units.  So each page is pointed to by
> > @@ -27,6 +28,7 @@
> >   */
> >  #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
> >  #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
> > +#define VIRTIO_BALLOON_ARRAY_HINTS_MAX	32
> >  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
> >  
> >  #define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
> > @@ -46,6 +48,7 @@ enum virtio_balloon_vq {
> >  	VIRTIO_BALLOON_VQ_DEFLATE,
> >  	VIRTIO_BALLOON_VQ_STATS,
> >  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> > +	VIRTIO_BALLOON_VQ_HINTING,
> >  	VIRTIO_BALLOON_VQ_MAX
> >  };
> >  
> > @@ -113,6 +116,10 @@ struct virtio_balloon {
> >  
> >  	/* To register a shrinker to shrink memory upon memory pressure */
> >  	struct shrinker shrinker;
> > +
> > +	/* Unused page hinting device */
> > +	struct virtqueue *hinting_vq;
> > +	struct page_hinting_dev_info ph_dev_info;
> >  };
> >  
> >  static struct virtio_device_id id_table[] = {
> > @@ -152,6 +159,22 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> >  
> >  }
> >  
> > +void virtballoon_page_hinting_react(struct page_hinting_dev_info *ph_dev_info,
> > +				    unsigned int num_hints)
> > +{
> > +	struct virtio_balloon *vb =
> > +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> > +	struct virtqueue *vq = vb->hinting_vq;
> > +	unsigned int unused;
> > +
> > +	/* We should always be able to add these buffers to an empty queue. */
> 
> can be an out of memory condition, and then ...
> 
> > +	virtqueue_add_inbuf(vq, ph_dev_info->sg, num_hints, vb, GFP_KERNEL);
> > +	virtqueue_kick(vq);
> 
> ... this will block forever.
> 
> > +	/* When host has read buffer, this completes via balloon_ack */
> > +	wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
> 
> However below I suggest limiting capacity which will solve
> this problem for you.

I wasn't aware that virtqueue_add_inbuf actually performed an allocation.

> > +}
> > +
> >  static void set_page_pfns(struct virtio_balloon *vb,
> >  			  __virtio32 pfns[], struct page *page)
> >  {
> > @@ -476,6 +499,7 @@ static int init_vqs(struct virtio_balloon *vb)
> >  	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
> >  	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
> >  	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> > +	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
> >  
> >  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> >  		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> > @@ -487,11 +511,19 @@ static int init_vqs(struct virtio_balloon *vb)
> >  		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> >  	}
> >  
> > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> > +		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
> > +		callbacks[VIRTIO_BALLOON_VQ_HINTING] = balloon_ack;
> > +	}
> > +
> >  	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
> >  					 vqs, callbacks, names, NULL, NULL);
> >  	if (err)
> >  		return err;
> >  
> > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> > +		vb->hinting_vq = vqs[VIRTIO_BALLOON_VQ_HINTING];
> > +
> >  	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
> >  	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
> >  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > @@ -924,12 +956,24 @@ static int virtballoon_probe(struct virtio_device *vdev)
> >  		if (err)
> >  			goto out_del_balloon_wq;
> >  	}
> > +
> > +	vb->ph_dev_info.react = virtballoon_page_hinting_react;
> > +	vb->ph_dev_info.capacity = VIRTIO_BALLOON_ARRAY_HINTS_MAX;
> 
> As explained above I think you should limit this by vq size.
> Otherwise virtqueue add buf might fail.
> In fact by struct spec reading you need to limit it
> anyway otherwise it will fail unconditionally.
> In practice on most hypervisors it will typically work ...

So I would just need to query that via the virtqueue_get_vring_size
function correct? I could probably just set capacity to the minimum of the
HINTS_MAX and that value right?




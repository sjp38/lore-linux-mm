Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B20B7C41514
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:15:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73F6E23401
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:15:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73F6E23401
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EAB16B0003; Wed,  4 Sep 2019 16:15:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 072EE6B0006; Wed,  4 Sep 2019 16:15:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA32F6B0007; Wed,  4 Sep 2019 16:15:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id C15E86B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 16:15:10 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6122F181AC9B4
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:15:10 +0000 (UTC)
X-FDA: 75898342380.17.smile03_ff3e6a674542
X-HE-Tag: smile03_ff3e6a674542
X-Filterd-Recvd-Size: 6431
Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:15:09 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Sep 2019 13:15:08 -0700
X-IronPort-AV: E=Sophos;i="5.64,468,1559545200"; 
   d="scan'208";a="187738920"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga006-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Sep 2019 13:15:07 -0700
Message-ID: <d451a4b08bfe5fc6ccc60b85d229baf011a37809.camel@linux.intel.com>
Subject: Re: [PATCH v7 6/6] virtio-balloon: Add support for providing unused
 page reports to host
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, 
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, 
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, 
 virtio-dev@lists.oasis-open.org, osalvador@suse.de,
 yang.zhang.wz@gmail.com,  pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com,  lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com,  pbonzini@redhat.com, dan.j.williams@intel.com
Date: Wed, 04 Sep 2019 13:15:07 -0700
In-Reply-To: <20190904151506-mutt-send-email-mst@kernel.org>
References: <20190904150920.13848.32271.stgit@localhost.localdomain>
	 <20190904151102.13848.65770.stgit@localhost.localdomain>
	 <20190904151506-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-09-04 at 15:17 -0400, Michael S. Tsirkin wrote:
> On Wed, Sep 04, 2019 at 08:11:02AM -0700, Alexander Duyck wrote:
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
> >  drivers/virtio/virtio_balloon.c     |   65 +++++++++++++++++++++++++++++++++++
> >  include/uapi/linux/virtio_balloon.h |    1 +
> >  3 files changed, 67 insertions(+)
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
> > index 2c19457ab573..0b400bb382c0 100644
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
> > @@ -152,6 +161,32 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> >  
> >  }
> >  
> > +void virtballoon_unused_page_report(struct page_reporting_dev_info *ph_dev_info,
> > +				    unsigned int nents)
> > +{
> > +	struct virtio_balloon *vb =
> > +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> > +	struct virtqueue *vq = vb->reporting_vq;
> > +	unsigned int unused, err;
> > +
> > +	/* We should always be able to add these buffers to an empty queue. */
> > +	err = virtqueue_add_inbuf(vq, ph_dev_info->sg, nents, vb,
> > +				  GFP_NOWAIT | __GFP_NOWARN);
> > +
> > +	/*
> > +	 * In the extremely unlikely case that something has changed and we
> > +	 * are able to trigger an error we will simply display a warning
> > +	 * and exit without actually processing the pages.
> > +	 */
> > +	if (WARN_ON(err))
> > +		return;
> > +
> > +	virtqueue_kick(vq);
> > +
> > +	/* When host has read buffer, this completes via balloon_ack */
> > +	wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
> > +}
> > +
> 
> So just to make sure I understand, this always passes a single
> buf to the vq and then waits until that completes, correct?

Correct.

> Thus there are never outstanding bufs on the vq and this
> is why we don't need e.g. any cleanup.

Yes. Basically this will wait until the queue has been processed by the
host before we process any additional pages. We can't have the pages in an
unknown state when we put them back so we have to wait here until we know
they have been fully reported to the host.



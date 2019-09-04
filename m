Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0E0AC3A5AA
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:32:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DF2F21883
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:32:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DF2F21883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39C8D6B0003; Wed,  4 Sep 2019 16:32:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34BD66B0006; Wed,  4 Sep 2019 16:32:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 261876B0007; Wed,  4 Sep 2019 16:32:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 0018F6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 16:32:47 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A0AD21EE6
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:32:47 +0000 (UTC)
X-FDA: 75898386774.15.sand35_1847d05261953
X-HE-Tag: sand35_1847d05261953
X-Filterd-Recvd-Size: 5506
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:32:46 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Sep 2019 13:32:45 -0700
X-IronPort-AV: E=Sophos;i="5.64,468,1559545200"; 
   d="scan'208";a="177069505"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Sep 2019 13:32:44 -0700
Message-ID: <a6a0770adc5c5d593e407e26589cb2bc552f4cbb.camel@linux.intel.com>
Subject: Re: [virtio-dev] Re: [PATCH v7 5/6] virtio-balloon: Pull page
 poisoning config out of free page hinting
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
Date: Wed, 04 Sep 2019 13:32:44 -0700
In-Reply-To: <20190904152244-mutt-send-email-mst@kernel.org>
References: <20190904150920.13848.32271.stgit@localhost.localdomain>
	 <20190904151055.13848.27351.stgit@localhost.localdomain>
	 <20190904152244-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-09-04 at 15:28 -0400, Michael S. Tsirkin wrote:
> On Wed, Sep 04, 2019 at 08:10:55AM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Currently the page poisoning setting wasn't being enabled unless free page
> > hinting was enabled. However we will need the page poisoning tracking logic
> > as well for unused page reporting. As such pull it out and make it a
> > separate bit of config in the probe function.
> > 
> > In addition we can actually wrap the code in a check for NO_SANITY. If we
> > don't care what is actually in the page we can just default to 0 and leave
> > it there.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  drivers/virtio/virtio_balloon.c |   19 +++++++++++++------
> >  mm/page_reporting.c             |    4 ++++
> >  2 files changed, 17 insertions(+), 6 deletions(-)
> > 
> > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > index 226fbb995fb0..2c19457ab573 100644
> > --- a/drivers/virtio/virtio_balloon.c
> > +++ b/drivers/virtio/virtio_balloon.c
> > @@ -842,7 +842,6 @@ static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
> >  static int virtballoon_probe(struct virtio_device *vdev)
> >  {
> >  	struct virtio_balloon *vb;
> > -	__u32 poison_val;
> >  	int err;
> >  
> >  	if (!vdev->config->get) {
> > @@ -909,11 +908,19 @@ static int virtballoon_probe(struct virtio_device *vdev)
> >  						  VIRTIO_BALLOON_CMD_ID_STOP);
> >  		spin_lock_init(&vb->free_page_list_lock);
> >  		INIT_LIST_HEAD(&vb->free_page_list);
> > -		if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
> > -			memset(&poison_val, PAGE_POISON, sizeof(poison_val));
> > -			virtio_cwrite(vb->vdev, struct virtio_balloon_config,
> > -				      poison_val, &poison_val);
> > -		}
> > +	}
> > +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
> > +		__u32 poison_val = 0;
> > +
> > +#if !defined(CONFIG_PAGE_POISONING_NO_SANITY)
> > +		/*
> > +		 * Let hypervisor know that we are expecting a specific
> > +		 * value to be written back in unused pages.
> > +		 */
> > +		memset(&poison_val, PAGE_POISON, sizeof(poison_val));
> > +#endif
> > +		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
> > +			      poison_val, &poison_val);
> >  	}
> >  	/*
> >  	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to decide if a
> 
> I'm a bit confused by this part. Should we not just clear
> VIRTIO_BALLOON_F_PAGE_POISON completely?
> 
> In my mind the value written should be what guest puts in
> free pages - and possibly what it expects to find there later.

I thought it better to err on the side of more information rather than
less. With this the host knows that page poisoning is enabled, but that 0
is an acceptable value.

> If it doesn't expect anything there then it makes sense
> to clear VIRTIO_BALLOON_F_PAGE_POISON so that host does
> not try to put the poison value there.

That makes sense.

> But I think that it does not make sense to lie to host about the poison
> value - I think that if we do send poison value to
> host it's reasonable for host to expect free pages
> have that value - and even possibly to validate that.
> 
> So I think that the hack belongs in virtballoon_validate,
> near the page_poisoning_enabled check.

Yeah, I will move that for v8. I will just add an IS_ENABLED check to the
!page_poisoning_enabled check in virtballoon_validate and can drop the
#ifdef check.

Thanks.

- Alex



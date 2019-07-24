Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E6EAC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:46:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C08AE21852
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:46:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C08AE21852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B0A36B0003; Wed, 24 Jul 2019 16:46:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 261DD8E000C; Wed, 24 Jul 2019 16:46:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14FC58E0002; Wed, 24 Jul 2019 16:46:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8F716B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:46:11 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id j81so40262998qke.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:46:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=kEmnRIh7eb5SZPPwt0SSGdzpr7hhPeFdagIv+/tAxBM=;
        b=BvTKsokc5cVhxOq3fXzz7ixoU1Eha+VFQDOW1B5BjzgRCCxgTHaxbnrkIum69mOpHs
         Xs9QD/RcS9pAHxbq1NIlAryeHOPiwITK3NwjcIpInSoqqGXXiaejVAEMgNCnS5eIJkyH
         tHG27oYd4kjqN9E1UqKno4jyRwxpEvmrr1unLeegKTQzD64yQOoQtq7LuHilwnAcQoLA
         2ZY+YNprZejpw2oKGENOcMnad2F4cXxJBzsMGyazt6C/BHQUt+lQdmvmXLpQjhpzVqew
         bxY0lPBQKwOBHE4PFponbVQG/VWwVJ646D6fWhXUINF+XQNN/VHihk/NfueVOV1JxK92
         PurA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXXkz95UHTP89DZzN6u9kGo0aD4C+9V7v3vZISePDl5i4uYbUl0
	WRqonTzjhy6+D8leVASmin1qK4e2YnABrNgrvOpfy6Dq8RGmwYpvHYjJfXunOtBxK0/35X8vXwo
	+Cq/7lPvz36stW3awc9CKCs/C5JpsPUX3Q2GuI6icfW1SS1G1aXbUwO8vAoSpdEtjOg==
X-Received: by 2002:ac8:341d:: with SMTP id u29mr56313522qtb.320.1564001171722;
        Wed, 24 Jul 2019 13:46:11 -0700 (PDT)
X-Received: by 2002:ac8:341d:: with SMTP id u29mr56313491qtb.320.1564001171047;
        Wed, 24 Jul 2019 13:46:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564001171; cv=none;
        d=google.com; s=arc-20160816;
        b=AafhMLMv6/MVlAmTNmBVOLYz7fQy56/cOY8+kjGuOtlK5I5HC0faZ5vJsY1GAbRB2w
         6UOHrXu3LDZlf7gU2GVTX9pe/wGR5Q/djuueYXg0eToYEpUYqAbQYkFWhGOUiz89+oFA
         VSqym8px6AqIWd4VOkXQElW0Zq0HRXJk6Cw4LC+6P1GOhgqQDNDbAAmyb6+lLJP6xBrm
         lYq0Lc97+RSdkNmz721wxLX7LJKECo/aX104Co6UgXXXQ+tJY18Yy+ODcE4OfDb65U/4
         a1oipMLHOTui9fy9XEWb0XkrJlMAvSiGm+6Yngif/K6GSeqne7eJAow3H0ZgUgfgkhca
         d/iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=kEmnRIh7eb5SZPPwt0SSGdzpr7hhPeFdagIv+/tAxBM=;
        b=kxt9bDufSoZ73r5HWemq33yasg3ySQre4ntl8IZ9YFxLGPhvBs0tf+8AwKgVd54TvJ
         1nj4VY+jJiLr3LKg6yVF//K4eFt5J2JLomY+M9gl3kogrXBtZDNnErXFP7zdYUQ+zNkx
         XpFf0/2u/YQgMngt7T9O7Be2G+bOWj8Z1RJb/vNgqeoH0uJ/kbe+EA0uxLYXHgYdhBFb
         YHcz2YinqJwgzvBYOsL39zfszO8yurPsv+wy819jWJlJ2pryR3iWzuCV42q+n0bj+3T3
         AMU3z2Wqm5neC2OK6DBrw79QG9xhOfQTAhv+duZvKX8GXy3b3GFqhrv37ogXCwP/s1D9
         PL2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e17sor62810102qto.8.2019.07.24.13.46.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 13:46:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwbpIKZ55eh/98dX0EXGRSXf9HthV7sKQoo76sbcztNZu/6XKn9qDAYGtrzpMy5Z2naK3MXlQ==
X-Received: by 2002:ac8:5141:: with SMTP id h1mr59926940qtn.15.1564001170693;
        Wed, 24 Jul 2019 13:46:10 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id c5sm29604425qta.5.2019.07.24.13.46.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 13:46:09 -0700 (PDT)
Date: Wed, 24 Jul 2019 16:46:03 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
	kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
Message-ID: <20190724164433-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724150224-mutt-send-email-mst@kernel.org>
 <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 01:18:00PM -0700, Alexander Duyck wrote:
> On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
> > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > Add support for what I am referring to as "bubble hinting". Basically the
> > > idea is to function very similar to how the balloon works in that we
> > > basically end up madvising the page as not being used. However we don't
> > > really need to bother with any deflate type logic since the page will be
> > > faulted back into the guest when it is read or written to.
> > > 
> > > This is meant to be a simplification of the existing balloon interface
> > > to use for providing hints to what memory needs to be freed. I am assuming
> > > this is safe to do as the deflate logic does not actually appear to do very
> > > much other than tracking what subpages have been released and which ones
> > > haven't.
> > > 
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > ---
> > >  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
> > >  include/hw/virtio/virtio-balloon.h              |    2 +
> > >  include/standard-headers/linux/virtio_balloon.h |    1 +
> > >  3 files changed, 42 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> > > index 2112874055fb..70c0004c0f88 100644
> > > --- a/hw/virtio/virtio-balloon.c
> > > +++ b/hw/virtio/virtio-balloon.c
> > > @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
> > >      balloon_stats_change_timer(s, 0);
> > >  }
> > >  
> > > +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> > > +{
> > > +    VirtQueueElement *elem;
> > > +
> > > +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> > > +    	unsigned int i;
> > > +
> > > +        for (i = 0; i < elem->in_num; i++) {
> > > +            void *addr = elem->in_sg[i].iov_base;
> > > +            size_t size = elem->in_sg[i].iov_len;
> > > +            ram_addr_t ram_offset;
> > > +            size_t rb_page_size;
> > > +            RAMBlock *rb;
> > > +
> > > +            if (qemu_balloon_is_inhibited())
> > > +                continue;
> > > +
> > > +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
> > > +            rb_page_size = qemu_ram_pagesize(rb);
> > > +
> > > +            /* For now we will simply ignore unaligned memory regions */
> > > +            if ((ram_offset | size) & (rb_page_size - 1))
> > > +                continue;
> > > +
> > > +            ram_block_discard_range(rb, ram_offset, size);
> > 
> > I suspect this needs to do like the migration type of
> > hinting and get disabled if page poisoning is in effect.
> > Right?
> 
> Shouldn't something like that end up getting handled via
> qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
> like that would end up setting qemu_balloon_is_inhibited to true, if that
> isn't the case then I could add some additional conditions. I would do it
> in about the same spot as the qemu_balloon_is_inhibited check.

Well qemu_balloon_is_inhibited is for the regular ballooning,
mostly a work-around for limitations is host linux iommu
APIs when it's used with VFIO.

-- 
MST


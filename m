Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D94FCC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:57:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A27722BF5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:57:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A27722BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D9456B026B; Thu, 25 Jul 2019 10:57:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 289796B026C; Thu, 25 Jul 2019 10:57:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 179918E0002; Thu, 25 Jul 2019 10:57:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D50C96B026B
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:57:49 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so31047015pfz.10
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:57:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=l/urlPE742dwOPrjg4cIuvv4qlqyGvC6x5/DV4E1IoI=;
        b=Ojs7KKwUCyqT2vrxNuYoKXOu4zZFMvBGzAxklNnxUADb5IKxhXRlEy+45FIVdq4etS
         unS8bs6GovxNjDPIXdoYpRL6HcGOMJ+1xJvG09WBI2XKxSC6mGy2dnFWoTfsTK19FdDX
         AjnzSp2X2UgrpD0JLLHOVisppC/dJAf/U00rwtQjZgOmZVQ6kanFmjPHU4bZpC7ad5Kn
         bcvvIHPFqSU//Tolup3X+Mf3C5NCltgW99Cb/xvuW6Np4hed2oHNt5Xe1MOliyRyoAyO
         1ppYNBaPPWybP01S5yRRvvd38LcNBEdB+Fkmj1XQl6AS/Pzi5f/QykIeHU0m3J8aYvDO
         863w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU00Jb4dENI2Rq82uCigcWKRoSjaq4LF33ZBO9zQTSrGm1MKh40
	lGgC8L7KBi+LMbtxSBhI9VtOUD/8Ygiiv/fLvs9S/fjXSSbFj4S5QQ6+8o6Irhpf7HDVOA2YQjo
	HtaBlsoVt7gRJeOb6gQilUxUGX1p4ylS6/wldfQKBmnzZGnk1DH3/1ltW0tYx/bcn9g==
X-Received: by 2002:a63:20d:: with SMTP id 13mr75764562pgc.253.1564066669426;
        Thu, 25 Jul 2019 07:57:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2H89eyvCC7PYvfcOZtjQBeG36t90Xa4X7H+x4xXEn4dPZRypKGOr04etrTYO4qxr9Aoui
X-Received: by 2002:a63:20d:: with SMTP id 13mr75764523pgc.253.1564066668574;
        Thu, 25 Jul 2019 07:57:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564066668; cv=none;
        d=google.com; s=arc-20160816;
        b=c9ZAkDYGOgyTYh+Bp3dGid3EPhS+XjrRs27Mi9nj3ZTZR2Gzl9tEinaemaDFQ6JSL8
         fhJqxi+Lhrvqy8R5mqwUJ+LCeFvg2ApQ+S0p9B1cLnL9JTaWvcqKF3j30a00bBsIT7aY
         6e5PwLfP8GZTmpXEsRLaAoRWYsOr4q+fmmlzRmDApKMcnX/AcuSPtKRJra6vG89x5RGQ
         yWb5V2idekokVmYBsCorE+LLfNBfELlmZGPWkJuKBuxTEGysghCJz3s/8bcupcXvYd39
         zr5z6AO6ChPBrqpPGW0t0hdpLlEwNKKHMQAOfxCu+Q1sFn2YXA6htNVmxAZ4kY0M57RK
         4L9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=l/urlPE742dwOPrjg4cIuvv4qlqyGvC6x5/DV4E1IoI=;
        b=RH/o5rYMFCcYxYZSsp3GNvMoDkJ/8smkJNLTdASKGSXhxvWcrkMNH/3wN/5fKdAlu6
         HOjQNPtqSlqnDY5zSvRtX3i3asGEG3s7UfYr5QNoKoNCp8te1IvcSorRPfRbcP+EB1rL
         lSvzN9mJhAH3vP3ZgYjjCpEbWLErSsOsUjF3+LHPhjBC49f7/iTQre/lbyGwXRv+9ci6
         C9lOLH2DI8WQuI5/qpOv/pRuw6P1iolfIlxDRvtsM2MKpDusDi6zkHloHZUW9e3V0UDQ
         QaA2G8D7dF9Z13F04Kv4M5Y0YdMVCmlGLwO95QIMTPv6E0EJGAq7ms9qZFMTZo8oX+rs
         Z2Fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d12si17886903pla.121.2019.07.25.07.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 07:57:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 07:57:48 -0700
X-IronPort-AV: E=Sophos;i="5.64,307,1559545200"; 
   d="scan'208";a="164199993"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 07:57:48 -0700
Message-ID: <d9357c2b6ed9e1499703a562199cc28d1b57383e.camel@linux.intel.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org, 
	david@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org, yang.zhang.wz@gmail.com, 
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com, 
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com, 
	pbonzini@redhat.com, dan.j.williams@intel.com
Date: Thu, 25 Jul 2019 07:57:47 -0700
In-Reply-To: <bbfe0fbb-dd23-ed5c-01b3-493ae804942f@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724171050.7888.62199.stgit@localhost.localdomain>
	 <20190724150224-mutt-send-email-mst@kernel.org>
	 <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
	 <bbfe0fbb-dd23-ed5c-01b3-493ae804942f@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-25 at 07:57 -0400, Nitesh Narayan Lal wrote:
> On 7/24/19 4:18 PM, Alexander Duyck wrote:
> > On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
> > > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > Add support for what I am referring to as "bubble hinting". Basically the
> > > > idea is to function very similar to how the balloon works in that we
> > > > basically end up madvising the page as not being used. However we don't
> > > > really need to bother with any deflate type logic since the page will be
> > > > faulted back into the guest when it is read or written to.
> > > > 
> > > > This is meant to be a simplification of the existing balloon interface
> > > > to use for providing hints to what memory needs to be freed. I am assuming
> > > > this is safe to do as the deflate logic does not actually appear to do very
> > > > much other than tracking what subpages have been released and which ones
> > > > haven't.
> > > > 
> > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > ---
> > > >  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
> > > >  include/hw/virtio/virtio-balloon.h              |    2 +
> > > >  include/standard-headers/linux/virtio_balloon.h |    1 +
> > > >  3 files changed, 42 insertions(+), 1 deletion(-)
> > > > 
> > > > diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> > > > index 2112874055fb..70c0004c0f88 100644
> > > > --- a/hw/virtio/virtio-balloon.c
> > > > +++ b/hw/virtio/virtio-balloon.c
> > > > @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
> > > >      balloon_stats_change_timer(s, 0);
> > > >  }
> > > >  
> > > > +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> > > > +{
> > > > +    VirtQueueElement *elem;
> > > > +
> > > > +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> > > > +    	unsigned int i;
> > > > +
> > > > +        for (i = 0; i < elem->in_num; i++) {
> > > > +            void *addr = elem->in_sg[i].iov_base;
> > > > +            size_t size = elem->in_sg[i].iov_len;
> > > > +            ram_addr_t ram_offset;
> > > > +            size_t rb_page_size;
> > > > +            RAMBlock *rb;
> > > > +
> > > > +            if (qemu_balloon_is_inhibited())
> > > > +                continue;
> > > > +
> > > > +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
> > > > +            rb_page_size = qemu_ram_pagesize(rb);
> > > > +
> > > > +            /* For now we will simply ignore unaligned memory regions */
> > > > +            if ((ram_offset | size) & (rb_page_size - 1))
> > > > +                continue;
> > > > +
> > > > +            ram_block_discard_range(rb, ram_offset, size);
> > > I suspect this needs to do like the migration type of
> > > hinting and get disabled if page poisoning is in effect.
> > > Right?
> > Shouldn't something like that end up getting handled via
> > qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
> > like that would end up setting qemu_balloon_is_inhibited to true, if that
> > isn't the case then I could add some additional conditions. I would do it
> > in about the same spot as the qemu_balloon_is_inhibited check.
> 
> Just wondering if you have tried running these patches in an environment with
> directly assigned devices? Ideally, I would expect qemu_balloon_is_inhibited()
> to take care of it.

Yes, I have run that as a test to actually benchmark the effect of things
without the madvise bits since it essentially disables the hinting in the
hypervisor but not the guest.


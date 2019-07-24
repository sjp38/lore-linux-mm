Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58BEDC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:18:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B01B206BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:18:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B01B206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3F766B0005; Wed, 24 Jul 2019 16:18:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F27C8E0003; Wed, 24 Jul 2019 16:18:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E2068E0002; Wed, 24 Jul 2019 16:18:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 559D06B0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:18:02 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f2so24765038plr.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:18:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=v0V48bHJCTyXrXZRPA/cLuY9lP0VDLM8nRGyE+5xpGs=;
        b=IJC3MLN66XMBYBk2SINLLELcn+2Kial4piw8h5MKhENuk12RIdmgq+Ho7ykLggpf0E
         Ir6kmVdg6M799lrV7rtIJJFYqHgCk1WXAgtoRHGmYeCQVq+Zg9JP6rgWDyBSllzLWTcS
         EOaAKreQpYfwrxr0t8oSfpwAe21lXsyzLf0ZQD+6aFs6yPMT70Q59DflGffIDcEkeJO0
         709R1K58HJCZcJS9fNEUJmaHp7UuldXN1ImugwBHhN35Yy2Ye+fQKLxhIcAHlYYJh6Sb
         trbOZWch/YOsOL0IudrV9359GeQQMgO3oSvZcq/8YOU4jCd6gvMLMj2JogmvzAcaUbo8
         9hUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUHDqsXjIOyKFJTWYEAMCv5Ohohq3gG2WpI9945sY0Mz1Ok3IXv
	9ZUAYFjuTBEH2TWCCZanYMo149skLlUzJElMYor12T/csljhdwuCuRPEW5nY/78fZ3SzBOjYOMK
	TiG/OFnY8wfgfCa+zgxFxA/mfUb+4LF+MdgKaihoDEcQlSMhPGCh+gEf9/hDgi55Ifg==
X-Received: by 2002:a17:90a:2385:: with SMTP id g5mr91309066pje.12.1563999482015;
        Wed, 24 Jul 2019 13:18:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTsv51CdUlRvwBW0yiSEMpwWe/8RN1uVPZqrEEmPsGHPoJljvj/St8pI7XyVT5V/229ccb
X-Received: by 2002:a17:90a:2385:: with SMTP id g5mr91309036pje.12.1563999481280;
        Wed, 24 Jul 2019 13:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563999481; cv=none;
        d=google.com; s=arc-20160816;
        b=ZVfFQgjz21kcpZgQn8Zoio/P9cjahfMUNFg5aCbUz1thMOuYZdZgC7PQjmAzSIQT5g
         vuTMH9Xv0MvAH6eDqINgKNMQZnXZso0+Pu9lq/GoZ3dxZ7vOe8tdln9gYW6mFjUsnxtJ
         gvJgvPMaq2Wo3A+Z87+ItJ7yeKJ7JYkGJhhI0lZA7iwkhsD5MbLFz1WPFbNNmfFBRuTj
         a703KgTGZFEAtRRxc9hdnU5t10dWbx1x2/7Lw+QRFgpfMyN3yDQcm1qhMCdfiwMnWWAt
         hQ0FnpEAkNjPZbpRwa1+lmK5LkKm0eO9K7hka7nyq9y83X8BiUp1BjC4+fW4kgMO0/tS
         Zj3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=v0V48bHJCTyXrXZRPA/cLuY9lP0VDLM8nRGyE+5xpGs=;
        b=zVfSGoswbDs5JgG7FXDJJN3IEVD0MYTLPWooMZ9sD7YeGFYvZ8Xs/nrl+IVBEagT17
         oMkNFlauWfvAwTzLpOp2PZJlsFqSsId1BqZQWYABxqA/oplLi70RU4FS8PplylU1WnNm
         E0bEeDlWFYpbzu2CfSfn9mLT2K6MOZs9ZtYc5yCVHuNOUKQfNu4IbwHp+2Jbnm+vzN6W
         tBzLDryydvQJe+cdrlraURaKrGGitYPJYgi8ipe9jRO/UTA4r4Ud4Y59GxsKrG7Evcln
         oYr2enzZo4COAAlmFG7TgDApIEpt1D+GEmletR+V+kAuhgfg3yJp654CQf2tJmqK/1T9
         KTBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i94si14393747plb.78.2019.07.24.13.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 13:18:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 13:18:00 -0700
X-IronPort-AV: E=Sophos;i="5.64,304,1559545200"; 
   d="scan'208";a="174993771"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga006-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 13:18:00 -0700
Message-ID: <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, 
	dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com, pagupta@redhat.com, 
	riel@surriel.com, konrad.wilk@oracle.com, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com, 
	dan.j.williams@intel.com
Date: Wed, 24 Jul 2019 13:18:00 -0700
In-Reply-To: <20190724150224-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724171050.7888.62199.stgit@localhost.localdomain>
	 <20190724150224-mutt-send-email-mst@kernel.org>
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
> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Add support for what I am referring to as "bubble hinting". Basically the
> > idea is to function very similar to how the balloon works in that we
> > basically end up madvising the page as not being used. However we don't
> > really need to bother with any deflate type logic since the page will be
> > faulted back into the guest when it is read or written to.
> > 
> > This is meant to be a simplification of the existing balloon interface
> > to use for providing hints to what memory needs to be freed. I am assuming
> > this is safe to do as the deflate logic does not actually appear to do very
> > much other than tracking what subpages have been released and which ones
> > haven't.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
> >  include/hw/virtio/virtio-balloon.h              |    2 +
> >  include/standard-headers/linux/virtio_balloon.h |    1 +
> >  3 files changed, 42 insertions(+), 1 deletion(-)
> > 
> > diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> > index 2112874055fb..70c0004c0f88 100644
> > --- a/hw/virtio/virtio-balloon.c
> > +++ b/hw/virtio/virtio-balloon.c
> > @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
> >      balloon_stats_change_timer(s, 0);
> >  }
> >  
> > +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> > +{
> > +    VirtQueueElement *elem;
> > +
> > +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> > +    	unsigned int i;
> > +
> > +        for (i = 0; i < elem->in_num; i++) {
> > +            void *addr = elem->in_sg[i].iov_base;
> > +            size_t size = elem->in_sg[i].iov_len;
> > +            ram_addr_t ram_offset;
> > +            size_t rb_page_size;
> > +            RAMBlock *rb;
> > +
> > +            if (qemu_balloon_is_inhibited())
> > +                continue;
> > +
> > +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
> > +            rb_page_size = qemu_ram_pagesize(rb);
> > +
> > +            /* For now we will simply ignore unaligned memory regions */
> > +            if ((ram_offset | size) & (rb_page_size - 1))
> > +                continue;
> > +
> > +            ram_block_discard_range(rb, ram_offset, size);
> 
> I suspect this needs to do like the migration type of
> hinting and get disabled if page poisoning is in effect.
> Right?

Shouldn't something like that end up getting handled via
qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
like that would end up setting qemu_balloon_is_inhibited to true, if that
isn't the case then I could add some additional conditions. I would do it
in about the same spot as the qemu_balloon_is_inhibited check.



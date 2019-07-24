Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97192C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:14:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 552D721911
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:14:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 552D721911
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D229A6B026B; Wed, 24 Jul 2019 17:14:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAD5A8E000C; Wed, 24 Jul 2019 17:14:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9B8F8E0002; Wed, 24 Jul 2019 17:14:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9CD6B026B
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:14:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z1so29322376pfb.7
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:14:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=MuqKWK/59RLrHxUF8or0sFVYzkeHcFgYN3OwCb1//T4=;
        b=DRRyvrRx5fKoqaTTZHWRcaTvd5xqIV2KrfLwLI30vhDbjbCi0CYKq6D1xrzw3fSGdU
         VT1BGKaBZmgIpIZIR3U5/+NuPCkqQfgRjbJE2V21qubgih0X67jLYTO8gp9eSWeVv2yX
         VMMHYgl4FPqzWhzjrOd+oJcjtB17acKwhht3bBwHTuTbi8VpSeimhIOin55n0hgjLn3R
         lowyLydHuau0r2bEXsqPoE43cYsG70B4Jn8Ca32p7DHKk2FPkWIXJa28W/HkqYpR5mEu
         8KSNZuo3cL+irVmxxp//3mHuTYSri1tHZu9mpbL5Cma5xwVTtKegUzzCUQHsU2IgFq2u
         5vOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXDvwbGC/d4BfCyPqAoDMuJmmi/G9VIwd99vklvWY8RMKnAg0bB
	c3ifA8EBOYA5aDU21n0ROWW/bkSShUR7L2+EEp8WG3lpu9728OxbrdwBQtkVaQfUz0UzA2o0gFw
	kCWBxhrdtWQnaW8En8gpU5AdD9qP4O7bwtGXZe8FN5/btwe1+LhdxTwRGbctlt6jTBw==
X-Received: by 2002:a63:5765:: with SMTP id h37mr50392109pgm.183.1564002884984;
        Wed, 24 Jul 2019 14:14:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpcfob2P63X95LKN/p21VekitVp+lb06yVSO+V7oVCWdAs6ZthGfla+zJQhO5M2b8djJWs
X-Received: by 2002:a63:5765:: with SMTP id h37mr50392053pgm.183.1564002884152;
        Wed, 24 Jul 2019 14:14:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564002884; cv=none;
        d=google.com; s=arc-20160816;
        b=PPIWaF7aSXPa2wjAWKulKuMZ4ndCglKJUaNmSvmYM1T6mRFTtWbY32d0H33bD8vAes
         YMXzLtzRjF0shwEROJnPDqdGCxaGZ1p0u/iIFAMEwbjxVp1Rjj4q3RVM87cw/UDgFCqV
         68X0kQXJarKDNSNJQvhBrgtjSypXDcsI5ptQgFOnB6zSVDViaFPU7uWMLMGnODX2xUBl
         rXHsZzsWTXF5LgY8K6qcsi68lLJQXjHnW/ZkNiJN3X6wiKHVL1MWeaC8fseJUBiDPbsg
         TOSSNVZ5YiWzMRmuMdF9b/ANK9B00mxQjZwrIRyAKBO/RP5h6AcqmFEkFkMi46Lp+BiM
         6HaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=MuqKWK/59RLrHxUF8or0sFVYzkeHcFgYN3OwCb1//T4=;
        b=HOMb11faIGnU5mSxasK2mZ5zcx+1XE6USuPDX778h9yLC0dkUD1mEguKVqh1M2yZbU
         QHSraCJEeDV9MeMvHRzqWRkfubTmJ8VHNNudhSMpgJjMIWHCb/wFzqo64UYmVhCpAZNr
         VwwWov5Hvcp4vXSgNU6qei60yqPjZjWsrgsJu03CadI5XYFDXcepQgPtOsMShZbRmTg1
         iyYPXf8WuicWoP8o54BkhDX4iEUTErHzHXBjUYpi2CArIADhi43goyeS1oeNKXi1BIx4
         oFHCEy56eSP9dSBwJC5SmSzpu1aQx+NKDoevsG2KUMTGJGrQeDJvdcAnP33G8VXvZNzN
         J81g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id c38si6039390pgc.65.2019.07.24.14.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 14:14:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 14:14:43 -0700
X-IronPort-AV: E=Sophos;i="5.64,304,1559545200"; 
   d="scan'208";a="253724062"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 14:14:43 -0700
Message-ID: <d70c9d97571e8efd4c971eaa73d67fc50222e67d.camel@linux.intel.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com, 
 kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com, 
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org,  yang.zhang.wz@gmail.com, pagupta@redhat.com,
 riel@surriel.com,  konrad.wilk@oracle.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com,  aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com
Date: Wed, 24 Jul 2019 14:14:43 -0700
In-Reply-To: <20190724164433-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724171050.7888.62199.stgit@localhost.localdomain>
	 <20190724150224-mutt-send-email-mst@kernel.org>
	 <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
	 <20190724164433-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-24 at 16:46 -0400, Michael S. Tsirkin wrote:
> On Wed, Jul 24, 2019 at 01:18:00PM -0700, Alexander Duyck wrote:
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
> > > 
> > > I suspect this needs to do like the migration type of
> > > hinting and get disabled if page poisoning is in effect.
> > > Right?
> > 
> > Shouldn't something like that end up getting handled via
> > qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
> > like that would end up setting qemu_balloon_is_inhibited to true, if that
> > isn't the case then I could add some additional conditions. I would do it
> > in about the same spot as the qemu_balloon_is_inhibited check.
> 
> Well qemu_balloon_is_inhibited is for the regular ballooning,
> mostly a work-around for limitations is host linux iommu
> APIs when it's used with VFIO.

I understood that. However it also addresses the shared memory case as
well if I recall correctly. Basically any case where us discarding the
page could cause issues we should be causing that function to return true.


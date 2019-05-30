Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B80D7C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 18:13:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D16E25F36
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 18:13:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D16E25F36
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B0176B000E; Thu, 30 May 2019 14:13:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 339F26B026D; Thu, 30 May 2019 14:13:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DAE36B026E; Thu, 30 May 2019 14:13:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFA5E6B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 14:13:32 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id a12so5633316qkb.3
        for <linux-mm@kvack.org>; Thu, 30 May 2019 11:13:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=swUKp54FsABaRx/HQxckmg32aK739BKT6ewItuokNDk=;
        b=atkGIrS4zMJexjVpUbaLBEqEjcCvIrLaDBkyZOlF0NMonEJvLoxuVObcaTUppxcO4t
         Kq9i0NP57YmJ5r5/akMwEUESKKqIeujuWqWXQbVBpCV7dwG1zCW6JlrISbgr30ijXcNT
         Ivy1JjlsTN6dIFOx/vC11MukfzwmG27N0Wub1T/t/AZ3Dox/tayhRUBHXNhXgMiNgZgq
         Iob+FULBllVchDaj2bEi1x1KCG4N65DtGy8cA35HOsejz9aL1klHM0zBHber3eRtFQ6Z
         1k77t6HOSWKPQ8RbPQPl6Vy+ldTALTUqTVnMP3xDYFB9zofauHEpJZ6KixBhPMEXwLSd
         rsGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUU0H/+YR83aFlwZnbklLjlBdcQRH5o9vVslzmSEjpW179K5OZO
	t8ZkTHeFH4rsGZwaDgIRsfNq+4W8DDJrKskwVX9hwjOUK9AZHBki4/SQKGdBlbczUvHyyC+jcfS
	VgxjN0z2j9zj1CK6h0o7D0oe/eSNe6RVLmNTe9GtlsXUooziQJDGf4q8k+NgZzMENfQ==
X-Received: by 2002:aed:23d0:: with SMTP id k16mr4684785qtc.45.1559240012746;
        Thu, 30 May 2019 11:13:32 -0700 (PDT)
X-Received: by 2002:aed:23d0:: with SMTP id k16mr4684736qtc.45.1559240012152;
        Thu, 30 May 2019 11:13:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559240012; cv=none;
        d=google.com; s=arc-20160816;
        b=M7+HXKaGT9Dgs61wrg5RTmo4AVWJM2dr1f99F1HlrDUxiHm5JtQuASBkMkFwtK7wCK
         zj0ZdMfiWOOs+TJOBhuCZSTjq9ijBgHcKDCWLm/F/XZRoatK3Rpv/Ai64X64AmSLwlTP
         q9aGtWbzV2IPjsu7LaggoCrA2rNZ382eU27VGdA+2CXQJkOJbr0Qh4pKNsUoVH5WMYRx
         bX1u2FolrLkOc3AtBnqygfmJkFCVdkiwEwnPXZEe9avcBPj+D/atsJn3X1FduJdUvlv2
         N3OM/iJS7bbwIfruenR0+XnNbgE1ytHEC7VAeuw3FHeBp7fEXr1km5d7ND7jRslUhDbU
         ZIUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=swUKp54FsABaRx/HQxckmg32aK739BKT6ewItuokNDk=;
        b=WJARgSfBaccyYNx+FI4ljmwQp/QZq2n+e+NdeGYyfBVOIZtYB57sHVo163QMvTqC2V
         QTgI3/AVj0U+pFiRerD5uUJEVLJ6IphDfZCBgziY1RDSsvCEspAwTlafW603+yIR0f/c
         RN2CWDWU+8+Vma9uS0AZVGRjMyHk0UlIgLSMk9jiqve+R8y/hV40LWa7VZN56b0ZPGaC
         wSTjwuGIZJ1ECpad9SFKZuQg16RIzgm3Fqm1syTkj1BYTX0lJnZ+0KKBuDCeUHBsky/G
         Fy+HYWVXhhCAsITDQ3/m2EOajof9GohriNfRPGKmVxpP0J238NatGktj7nE2f4vGF85Y
         Cbbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f51sor2636292qte.30.2019.05.30.11.13.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 11:13:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyndgU/JBNxGTz081BydLXYPXGN+1/yzyTBopwAP5jF6DEPVUhyIlMc188XrJEeCGJfnA2k0g==
X-Received: by 2002:aed:2494:: with SMTP id t20mr4813376qtc.135.1559240011968;
        Thu, 30 May 2019 11:13:31 -0700 (PDT)
Received: from redhat.com (pool-100-0-197-103.bstnma.fios.verizon.net. [100.0.197.103])
        by smtp.gmail.com with ESMTPSA id k9sm1894099qki.20.2019.05.30.11.13.30
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 30 May 2019 11:13:31 -0700 (PDT)
Date: Thu, 30 May 2019 14:13:28 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Miller <davem@davemloft.net>
Cc: jasowang@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com,
	James.Bottomley@hansenpartnership.com, hch@infradead.org,
	jglisse@redhat.com, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com, jrdr.linux@gmail.com
Subject: Re: [PATCH net-next 0/6] vhost: accelerate metadata access
Message-ID: <20190530141243-mutt-send-email-mst@kernel.org>
References: <20190524081218.2502-1-jasowang@redhat.com>
 <20190530.110730.2064393163616673523.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530.110730.2064393163616673523.davem@davemloft.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 11:07:30AM -0700, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Fri, 24 May 2019 04:12:12 -0400
> 
> > This series tries to access virtqueue metadata through kernel virtual
> > address instead of copy_user() friends since they had too much
> > overheads like checks, spec barriers or even hardware feature
> > toggling like SMAP. This is done through setup kernel address through
> > direct mapping and co-opreate VM management with MMU notifiers.
> > 
> > Test shows about 23% improvement on TX PPS. TCP_STREAM doesn't see
> > obvious improvement.
> 
> I'm still waiting for some review from mst.
> 
> If I don't see any review soon I will just wipe these changes from
> patchwork as it serves no purpose to just let them rot there.
> 
> Thank you.

I thought we agreed I'm merging this through my tree, not net-next.
So you can safely wipe it.

Thanks!

-- 
MST


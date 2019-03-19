Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 674DFC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:18:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24E3B20811
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:18:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24E3B20811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9CD36B0006; Tue, 19 Mar 2019 15:18:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C25FC6B0007; Tue, 19 Mar 2019 15:18:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC79B6B0008; Tue, 19 Mar 2019 15:18:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 854DA6B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:18:54 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d8so18522136qkk.17
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:18:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SqKyDsIrCNZj0LNUi/jOz4p3YnLcroRbSoQ664QRnt8=;
        b=ZZXAu2wZd/OdhsXPHIU6bAyYsxB7ScZHmHXq/Y9YvWVAmT0nDcWOP3woeW390Pg6s7
         3/Kt67NlSGgsmu7DCffuy5kePDRsmNk99TLPLPYJ9X4MstvBwOyl0akr18inAlj4aWFE
         9IzcCuwRDdpX1feRwZNQpWfDjKdsq/0ea2UkPxnan+okdcmR1f/jCpVrsHYJez59CTdl
         0g5x+rHhkoDkluqGlIusx+sLJjbozkxNvbe4xzm9tBo6zmgpuRDaaVMqwiBPGhhAOw+h
         xv8LWBudHLdbLe4yoyVDL+MThTuSlwFJT25Jv2vIoL/Yztq6R0zfmA44VcyE3rnQwXSL
         7bOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV4b/JOVY1uNn3GltE04upT219hM8oa+yYv89zRhL5yGbAHlJww
	Q4h8T6hlnof6j20ZoA03WJcz0+CvSOELpHf+4yNtJemOT7TgsZkGxWq58V/AoAIgdHQSuTyy68m
	fx3jGo0m21RQ0+WirwtshvG4Cw+l+TyVTcynmqRZhucs12BRm5S1xBQ+IA0VfFdFRlw==
X-Received: by 2002:a0c:90c2:: with SMTP id p60mr3328270qvp.158.1553023134314;
        Tue, 19 Mar 2019 12:18:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJG5xMXxxo2bqwpSvtKv9Sl4YWNfQccVeZ1dxGlzQlN6eU3o1vio4vax8T0BatPFyRnrzv
X-Received: by 2002:a0c:90c2:: with SMTP id p60mr3328202qvp.158.1553023133411;
        Tue, 19 Mar 2019 12:18:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553023133; cv=none;
        d=google.com; s=arc-20160816;
        b=GIPnZiN1tMK+uohvKkCCBN1oyy16DYKn7IWIAjvHiNCkZ8e2sH/tnFmZixDaFg7jSx
         xjkCONKGZdPxD6VNbpSMLMaXB+pIpkJnsjTbs64KnpO/glqDoGrS1BB0pwT3BeX6dWUU
         DQ2mJTLaFlf6PFvjkVeX3iosBVChBMtzGQTcrSKirXvosj0gnYgkV8gFrjmzTX/51MQf
         OlEvy457ZOM0gY/3QJntbgCSxQ74n+G6Q3AOCtp1+4Alx2yoyGVXqyTjCiUHbPNnkKeA
         ElhBlQpXpewBgMfB9Tllm9IUtYFXYBgnshZEul4q8IswfP8Ppxc2k9X2I3I/NbLcUNWf
         qYIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=SqKyDsIrCNZj0LNUi/jOz4p3YnLcroRbSoQ664QRnt8=;
        b=V68WUyfKSP8d6X1bKd6O1oq8hA1CPVj5MnaDtwAqJyhlOShwN0lx2w7DBISXuYLMl3
         gx2o4BLSpd9DJgapCde8HeE1+Aq36lgiT+OLes64KjxInRBYyZYzkiNFZFTK/Rmtzbck
         pO8MEN72h4iXVmdqmtfhwYxJ2PgPGJltldigOrDPlKgQb0wvgCdchNt2CfsGQrfn9cJ8
         1dW6EIx+wuDm/LqwJ8XOSZyBzqF8QclSeVLgs25Gp0INmfSpNKvkFYNcy3JdZtNThf4i
         CE33gg+Ay8sLCQRWVwwVOclTbeU47ci9jXGs8CTccRFJx2YJQmkt8tsNqk74Vs3PePtf
         uQaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g12si1564355qtk.204.2019.03.19.12.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 12:18:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8069C307EA87;
	Tue, 19 Mar 2019 19:18:52 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7CA676ACE0;
	Tue, 19 Mar 2019 19:18:51 +0000 (UTC)
Date: Tue, 19 Mar 2019 15:18:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Alex Deucher <alexander.deucher@amd.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190319191849.GA4310@redhat.com>
References: <20190318170404.GA6786@redhat.com>
 <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
 <20190319165802.GA3656@redhat.com>
 <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
 <20190319171847.GC3656@redhat.com>
 <CAPcyv4iesGET_PV-QcdBbxJGgmJ_HhoGczyvb=0+SnLkFDhRuQ@mail.gmail.com>
 <20190319174552.GA3769@redhat.com>
 <CAPcyv4hFPOO0-=v3ZCNFA=LgE_QCvyFXGqF24Crveoj_NTbq0Q@mail.gmail.com>
 <20190319190528.GA4012@redhat.com>
 <CAPcyv4hg5Y_NC1iu56zcznYkCRnwg+_7bGFr==7=AC6ii=O=Ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4hg5Y_NC1iu56zcznYkCRnwg+_7bGFr==7=AC6ii=O=Ng@mail.gmail.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 19 Mar 2019 19:18:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 12:13:40PM -0700, Dan Williams wrote:
> On Tue, Mar 19, 2019 at 12:05 PM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Mar 19, 2019 at 11:42:00AM -0700, Dan Williams wrote:
> > > On Tue, Mar 19, 2019 at 10:45 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > >
> > > > On Tue, Mar 19, 2019 at 10:33:57AM -0700, Dan Williams wrote:
> > > > > On Tue, Mar 19, 2019 at 10:19 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > > >
> > > > > > On Tue, Mar 19, 2019 at 10:12:49AM -0700, Andrew Morton wrote:
> > > > > > > On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> > > > > [..]
> > > > > > > Also, the discussion regarding [07/10] is substantial and is ongoing so
> > > > > > > please let's push along wth that.
> > > > > >
> > > > > > I can move it as last patch in the serie but it is needed for ODP RDMA
> > > > > > convertion too. Otherwise i will just move that code into the ODP RDMA
> > > > > > code and will have to move it again into HMM code once i am done with
> > > > > > the nouveau changes and in the meantime i expect other driver will want
> > > > > > to use this 2 helpers too.
> > > > >
> > > > > I still hold out hope that we can find a way to have productive
> > > > > discussions about the implementation of this infrastructure.
> > > > > Threatening to move the code elsewhere to bypass the feedback is not
> > > > > productive.
> > > >
> > > > I am not threatening anything that code is in ODP _today_ with that
> > > > patchset i was factering it out so that i could also use it in nouveau.
> > > > nouveau is built in such way that right now i can not use it directly.
> > > > But i wanted to factor out now in hope that i can get the nouveau
> > > > changes in 5.2 and then convert nouveau in 5.3.
> > > >
> > > > So when i said that code will be in ODP it just means that instead of
> > > > removing it from ODP i will keep it there and it will just delay more
> > > > code sharing for everyone.
> > >
> > > The point I'm trying to make is that the code sharing for everyone is
> > > moving the implementation closer to canonical kernel code and use
> > > existing infrastructure. For example, I look at 'struct hmm_range' and
> > > see nothing hmm specific in it. I think we can make that generic and
> > > not build up more apis and data structures in the "hmm" namespace.
> >
> > Right now i am trying to unify driver for device that have can support
> > the mmu notifier approach through HMM. Unify to a superset of driver
> > that can not abide by mmu notifier is on my todo list like i said but
> > it comes after. I do not want to make the big jump in just one go. So
> > i doing thing under HMM and thus in HMM namespace, but once i tackle
> > the larger set i will move to generic namespace what make sense.
> >
> > This exact approach did happen several time already in the kernel. In
> > the GPU sub-system we did it several time. First do something for couple
> > devices that are very similar then grow to a bigger set of devices and
> > generalise along the way.
> >
> > So i do not see what is the problem of me repeating that same pattern
> > here again. Do something for a smaller set before tackling it on for
> > a bigger set.
> 
> All of that is fine, but when I asked about the ultimate trajectory
> that replaces hmm_range_dma_map() with an updated / HMM-aware GUP
> implementation, the response was that hmm_range_dma_map() is here to
> stay. The issue is not with forking off a small side effort, it's the
> plan to absorb that capability into a common implementation across
> non-HMM drivers where possible.

hmm_range_dma_map() is a superset of gup_range_dma_map() because on
top of gup_range_dma_map() the hmm version deals with mmu notifier.

But everything that is not mmu notifier related can be share through
gup_range_dma_map() so plan is to end up with:
    hmm_range_dma_map(hmm_struct) {
        hmm_mmu_notifier_specific_prep_step();
        gup_range_dma_map(hmm_struct->common_base_struct);
        hmm_mmu_notifier_specific_post_step();
    }

ie share as much as possible. Does that not make sense ? To get
there i will need to do non trivial addition to GUP and so i went
first to get HMM bits working and then work on common gup API.

Cheers,
Jérôme


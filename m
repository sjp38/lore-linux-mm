Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26243C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:05:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D45E92083D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:05:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D45E92083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 860C66B0005; Tue, 19 Mar 2019 15:05:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 810B36B0006; Tue, 19 Mar 2019 15:05:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D9C66B0007; Tue, 19 Mar 2019 15:05:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 499106B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:05:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k29so18667271qkl.14
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:05:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=OycpD+CPZT8XAlpeEa4gvrliRdgrsjfw2e+kvwQcboI=;
        b=FXiVlMrwBiiQDIOYiMCvV785CrhbPe4OgK/OGC9/zb5Bm5wcoyqbV8+Rr6OkvnMBBg
         7JkpmTcahJnKnfQ86hyVeRV7Pdh0M1IhNcg06Q2HXM4yKuHruO7PdaHKxb3BlyANZR4N
         bZD+KDKh+wAAluU4uGiXeQsal88a177LiNpzyzHkpKIcuX7KKY4jPYOOxkpgPtxym8cM
         XeWdeubBKeosmZ7CY/lL709LHxOK80uL2ugpt4ZdyVicbfuEjU3GMw4bqLH2mVrPyK5p
         m+JVTwip92BbB5laKkf9dKwPT3UCInz24QkSJdmPnh78U9DM5QNk0OjFqoWO7issM6o9
         m6cQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUVj/U2kd1CSciL+phqf11xR3loPj6Dm+MFQ0ikykdM8O6F4cHf
	YHnMJbCjG0zv5jFxrdDMdyj0Qmv33j4NKoCEN47pR+QuDENSMXglaPUI4K/m2jy/+O55hm3pb6j
	/5iIOppoq+eEyWz5/wpFOzXVq4BdOk07b7GtEfL5MaLhVl/Lu+VtgCfP1Yf47bFEd8w==
X-Received: by 2002:ac8:5493:: with SMTP id h19mr3293358qtq.23.1553022333000;
        Tue, 19 Mar 2019 12:05:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyP+dF2X0HMLffyhkViTt+esSS32MslaUBzg54G8r/Q94z2SUH2WXOKTnGXwtqA9okfK4NF
X-Received: by 2002:ac8:5493:: with SMTP id h19mr3293292qtq.23.1553022332052;
        Tue, 19 Mar 2019 12:05:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553022332; cv=none;
        d=google.com; s=arc-20160816;
        b=UPcGlfgICRRY/cs3eIbsNy8qWaJgDpi6mMyhh5wQE9Oocaw5tZKGcKGW597xqskb1d
         UJltSHC5gqDEKHS1US3qVShSJy6lCPQrcQJT4+4WGsmoNPdel5xq03KH4PdRMn8mUYmY
         cDJxtZBZ+pLyBIBFlUPkJ0FFjag3vRnyCH+GDYs5GTpcSW2VXuLD4d+91MRf7UBbdHGc
         lm51EcUVYEA6+qv4lgvVKGRYYNAePPvaz2GstVlwaI5+RYS5RSKecsXNk8rrAlMnzpSv
         XhaeKhuIy4p3DtLS1dyM64BC88JzLBByrIzXSuPnjrnz9423upFVki0KMncICuMOCQjb
         2ytw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=OycpD+CPZT8XAlpeEa4gvrliRdgrsjfw2e+kvwQcboI=;
        b=WZN3xzCT0fuTR5EBz/4i/zZxOdxss8DelLGyTXD2114L4U6FFoGorQC82ZbSLfniDX
         f4dMtmRMx60G/YeRfKuohv1vYVann3v/Kw3c15BWU2ngr0J3ws8TdnUKAWKRyDf1dh1g
         w5Th03UyzGzpv93Ext9Zbiufo0IDaNfsYydfL52sH/EA7yUPQ+Uq0DI66dFSCjlQDlPB
         sFsMH7eE/wdZ9ZDMHYgc+LevJNiPM/aWhfwMfDm0JRY+iyqslZjVu8ut8Z5voK5Rk4+j
         s3mo5pnhT+2T9UVmpuFNWt/Po/c9K+Cn5+q8OpxVxYcKj9TjlrmPVL64ny8fvR8gqxGM
         NJmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d9si1733008qvj.212.2019.03.19.12.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 12:05:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3CA4B308622A;
	Tue, 19 Mar 2019 19:05:31 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 322C26295D;
	Tue, 19 Mar 2019 19:05:30 +0000 (UTC)
Date: Tue, 19 Mar 2019 15:05:28 -0400
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
Message-ID: <20190319190528.GA4012@redhat.com>
References: <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com>
 <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
 <20190319165802.GA3656@redhat.com>
 <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
 <20190319171847.GC3656@redhat.com>
 <CAPcyv4iesGET_PV-QcdBbxJGgmJ_HhoGczyvb=0+SnLkFDhRuQ@mail.gmail.com>
 <20190319174552.GA3769@redhat.com>
 <CAPcyv4hFPOO0-=v3ZCNFA=LgE_QCvyFXGqF24Crveoj_NTbq0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4hFPOO0-=v3ZCNFA=LgE_QCvyFXGqF24Crveoj_NTbq0Q@mail.gmail.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 19 Mar 2019 19:05:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 11:42:00AM -0700, Dan Williams wrote:
> On Tue, Mar 19, 2019 at 10:45 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Mar 19, 2019 at 10:33:57AM -0700, Dan Williams wrote:
> > > On Tue, Mar 19, 2019 at 10:19 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > >
> > > > On Tue, Mar 19, 2019 at 10:12:49AM -0700, Andrew Morton wrote:
> > > > > On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> > > [..]
> > > > > Also, the discussion regarding [07/10] is substantial and is ongoing so
> > > > > please let's push along wth that.
> > > >
> > > > I can move it as last patch in the serie but it is needed for ODP RDMA
> > > > convertion too. Otherwise i will just move that code into the ODP RDMA
> > > > code and will have to move it again into HMM code once i am done with
> > > > the nouveau changes and in the meantime i expect other driver will want
> > > > to use this 2 helpers too.
> > >
> > > I still hold out hope that we can find a way to have productive
> > > discussions about the implementation of this infrastructure.
> > > Threatening to move the code elsewhere to bypass the feedback is not
> > > productive.
> >
> > I am not threatening anything that code is in ODP _today_ with that
> > patchset i was factering it out so that i could also use it in nouveau.
> > nouveau is built in such way that right now i can not use it directly.
> > But i wanted to factor out now in hope that i can get the nouveau
> > changes in 5.2 and then convert nouveau in 5.3.
> >
> > So when i said that code will be in ODP it just means that instead of
> > removing it from ODP i will keep it there and it will just delay more
> > code sharing for everyone.
> 
> The point I'm trying to make is that the code sharing for everyone is
> moving the implementation closer to canonical kernel code and use
> existing infrastructure. For example, I look at 'struct hmm_range' and
> see nothing hmm specific in it. I think we can make that generic and
> not build up more apis and data structures in the "hmm" namespace.

Right now i am trying to unify driver for device that have can support
the mmu notifier approach through HMM. Unify to a superset of driver
that can not abide by mmu notifier is on my todo list like i said but
it comes after. I do not want to make the big jump in just one go. So
i doing thing under HMM and thus in HMM namespace, but once i tackle
the larger set i will move to generic namespace what make sense.

This exact approach did happen several time already in the kernel. In
the GPU sub-system we did it several time. First do something for couple
devices that are very similar then grow to a bigger set of devices and
generalise along the way.

So i do not see what is the problem of me repeating that same pattern
here again. Do something for a smaller set before tackling it on for
a bigger set.

Cheers,
Jérôme


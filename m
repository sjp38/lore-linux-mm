Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D159C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCA6820835
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:58:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCA6820835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CFB96B0005; Tue, 19 Mar 2019 12:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 680646B0006; Tue, 19 Mar 2019 12:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 596626B0007; Tue, 19 Mar 2019 12:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3352E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:58:08 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l10so15983959qkj.22
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:58:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=LZfncOVwix9I7pRiQp/6Ng39qDrEW6CYLgJ/btXoJY8=;
        b=iGhlQpZAe7vzwAu2rit4UZVn9YA8+edJv6TXBrad64WN6hotTZsEHsfl+n+FWg2eS/
         i3B/IIjFQO1KWbBHWftmOngTsTEcmR9UKRHHUcDlM2I769qBcNrbWjV09Tg6UdtRsq4r
         Z4sCLFC+Wz1GTHLs21XznWQ4wlZ9UNt5sv5r8zRdJmogiOD5pX1kc/rczxCBCnbGE7YV
         Mpxqz1cpBGncAR85yR4+bHllrUGm6sKxZM3OUCUZClemU9xpf8UAMo6PDUoR71xkdRRu
         NHEuyu79s02rJFf9aHlajbWVzqw/hbkuqQFnSajXJ4SfeuPxl/szoYjWyL9E7wTlKjwu
         0wew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXFQIFpHWgbqtIfbRr/kZzB6w5dXcGmByEgb0ygGxmAnPcRCNZ+
	v4L3LT1J2Q5aRf1/4/sG5FEwTrtoikFcyYF5DWFZonRV6hfjHlhZPYcrDXoJbzmFsIc5xcoRiQj
	6olq057LJSNCeu4vnKA6TNdUqAFf/8VRgbUgBFt0Weun0KpDjtbXA/1MRZWMO6f7iVg==
X-Received: by 2002:ac8:65c3:: with SMTP id t3mr3213152qto.12.1553014687960;
        Tue, 19 Mar 2019 09:58:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznEGZ9Wb1pRh3yLVYaPeCig8jFDNyvx9J7NiulFKO21D4loFQcYITBDLcHaPFixA6anCsO
X-Received: by 2002:ac8:65c3:: with SMTP id t3mr3213095qto.12.1553014687042;
        Tue, 19 Mar 2019 09:58:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553014687; cv=none;
        d=google.com; s=arc-20160816;
        b=cWjbqR8n7WicFynGaLgAmViXV3r017H9P4PxZbqcrQmN8A0yzVBQVgdcgKUSGtOTyU
         wA47F98kywHjTOy5MLqfcuyx0d5BBA3wAYr3ZF8oAN8gq0v6E5N/L/ApAwch5QQqfupB
         UKPzUBUNpDNdYG3RSF5KlkZmZSfME+xT5PDV4XWjj99g03YOwgOmOht7fGxsnnq6y6zV
         fdrTRdD2eTctHj8AVNrF6ocYIV9ZGFhkoV/NkIgKhgYyZTM8D5j+tJdNGZITq+pcPUKo
         uXdaUJeyth+zsst43k6HzxagMoNEOnSwILxzHHvmRMv1BaBacJJjlLFiR/KSN5T21L3j
         MpVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=LZfncOVwix9I7pRiQp/6Ng39qDrEW6CYLgJ/btXoJY8=;
        b=cHiiGKuVAtb5GV4p37W9s6K/cFHec9LAKkHOtXN2IzARgkvrgUR1a/Sgeg9BTwcVsr
         /0dwOvzigXbJD3iw1IjBuCK/dvBEj/cZ3w2h7qQiT8tsAFCdpQHX9KPF3KnXkIAGhJOd
         X7bVVp+DUlja9JNStKLXzt+cGYVQbPaINVeYiXPC+NwQxx651dJKaZkOxHqSbABN6INn
         jSWH5xEjf5XOiEaAdlgYMWG4uYL6SLEw/wixV2377KvfHCqrErWanXo/6BZmqLOUdCa3
         gXAtk5QF1KgpfV1leZpz9JsYuTKdERZS9vN0iZbPwE2MHXLfaHcqYTJaBiayon6H2YnE
         0wkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y1si8036678qvf.173.2019.03.19.09.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 09:58:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0F9E870D63;
	Tue, 19 Mar 2019 16:58:06 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id AD11060856;
	Tue, 19 Mar 2019 16:58:04 +0000 (UTC)
Date: Tue, 19 Mar 2019 12:58:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Alex Deucher <alexander.deucher@amd.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190319165802.GA3656@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com>
 <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 19 Mar 2019 16:58:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 09:40:07AM -0700, Andrew Morton wrote:
> On Mon, 18 Mar 2019 13:04:04 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > On Wed, Mar 13, 2019 at 09:10:04AM -0700, Andrew Morton wrote:
> > > On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> > > 
> > > > Andrew you will not be pushing this patchset in 5.1 ?
> > > 
> > > I'd like to.  It sounds like we're converging on a plan.
> > > 
> > > It would be good to hear more from the driver developers who will be
> > > consuming these new features - links to patchsets, review feedback,
> > > etc.  Which individuals should we be asking?  Felix, Christian and
> > > Jason, perhaps?
> > > 
> > 
> > So i am guessing you will not send this to Linus ?
> 
> I was waiting to see how the discussion proceeds.  Was also expecting
> various changelog updates (at least) - more acks from driver
> developers, additional pointers to client driver patchsets, description
> of their readiness, etc.

nouveau will benefit from this patchset and is already upstream in 5.1
so i am not sure what kind of pointer i can give for that, it is already
there. amdgpu will also benefit from it and is queue up AFAICT. ODP RDMA
is the third driver and i gave link to the patch that also use the 2
new functions that this patchset introduce. Do you want more ?

I guess i will repost with updated ack as Felix, Jason and few others
told me they were fine with it.

> 
> Today I discover that Alex has cherrypicked "mm/hmm: use reference
> counting for HMM struct" into a tree which is fed into linux-next which
> rather messes things up from my end and makes it hard to feed a
> (possibly modified version of) that into Linus.

:( i did not know the tree they pull that in was fed into next. I will
discourage them from doing so going forward.

> So I think I'll throw up my hands, drop them all and shall await
> developments :(

What more do you want to see ? I can repost with the ack already given
and the improve commit wording on some of the patch. But from user point
of view nouveau is already upstream, ODP RDMA depends on this patchset
and is posted and i have given link to it. amdgpu is queue up. What more
do i need ?

Cheers,
Jérôme


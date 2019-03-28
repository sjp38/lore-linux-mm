Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AC1FC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:05:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C77622184E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:05:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C77622184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D72A6B0003; Thu, 28 Mar 2019 19:05:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45D766B0006; Thu, 28 Mar 2019 19:05:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 328B66B0007; Thu, 28 Mar 2019 19:05:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7946B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:05:49 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n1so447705qte.12
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:05:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=kQgoMerodOMYcS1ac8dmbvH/WohoMn/PcftIRSm/UUE=;
        b=kVNF0olD4g5qacqAo3djqsruNngKxz0aXw/HtW8GJRum43GobhBp9207qNrBM1Yp8n
         cEzpXcBbJ6Os3Rkb7v0OKR2luYspqscVobgUR2UHxhRbaVnveeJsY/3/+EwdEzi7YaRn
         VJeDTt1G7v9rFQClULXs9liHzbP7QvBXshf6+Ittp1lOfj4NNvXqfAI/ESnx1PayFrSW
         4R8pvCG1ewd50sEhsDNTTiQDFHjpLc0yWOQ3ujKI9D25zuYF/lWqK+sTgiWbNiH4ywIw
         k228gEibxL7OM4okjDJcWYgQTw6Xt6HWiSN9ajSpGDClS33MlhV/Vfo2qQQLNqitwqJV
         5p+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXAelOv6U3a+DboZm5LestfDvqGc1ww7HxIAKMzTqSs2XYaxm/s
	dXo9EQrjEyzIvUyMtENyP9mV70ZE7RO2cLTU3F5pBZf2YEGjb5bBJINIugYyNMhBom3ugaDl7dL
	N9Y3yghu9iRYXC78tP2CAuWhJ30EblJD3KS3/JWyTFkEIVXIlLhFsjQNszl7tkykPOw==
X-Received: by 2002:aed:3ac2:: with SMTP id o60mr20689056qte.158.1553814348734;
        Thu, 28 Mar 2019 16:05:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEEEk8a2FQ33vKFKushoQOR3SeUsovfsaY/xS9/vdpa4aOT+0oid1BEbVgmjl01E6deXoR
X-Received: by 2002:aed:3ac2:: with SMTP id o60mr20688964qte.158.1553814347508;
        Thu, 28 Mar 2019 16:05:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553814347; cv=none;
        d=google.com; s=arc-20160816;
        b=D1TaqpnK27JCoF0uPsrRY5wH8vgLi24rFR9ht7vVpx9JlYIlmqIufb4pazi4HieDBK
         P9r6TjJ3S2f7ut+skZn7VgrRKUdNuGxKNIGD8EM97DCIj3ph/N0VMghRQ9WJ9AGH4bxJ
         BJJyPylZ//jlc4PVtGMYvGiuCcITN6fwGO1Gp0/b3L/i4qjf6SIGKkxPCRZiDIvVpfOh
         kSA/WwVya6R6goJ/VHifHyGaiHScvLhBio5aeR+yz3EDt/6CUzWH5ZOCg3dL5O6pqRA2
         lls5BB0eOupqiZkmJmm6pD//jBkhCwF6z4UoY8PzrQnGJlqQplSSFXJl1YF04cFm1ltC
         xfHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=kQgoMerodOMYcS1ac8dmbvH/WohoMn/PcftIRSm/UUE=;
        b=ge4VnbfAZnIsTqOrl0nUH89VinU3SNNhZYOTv5aGB9F0XMPVzC8cAmaQKY9C6cn657
         qmJZ4Rz97/kUH9j15+QQMII3wvPugHexjVCLr2bpbL/AUkJylRtdRhY6XTtQ/wdh9fMV
         xunnUvq2sHtc11wDX3lu39xEYyYdyQBZ1xP4Kk2o2Wr3vKYiyU4QeoD9fyJtfD+Miezw
         94vf+zGkABDuv6QJgUtFG2OE/S6GipWIcBzdZGtWz7dsTal8r4ivEqxopnv2aDLfD3/z
         S6jRBiQHouzIamD/JhRhLjNTQ7uWEhURKCRGxGRY28tZ6u+efc+rYCTQtzb/mPtFjXf4
         SuTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b1si212640qtb.286.2019.03.28.16.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:05:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7522F86676;
	Thu, 28 Mar 2019 23:05:46 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A31F45C29A;
	Thu, 28 Mar 2019 23:05:45 +0000 (UTC)
Date: Thu, 28 Mar 2019 19:05:43 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
Message-ID: <20190328230543.GI13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-11-jglisse@redhat.com>
 <9df742eb-61ca-3629-a5f4-8ad1244ff840@nvidia.com>
 <20190328213047.GB13560@redhat.com>
 <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
 <20190328220824.GE13560@redhat.com>
 <068db0a8-fade-8ed1-3b9d-c29c27797301@nvidia.com>
 <20190328224032.GH13560@redhat.com>
 <0b698b36-da17-434b-b8e7-4a91ac6c9d82@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0b698b36-da17-434b-b8e7-4a91ac6c9d82@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 28 Mar 2019 23:05:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 03:43:33PM -0700, John Hubbard wrote:
> On 3/28/19 3:40 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 03:25:39PM -0700, John Hubbard wrote:
> >> On 3/28/19 3:08 PM, Jerome Glisse wrote:
> >>> On Thu, Mar 28, 2019 at 02:41:02PM -0700, John Hubbard wrote:
> >>>> On 3/28/19 2:30 PM, Jerome Glisse wrote:
> >>>>> On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
> >>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>>>>>> From: Jérôme Glisse <jglisse@redhat.com>
> >> [...]
> >>>>
> >>>>>>
> >>>>>> If you insist on having this wrapper, I think it should have approximately 
> >>>>>> this form:
> >>>>>>
> >>>>>> void hmm_mirror_mm_down_read(...)
> >>>>>> {
> >>>>>> 	WARN_ON(...)
> >>>>>> 	down_read(...)
> >>>>>> } 
> >>>>>
> >>>>> I do insist as it is useful and use by both RDMA and nouveau and the
> >>>>> above would kill the intent. The intent is do not try to take the lock
> >>>>> if the process is dying.
> >>>>
> >>>> Could you provide me a link to those examples so I can take a peek? I
> >>>> am still convinced that this whole thing is a race condition at best.
> >>>
> >>> The race is fine and ok see:
> >>>
> >>> https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-odp-v2&id=eebd4f3095290a16ebc03182e2d3ab5dfa7b05ec
> >>>
> >>> which has been posted and i think i provided a link in the cover
> >>> letter to that post. The same patch exist for nouveau i need to
> >>> cleanup that tree and push it.
> >>
> >> Thanks for that link, and I apologize for not keeping up with that
> >> other review thread.
> >>
> >> Looking it over, hmm_mirror_mm_down_read() is only used in one place.
> >> So, what you really want there is not a down_read() wrapper, but rather,
> >> something like
> >>
> >> 	hmm_sanity_check()
> >>
> >> , that ib_umem_odp_map_dma_pages() calls.
> > 
> > Why ? The device driver pattern is:
> >     if (hmm_is_it_dying()) {
> >         // handle when process die and abort the fault ie useless
> >         // to call within HMM
> >     }
> >     down_read(mmap_sem);
> > 
> > This pattern is common within nouveau and RDMA and other device driver in
> > the work. Hence why i am replacing it with just one helper. Also it has the
> > added benefit that changes being discussed around the mmap sem will be easier
> > to do as it avoid having to update each driver but instead it can be done
> > just once for the HMM helpers.
> 
> Yes, and I'm saying that the pattern is broken. Because it's racy. :)

And i explained why it is fine, it just an optimization, in most case
it takes time to tear down a process and the device page fault handler
can be trigger while that happens, so instead of having it pile more
work on we can detect that even if it is racy. It is just about avoiding
useless work. There is nothing about correctness here. It does not need
to identify dying process with 100% accuracy. The fact that the process
is dying will be identified race free later on and it just means that in
the meantime we are doing useless works, potential tons of useless works.

They are hardware that can storm the page fault handler and we end up
with hundred of page fault queued up against a process that might be
dying. It is a big waste to go over all those fault and do works that
will be trown on the floor later on.

> 
> >>>>>>> +{
> >>>>>>> +	struct mm_struct *mm;
> >>>>>>> +
> >>>>>>> +	/* Sanity check ... */
> >>>>>>> +	if (!mirror || !mirror->hmm)
> >>>>>>> +		return -EINVAL;
> >>>>>>> +	/*
> >>>>>>> +	 * Before trying to take the mmap_sem make sure the mm is still
> >>>>>>> +	 * alive as device driver context might outlive the mm lifetime.
> >>>>>>
> >>>>>> Let's find another way, and a better place, to solve this problem.
> >>>>>> Ref counting?
> >>>>>
> >>>>> This has nothing to do with refcount or use after free or anthing
> >>>>> like that. It is just about checking wether we are about to do
> >>>>> something pointless. If the process is dying then it is pointless
> >>>>> to try to take the lock and it is pointless for the device driver
> >>>>> to trigger handle_mm_fault().
> >>>>
> >>>> Well, what happens if you let such pointless code run anyway? 
> >>>> Does everything still work? If yes, then we don't need this change.
> >>>> If no, then we need a race-free version of this change.
> >>>
> >>> Yes everything work, nothing bad can happen from a race, it will just
> >>> do useless work which never hurt anyone.
> >>>
> >>
> >> OK, so let's either drop this patch, or if merge windows won't allow that,
> >> then *eventually* drop this patch. And instead, put in a hmm_sanity_check()
> >> that does the same checks.
> > 
> > RDMA depends on this, so does the nouveau patchset that convert to new API.
> > So i do not see reason to drop this. They are user for this they are posted
> > and i hope i explained properly the benefit.
> > 
> > It is a common pattern. Yes it only save couple lines of code but down the
> > road i will also help for people working on the mmap_sem patchset.
> > 
> 
> It *adds* a couple of lines that are misleading, because they look like they
> make things safer, but they don't actually do so.

It is not about safety, sorry if it confused you but there is nothing about
safety here, i can add a big fat comment that explains that there is no safety
here. The intention is to allow the page fault handler that potential have
hundred of page fault queue up to abort as soon as it sees that it is pointless
to keep faulting on a dying process.

Again if we race it is _fine_ nothing bad will happen, we are just doing use-
less work that gonna be thrown on the floor and we are just slowing down the
process tear down.

Cheers,
Jérôme


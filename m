Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA621C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:36:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CBC92087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:36:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CBC92087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E2998E0004; Wed, 30 Jan 2019 13:36:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 069158E0001; Wed, 30 Jan 2019 13:36:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4D5F8E0004; Wed, 30 Jan 2019 13:36:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B34C08E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:36:22 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q33so531286qte.23
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:36:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=A5Hrd+dQWLwf9n9iDbhl206GnS8YT5VeBSdAfnUemIE=;
        b=qS3szSb449sq7X4K+vfn9SCpdiVHxDuh5aPboMdoIcxId9+3KslpPENAXANPwwskHb
         6LJaiC2XFULlvUmoX64jXWM9PuXqrtGOhtONkpAEl/oPb2cev9GgES+YEhZ8a0G8pHCD
         VptoEvHCOIZaHF1IxN+9jLpDpjoAouLqPcPdBwJhHovGYqUdnrnjKMldKr33JiM/AJ8C
         Wi/pr8RV+grmbHczFGQ3ytwesNE1t1Kr1JEijLsF3LSXG62pkWFvKdggQlm0r1r5f6O2
         xVoKSoMdytFe1wNFGoKo6ZTTdA5emUYGioP1sd6iAhj1EY6U72SvyeMeQ9UBnDsgMm8v
         cXcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcRIATKINg54fxmDnmVAUs8HYoZTPMjQthB6Nk0TA5C+qM+SEIB
	MaR2Tbcgl0rZc9HK3iAZv1izPZWOWCsFA5FNf/ylNQbby86LDqdhwZOCoYuntL/i/XJoNM8cxBl
	kOF/6JaJ3TudwvEJEbIFKNQijnbVpXEg60LfEhD3k/rmliPC/S+a1uAE8jyH3XjMpJA==
X-Received: by 2002:a37:8006:: with SMTP id b6mr27133941qkd.19.1548873382397;
        Wed, 30 Jan 2019 10:36:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4bYhsiN4OXmyTFnlO5V/L92uEra3C/cLYHuX7xZfWc5J//g8Re9EOfFxZCfT5W5mSWNUde
X-Received: by 2002:a37:8006:: with SMTP id b6mr27133889qkd.19.1548873381480;
        Wed, 30 Jan 2019 10:36:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548873381; cv=none;
        d=google.com; s=arc-20160816;
        b=WX6Vdze7TzZbpGM8tHqth1buQDIyqmTeyqC/nmAEC3ZDbKMCml4yoQDmym2toGUePy
         dbuM4mtzbvME6fk4krt9yrKdJUgUPTewpgjLXTCJ8znMU7eoK8pzBVs6uLS/j6Qjade0
         8COasxmmmvCirNQ64EY062sOHRUOZmKNWAdwDRf6PnpY6Xcin134zB0/4cmDQfex9c6p
         zNbM0g1/n4fhSdC24jTZ1f4luDr5rtQxtzRawETkHVjH/kuXWksx8whB13h5byYyLsgJ
         Vkk8Y/YLoEMtD24L6QRphF+9GzGxPIISvstJ86ji05XmfF1VA+MNXUFf3byjXrHRMTy6
         8EjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=A5Hrd+dQWLwf9n9iDbhl206GnS8YT5VeBSdAfnUemIE=;
        b=g9u8bDGkZ+R9MSGbFCe6M8E1lSRBNx8C4VVa46+dxA23JnN69ouK3MgSOz+7rfMIsX
         EgRWcyzZWmYuASrKcX2fUa3ENgnUHWrRwnADgO72kFOMYRvTBqr83dZ+Pm75CUo/0G+X
         38fNFDjmMaCCOVduy+HvHlpwooA2YM91eBV5dgI4MyjChBiUyiGvynkL2gpBMsv5U6Fm
         4C/DNx+HDO+L/Oz1817DZhv0O18EgXQ447ekhrYzyTk4lVTfgSEUqAzKUAIswjExqEwW
         Jeo3kUbO0PXxIB5DtPRltCOriiyqBy04ECDR/P82+u9DOev9pjW8f06SUniUMQssCJhV
         QNOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l45si942931qtc.21.2019.01.30.10.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:36:21 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 276822CD7EC;
	Wed, 30 Jan 2019 18:36:20 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 08B055C239;
	Wed, 30 Jan 2019 18:36:18 +0000 (UTC)
Date: Wed, 30 Jan 2019 13:36:17 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190130183616.GB5061@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-10-jglisse@redhat.com>
 <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
 <20190129193123.GF3176@redhat.com>
 <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
 <20190129212150.GP3176@redhat.com>
 <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com>
 <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 30 Jan 2019 18:36:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 09:25:21AM -0800, Dan Williams wrote:
> On Tue, Jan 29, 2019 at 7:03 PM Jerome Glisse <jglisse@redhat.com> wrote:
> [..]
> > > >     1) Convert ODP to use HMM underneath so that we share code between
> > > >     infiniband ODP and GPU drivers. ODP do support DAX today so i can
> > > >     not convert ODP to HMM without also supporting DAX in HMM otherwise
> > > >     i would regress the ODP features.
> > > >
> > > >     2) I expect people will be running GPGPU on computer with file that
> > > >     use DAX and they will want to use HMM there too, in fact from user-
> > > >     space point of view wether the file is DAX or not should only change
> > > >     one thing ie for DAX file you will never be able to use GPU memory.
> > > >
> > > >     3) I want to convert as many user of GUP to HMM (already posted
> > > >     several patchset to GPU mailing list for that and i intend to post
> > > >     a v2 of those latter on). Using HMM avoids GUP and it will avoid
> > > >     the GUP pin as here we abide by mmu notifier hence we do not want to
> > > >     inhibit any of the filesystem regular operation. Some of those GPU
> > > >     driver do allow GUP on DAX file. So again i can not regress them.
> > >
> > > Is this really a GUP to HMM conversion, or a GUP to mmu_notifier
> > > solution? It would be good to boil this conversion down to the base
> > > building blocks. It seems "HMM" can mean several distinct pieces of
> > > infrastructure. Is it possible to replace some GUP usage with an
> > > mmu_notifier based solution without pulling in all of HMM?
> >
> > Kind of both, some of the GPU driver i am converting will use HMM for
> > more than just this GUP reason. But when and for what hardware they
> > will use HMM for is not something i can share (it is up to each vendor
> > to announce their hardware and feature on their own timeline).
> 
> Typically a spec document precedes specific hardware announcement and
> Linux enabling is gated on public spec availability.
> 
> > So yes you could do the mmu notifier solution without pulling HMM
> > mirror (note that you do not need to pull all of HMM, HMM as many
> > kernel config option and for this you only need to use HMM mirror).
> > But if you are not using HMM then you will just be duplicating the
> > same code as HMM mirror. So i believe it is better to share this
> > code and if we want to change core mm then we only have to update
> > HMM while keeping the API/contract with device driver intact.
> 
> No. Linux should not end up with the HMM-mm as distinct from the
> Core-mm. For long term maintainability of Linux, the target should be
> one mm.

Hu ? I do not follow here. Maybe i am unclear and we are talking past
each other.

> 
> > This
> > is one of the motivation behind HMM ie have it as an impedence layer
> > between mm and device drivers so that mm folks do not have to under-
> > stand every single device driver but only have to understand the
> > contract HMM has with all device driver that uses it.
> 
> This gets to heart of my critique of the approach taken with HMM. The
> above statement is antithetical to
> Documentation/process/stable-api-nonsense.rst. If HMM is trying to set
> expectations that device-driver projects can write to a "stable" HMM
> api then HMM is setting those device-drivers up for failure.

So i am not expressing myself correctly. If someone want to change mm
in anyway that would affect HMM user, it can and it is welcome too
(assuming that those change are wanted by the community and motivated
for good reasons). Here by understanding HMM contract and preserving it
what i mean is that all you have to do is update the HMM API in anyway
that deliver the same result to the device driver. So what i means is
that instead of having to understand each device driver. For instance
you have HMM provide X so that driver can do Y; then what can be Z a
replacement for X that allow driver to do Y. The point here is that
HMM define what Y is and provide X for current kernel mm code. If X
ever need to change so that core mm can evolve than you can and are
more than welcome to do it. With HMM Y is defined and you only need to
figure out how to achieve the same end result for the device driver.

The point is that you do not have to go read each device driver to
figure out Y.driver_foo, Y.driver_bar, ... you only have HMM that
define what Y means and is ie this what device driver are trying to
do.

Obviously here i assume that we do not want to regress features ie
we want to keep device driver features intact when we modify anything.

> 
> The possibility of refactoring driver code *across* vendors is a core
> tenet of Linux maintainability. If the refactoring requires the API
> exported to drivers to change then so be it. The expectation that all
> out-of-tree device-drivers should have is that the API they are using
> in kernel version X may not be there in version X+1. Having the driver
> upstream is the only surefire insurance against that thrash.
> 
> HMM seems a bold experiment in trying to violate Linux development norms.

We are definitly talking past each other. HMM is _not_ a stable API or
any kind of contract with anybody outside upstream. If you want to change
the API HMM expose to device driver you are free to do so provided that
the change still allow device driver to achieve their objective.

HMM is not here to hinder that, quite the opposite in fact, it is here
to help that. Helping people that want to evolve mm by not requirement
them to understand every single device driver.


> 
> > Also having each driver duplicating this code increase the risk of
> > one getting a little detail wrong. The hope is that sharing same
> > HMM code with all the driver then everyone benefit from debugging
> > the same code (i am hopping i do not have many bugs left :))
> 
> "each driver duplicating code" begs for refactoring driver code to
> common code and this refactoring is hindered if it must adhere to an
> "HMM" api.

Again HMM API can evolve, i am happy to help with any such change, given
it provides benefit to either mm or device driver (ie changing the HMM
just for the sake of changing the HMM API would not make much sense to
me).

So if after converting driver A, B and C we see that it would be nicer
to change HMM in someway then i will definitly do that and this patchset
is a testimony of that. Converting ODP to use HMM is easier after this
patchset and this patchset changes the HMM API. I will be updating the
nouveau driver to the new API and use the new API for the other driver
patchset i am working on.

If i bump again into something that would be better done any differently
i will definitly change the HMM API and update all upstream driver
accordingly.

I am a strong believer in full freedom for internal kernel API changes
and my intention have always been to help and facilitate such process.
I am sorry this was unclear to any body :( and i am hopping that this
email make my intention clear.

Cheers,
Jérôme


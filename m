Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 367FBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:12:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D182F2175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:12:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D182F2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CB426B0005; Tue, 19 Mar 2019 18:12:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67B586B0006; Tue, 19 Mar 2019 18:12:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5435F6B0007; Tue, 19 Mar 2019 18:12:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA486B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:12:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j184so500029pgd.7
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:12:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=BQidobWBe+c9x9WY4pB2y8pL2fYKqqjM+P4XFplU32g=;
        b=jZwOuIBU78M7yS2LbemQPP8yf/tGygv/ffIpXLQXPCtg9yJY3SAVSB0Y9xJwu1bH9k
         xTBQAkcWG6vB0wQt7jrYmzJMX8yXXtTn+Qd/2QKQUXyNZFymPBol5mQcVa+hmhltfimw
         MZQxBSStIqVUdekuhs/Y6qBOkfmYtPF6wwu3WzjoKFYrQLpXvcGZUYBj15PMcAcS1XDS
         DIwfKuhGPYhAyFhVI4GZBAiyh5bZSpsYBAEAeC463u9DqaLiVEOUiHvpDXm3w+oCxqH4
         jXs9zemCkug74VkOtwTaApszI2nFoLvGN9QW7gHgEuH2j4TAfufqA4QGG3JIAwLkKNCp
         VV1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVP25PkXwNl4pEKl6FDO5m0huu+PIH6ulv9v26Qk/OQ2dTI/qnR
	Ou0Wea/JU6MMA71A5y0jqTd8dyfQpDsAeJFjojC97ZDGbeUBi908fApWYQFdqjNzFg7WynzFpWk
	FiHfJvUydnda1Qc+/111ty2VTvzhnneYny2ECqIXd5gGRFqslringpkwVXO97gpN+Rw==
X-Received: by 2002:a63:c149:: with SMTP id p9mr4106552pgi.362.1553033550712;
        Tue, 19 Mar 2019 15:12:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxybd6+smnYWjIga55YJ8BxkBzlwxXBEMHuh2Vo/824Zy0us/Q1zX9ewnY191+9QyMlMvVN
X-Received: by 2002:a63:c149:: with SMTP id p9mr4106448pgi.362.1553033549228;
        Tue, 19 Mar 2019 15:12:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553033549; cv=none;
        d=google.com; s=arc-20160816;
        b=san6/2C0Vr9IFzNvMbTZT2t55vpSia4+Zub8JOAuPdPg5EfvOBeELICDW8oviH1EUD
         geeMjX4SiiEVmsGRnMCoApOZbU5MyhnY+64V73KugatAwwPo/1AnR8xYYbohD0C9fDHd
         pnDz8iERlSu7q4zDS2DhSCv3ihVGzJj0Pw+1whz4bUadq37WJk2XTbMSWpmcHx+sn0o+
         McNW0c/f9k489+0qQepZshMTMREKKovIfthJRQAuaQTeXpzDss1QTEqLK2E4PKcxti1w
         m4NgURt81jCDFPoz+dvgUq6ZyEDEmmZd1QKL1DKDHgHysZjNbhzMzkwi0flD5+47b3Q1
         WKhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=BQidobWBe+c9x9WY4pB2y8pL2fYKqqjM+P4XFplU32g=;
        b=oSu9p4CbJjlF2wfr0Q0RKA++RslU9TUcoZnJoEeDoivBjP+6b841B17NZN9dX/91Kl
         JHRPhLubdjbhjC04QXXpMFSLks1RZVTyyq2bx81MFtNoMa8NaIOaUMClt7QEBpLDnQCY
         5wqKEVCnm8t/DfdhePff7K4y2KQjEC2OPTnbcuGRI+lAydZ8tG40N6EI78zVIZzT40U1
         wveHX8debfkdBZ8Xqh7sjBlx3peO+sUK4UpLdUaFvXkArRZnf5tgvGDKcD2LxPt1Ayu9
         9VamCDQxlfuevRd8UQ3VbZrm1Cmp4pG+FylR2A4rYpS4+LVr31Y+oOOvtUYm3haUPf7v
         1YMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j5si160372plk.387.2019.03.19.15.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 15:12:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Mar 2019 15:12:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,246,1549958400"; 
   d="scan'208";a="128417216"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 19 Mar 2019 15:12:02 -0700
Date: Tue, 19 Mar 2019 07:10:43 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 07/10] mm/hmm: add an helper function that fault pages
 and map them to a device
Message-ID: <20190319141043.GI7485@iweiny-DESK2.sc.intel.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-8-jglisse@redhat.com>
 <CAA9_cmcN+8B_tyrxRy5MMr-AybcaDEEWB4J8dstY6h0cmFxi3g@mail.gmail.com>
 <20190318204134.GD6786@redhat.com>
 <CAPcyv4he6v5JQMucezZV4J3i+Ea-i7AsaGpCOnc4f-stCrhGag@mail.gmail.com>
 <20190318221515.GA6664@redhat.com>
 <CAPcyv4gYUfEDSsGa_e1v8hqHyyvX8pEc75=G33aaQ6EWG3pSZA@mail.gmail.com>
 <20190319133004.GA3437@redhat.com>
 <20190319084457.GD7485@iweiny-DESK2.sc.intel.com>
 <20190319171043.GB3656@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190319171043.GB3656@redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 01:10:43PM -0400, Jerome Glisse wrote:
> On Tue, Mar 19, 2019 at 01:44:57AM -0700, Ira Weiny wrote:
> > On Tue, Mar 19, 2019 at 09:30:05AM -0400, Jerome Glisse wrote:
> > > On Mon, Mar 18, 2019 at 08:29:45PM -0700, Dan Williams wrote:
> > > > On Mon, Mar 18, 2019 at 3:15 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > >
> > > > > On Mon, Mar 18, 2019 at 02:30:15PM -0700, Dan Williams wrote:
> > > > > > On Mon, Mar 18, 2019 at 1:41 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > > > >
> > > > > > > On Mon, Mar 18, 2019 at 01:21:00PM -0700, Dan Williams wrote:
> > > > > > > > On Tue, Jan 29, 2019 at 8:55 AM <jglisse@redhat.com> wrote:
> > > > > > > > >
> > > > > > > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > > > > > >

[snip]

> > > > >
> > > > > The API is not temporary it will stay the same ie the device driver
> > > > > using HMM would not need further modification. Only the inner working
> > > > > of HMM would be ported over to use improved common GUP. But GUP has
> > > > > few shortcoming today that would be a regression for HMM:
> > > > >     - huge page handling (ie dma mapping huge page not 4k chunk of
> > > > >       huge page)
> > 
> > Agreed.
> > 
> > > > >     - not incrementing page refcount for HMM (other user like user-
> > > > >       faultd also want a GUP without FOLL_GET because they abide by
> > > > >       mmu notifier)
> > > > >     - support for device memory without leaking it ie restrict such
> > > > >       memory to caller that can handle it properly and are fully
> > > > >       aware of the gotcha that comes with it
> > > > >     ...
> > > > 
> > > > ...but this is backwards because the end state is 2 driver interfaces
> > > > for dealing with page mappings instead of one. My primary critique of
> > > > HMM is that it creates a parallel universe of HMM apis rather than
> > > > evolving the existing core apis.
> > > 
> > > Just to make it clear here is pseudo code:
> > >     gup_range_dma_map() {...}
> > > 
> > >     hmm_range_dma_map() {
> > >         hmm_specific_prep_step();
> > >         gup_range_dma_map();
> > 
> > Does this GUP use FOLL_GET and then a put after the mmu_notifier is setup?
> 
> No it avoids incrementing page refcount all together and use mmu notifier
> synchronization to garantee that it is fine to do so. Hence we need a way
> to do GUP without incrementing the page refcount (ie no FOLL_GET but still
> returning page).

Isn't this follow_page?  I'll admit it may be broken and I'll further admit
that fixing it may have unintended consequences on drivers using GUP but some
of the code in this series looks a lot like the code there.

> 
> > 
> > >         hmm_specific_post_step();
> > >     }
> > > 
> > > Like i said HMM do have the synchronization with mmu notifier to take
> > > care of and other user of GUP and dma map pattern do not care about
> > > that. Hence why not everything can be share between device driver that
> > > can not do mmu notifier and other.
> > > 
> > > Is that not acceptable to you ? Should every driver duplicate the code
> > > HMM factorize ?
> > > 
> > 
> > In the final API you envision will drivers be able to call gup_range_dma_map()
> > _or_ hmm_range_dma_map()?
> > 
> > If so, at that time how will drivers know which to call and parameters control
> > those calls?
> 
> Device that can do invalidation at anytime and thus that can support
> mmu notifier will use HMM and thus the HMM version of it and they will
> always stick with the HMM version.
> 
> Device that can not do invalidation at anytime and thus require pin
> will use the GUP version and always the GUP version.
> 
> What the HMM version does is extra synchronization with mmu notifier
> to ensure that not incrementing page refcount is fine. You can think
> of HMM mirror as an helper than handle mmu notifier common device
> driver pattern.

ok sounds fair.

> 
> > 
> > > 
> > > > > So before converting HMM to use common GUP code under-neath those GUP
> > > > > shortcoming (from HMM POV) need to be addressed and at the same time
> > > > > the common dma map pattern can be added as an extra GUP helper.
> > > > 
> > > > If the HMM special cases are not being absorbed into the core-mm over
> > > > time then I think this is going in the wrong direction. Specifically a
> > > > direction that increases the long term maintenance burden over time as
> > > > HMM drivers stay needlessly separated.
> > > 
> > > HMM is core mm and other thing like GUP do not need to absord all of HMM
> > > as it would be forcing down on them mmu notifier and those other user can
> > > not leverage mmu notifier. So forcing down something that is useless on
> > > other is pointless, don't you agree ?
> > > 
> > > > 
> > > > > The issue is that some of the above changes need to be done carefully
> > > > > to not impact existing GUP users. So i rather clear some of my plate
> > > > > before starting chewing on this carefully.
> > > > 
> > > > I urge you to put this kind of consideration first and not "merge
> > > > first, ask hard questions later".
> > > 
> > > There is no hard question here. GUP does not handle THP optimization and
> > > other thing HMM and ODP has. Adding this to GUP need to be done carefully
> > > to not break existing GUP user. So i taking a small step approach since
> > > when that is a bad thing. First merge HMM and ODP together then push down
> > > common thing into GUP. It is a lot safer than a huge jump.
> > 
> > FWIW I think it is fine to have a new interface which allows new features
> > during a transition is a good thing.  But if that comes at the price of leaving
> > the old "deficient" interface sitting around that presents confusion for driver
> > writers and we get users calling GUP when perhaps they should be calling HMM.
> 
> This is not the intention here, i am converting device driver that can use
> HMM to HMM. Those device driver do not need GUP in the sense that they do
> not need the page refcount increment and this is the short path the HMM does
> provide today. Now i want to convert all device that can follow that to use
> HMM (i posted patchset for amdgpu, radeon, nouveau, i915 and odp rdma for
> that already).
> 
> Device driver that can not do mmu notifier will never use HMM and stick to
> the GUP/dma map pattern. But i want to share the same underlying code for
> both API latter on.

Great!  We agree on something!  :-D

> 
> So i do not see how it would confuse anyone. I am probably bad at expressing
> intent but HMM is not for all device driver it is only for device driver that
> would be able to do mmu notifier but instead of doing mmu notifier directly
> and duplicating common code they can use HMM which has all the common code
> they would need.

I guess I see HMM being bigger than that _eventually_.  I see it being a "one
stop shop" for devices to get pages from the system...  But I think what you
have limited it to is good for now.

Basic pseudocode:

hmm_get_pages()
	if (!mmu_capability)
		do_gup_stuff
	else
		do_hmm_stuff

	return pages;

> 
> > 
> > I think having GPL exports helps to ensure we can later merge these to make it
> > clear to driver writers what the right thing to do is.
> 
> I am fine with GPL export but i stress agains this does not help in the GPU
> world we had tons of GPL driver that are not upstream. GPL was not the issue.
> So i fail to see how GPL helps device driver writer in anyway.

GPL to ensure we can change the interfaces of HMM at will and have a good
chance of getting all the drivers in tree fixed.  There are a couple of patches
in this series which change the interface of exported symbols.  I think this is
fine but it shows we are not ready to export this interface to out of tree users.

> 
> > > 
> > > > 
> > > > > Also doing this patch first and then the GUP thing solve the first user
> > > > > problem you have been asking for. With that code in first the first user
> > > > > of the GUP convertion will be all the devices that use those two HMM
> > > > > functions. In turn the first user of that code is the ODP RDMA patch i
> > > > > already posted. Second will be nouveau once i tackle out some nouveau
> > > > > changes. I expect amdgpu to come close third as a user and other device
> > > > > driver who are working on HMM integration to come shortly after.
> > > > 
> > > > I appreciate that it has users, but the point of having users is so that
> > > > the code review can actually be fruitful to see if the infrastructure makes
> > > > sense, and in this case it seems to be duplicating an existing common
> > > > pattern in the kernel.
> > > 
> > > It is not duplicating anything i am removing code at the end if you include
> >            ^^^^^^^^^^^^^
> > 
> > The duplication is in how drivers indicate to the core that a set of pages is
> > being used by the hardware the driver is controlling, what the rules for those
> > pages are and how the use by that hardware is going to be coordinated with the
> > other hardware vying for those pages.  There are differences, true, but
> > fundamentally it would be nice for drivers to not have to care about the
> > details.
> > 
> > Maybe that is a dream we will never realize but if there are going to be
> > different ways for drivers to "get pages" then we need to make it clear what it
> > means when those pages come to the driver and how they can be used safely.
> 
> This is exactly what HMM mirror is. Device driver do not have to care about
> mm gory details or about mmu notifier subtilities, HMM provide an abstracted
> API easy to understand for device driver and takes care of the sublte details.

If the device supports MMU notification.  ;-)

> 
> Please read the HMM documentation and provide feedback if that is not clear.

FWIW I also want to be clear that having some common code to handle MMU
notification would be great.  I've had to fix mmu_notification code in the past
because mmu notification code can be tricky.  So I'm not against HMM helping
out there.  But I also don't want to leave drivers which don't do MMU
notification with a broken GUP interface.

Ira

> 
> Cheers,
> Jérôme


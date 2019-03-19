Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04ADBC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:10:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A67CE20863
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:10:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A67CE20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25C4C6B0005; Tue, 19 Mar 2019 13:10:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2098D6B0006; Tue, 19 Mar 2019 13:10:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D0786B0007; Tue, 19 Mar 2019 13:10:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D45336B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:10:48 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l187so5799271qkd.7
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:10:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vblmO6igSQTptWv8RKQopUll0J5c945HV2Je+EfRzXY=;
        b=jO8R08W5Q8WHPB3sI1wasIcrSLZvDRPKsLRS3ScNlz7WftdK/eDp1dgbHH9ElxjhSA
         6dO06Ik+9eQxoN9emk3wRZAaXKwWr3QnGQkzbx+CmhF4hxThzcJlcRVx6NY52Ptt2vCm
         aIoBkoafRV4OC2RMC7eQO7wHcQrvun0Plw3TkySVJBPOAgdIl9uNXFR8ENgj3nLX/z42
         25V1UMmRsulkyTlu9CQe6qIkI10wDmh6V3QwB0ksVqOmUEIXxZ03APx56rhoDiD2aIvL
         8aywLd329qym2ZgZxdz3QuRMvt66gIFASQhI3rwScMvv45fgwnZ8zXXdsOi6hD3EKYhC
         RwGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVTdFAPqU5j08pgtLeB0GcScOc83WQDsIsNqhQXZDNXfGoJH9vc
	nkQ5QnTueM3VYDR8+V+8Pc1mlk8UDgZZYXc/n6kGUYIWhGhtBmt0pcR9gBK4gPJkqj8Qs1X8XYG
	trqvNlS+xAxM1esBeTjo9WCDnSrSalc8f5NkMPxtiEKs625a+NQOUGpJ4Pv63S6Lp8w==
X-Received: by 2002:ac8:100e:: with SMTP id z14mr2840786qti.137.1553015448507;
        Tue, 19 Mar 2019 10:10:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziBQDHDFEbdV8kvS62t8Fh013jf0unl6wsHoe921Nx8BhwXmkNrmGuzvEZ69LNx6a//LnD
X-Received: by 2002:ac8:100e:: with SMTP id z14mr2840707qti.137.1553015447363;
        Tue, 19 Mar 2019 10:10:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553015447; cv=none;
        d=google.com; s=arc-20160816;
        b=tJ9gHP+Kl2GXLTHC/XJcQuGHBXKXH3JXRqMysHM2WbPs2MmK6S+hrjfzHYkXYbtvIz
         o1TrFC/KKkRRlXyFPaMD8n7bnrTbAadLOcrwAtwOarLUHRhDd/obQijGG9TfJkshvlJq
         i4lcmtLyyzWqwB+IE/ddimZghNvZ8zZroiqOlVLFfitDJxzNz40iRsdOp9Wo0JD8V/cD
         RDLaL9ckZP7OkZEBjCd0J8Qhsx94kDZjQslMeAdNx7Wr94B8OD4kk9cgW9ANO0EW3bfY
         8ErtjDYEpjvI+oDrMdGjWdbPHYmnoBQVvZxmuizTU3agzSuF4a978CPt0gDILdOlsedr
         maog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=vblmO6igSQTptWv8RKQopUll0J5c945HV2Je+EfRzXY=;
        b=leju20CYYctg3E8v6LumuUggW2jEyQI8O7n8X2TnZtxc/jARM4H29eJYN+5/7uFZkG
         yke1ZT/jWc/d8n2KblFJSO0zjP0CWDfd1CQGqJ/N8Prc+vqQ6dpNJrqzZZkZMfTAaw6S
         XgJlVeAXNb5fP6QRXqVemqhMHda7FvLPRaJaAJ1qXF2b4vJeg/R5bNltCb8TgDm/GTT1
         XDtSrxQSS80np8xRgI7ZtBIKhqoIBikLXC3vdKZu0hn50G12oelD9AUE8YmlWHuDp3Br
         M09h5XohwpAs6Owl/QvwhxvO2/coKeAy7D2rp861rgbpDcX8wlLeFExA7hHmmqnPzi7E
         dCug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r14si3626470qki.125.2019.03.19.10.10.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 10:10:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1F46881E07;
	Tue, 19 Mar 2019 17:10:46 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 47C6719C65;
	Tue, 19 Mar 2019 17:10:45 +0000 (UTC)
Date: Tue, 19 Mar 2019 13:10:43 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 07/10] mm/hmm: add an helper function that fault pages
 and map them to a device
Message-ID: <20190319171043.GB3656@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-8-jglisse@redhat.com>
 <CAA9_cmcN+8B_tyrxRy5MMr-AybcaDEEWB4J8dstY6h0cmFxi3g@mail.gmail.com>
 <20190318204134.GD6786@redhat.com>
 <CAPcyv4he6v5JQMucezZV4J3i+Ea-i7AsaGpCOnc4f-stCrhGag@mail.gmail.com>
 <20190318221515.GA6664@redhat.com>
 <CAPcyv4gYUfEDSsGa_e1v8hqHyyvX8pEc75=G33aaQ6EWG3pSZA@mail.gmail.com>
 <20190319133004.GA3437@redhat.com>
 <20190319084457.GD7485@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190319084457.GD7485@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 19 Mar 2019 17:10:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 01:44:57AM -0700, Ira Weiny wrote:
> On Tue, Mar 19, 2019 at 09:30:05AM -0400, Jerome Glisse wrote:
> > On Mon, Mar 18, 2019 at 08:29:45PM -0700, Dan Williams wrote:
> > > On Mon, Mar 18, 2019 at 3:15 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > >
> > > > On Mon, Mar 18, 2019 at 02:30:15PM -0700, Dan Williams wrote:
> > > > > On Mon, Mar 18, 2019 at 1:41 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > > >
> > > > > > On Mon, Mar 18, 2019 at 01:21:00PM -0700, Dan Williams wrote:
> > > > > > > On Tue, Jan 29, 2019 at 8:55 AM <jglisse@redhat.com> wrote:
> > > > > > > >
> > > > > > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > > > > >
> > > > > > > > This is a all in one helper that fault pages in a range and map them to
> > > > > > > > a device so that every single device driver do not have to re-implement
> > > > > > > > this common pattern.
> > > > > > >
> > > > > > > Ok, correct me if I am wrong but these seem effectively be the typical
> > > > > > > "get_user_pages() + dma_map_page()" pattern that non-HMM drivers would
> > > > > > > follow. Could we just teach get_user_pages() to take an HMM shortcut
> > > > > > > based on the range?
> > > > > > >
> > > > > > > I'm interested in being able to share code across drivers and not have
> > > > > > > to worry about the HMM special case at the api level.
> > > > > > >
> > > > > > > And to be clear this isn't an anti-HMM critique this is a "yes, let's
> > > > > > > do this, but how about a more fundamental change".
> > > > > >
> > > > > > It is a yes and no, HMM have the synchronization with mmu notifier
> > > > > > which is not common to all device driver ie you have device driver
> > > > > > that do not synchronize with mmu notifier and use GUP. For instance
> > > > > > see the range->valid test in below code this is HMM specific and it
> > > > > > would not apply to GUP user.
> > > > > >
> > > > > > Nonetheless i want to remove more HMM code and grow GUP to do some
> > > > > > of this too so that HMM and non HMM driver can share the common part
> > > > > > (under GUP). But right now updating GUP is a too big endeavor.
> > > > >
> > > > > I'm open to that argument, but that statement then seems to indicate
> > > > > that these apis are indeed temporary. If the end game is common api
> > > > > between HMM and non-HMM drivers then I think these should at least
> > > > > come with /* TODO: */ comments about what might change in the future,
> > > > > and then should be EXPORT_SYMBOL_GPL since they're already planning to
> > > > > be deprecated. They are a point in time export for a work-in-progress
> > > > > interface.
> > > >
> > > > The API is not temporary it will stay the same ie the device driver
> > > > using HMM would not need further modification. Only the inner working
> > > > of HMM would be ported over to use improved common GUP. But GUP has
> > > > few shortcoming today that would be a regression for HMM:
> > > >     - huge page handling (ie dma mapping huge page not 4k chunk of
> > > >       huge page)
> 
> Agreed.
> 
> > > >     - not incrementing page refcount for HMM (other user like user-
> > > >       faultd also want a GUP without FOLL_GET because they abide by
> > > >       mmu notifier)
> > > >     - support for device memory without leaking it ie restrict such
> > > >       memory to caller that can handle it properly and are fully
> > > >       aware of the gotcha that comes with it
> > > >     ...
> > > 
> > > ...but this is backwards because the end state is 2 driver interfaces
> > > for dealing with page mappings instead of one. My primary critique of
> > > HMM is that it creates a parallel universe of HMM apis rather than
> > > evolving the existing core apis.
> > 
> > Just to make it clear here is pseudo code:
> >     gup_range_dma_map() {...}
> > 
> >     hmm_range_dma_map() {
> >         hmm_specific_prep_step();
> >         gup_range_dma_map();
> 
> Does this GUP use FOLL_GET and then a put after the mmu_notifier is setup?

No it avoids incrementing page refcount all together and use mmu notifier
synchronization to garantee that it is fine to do so. Hence we need a way
to do GUP without incrementing the page refcount (ie no FOLL_GET but still
returning page).

> 
> >         hmm_specific_post_step();
> >     }
> > 
> > Like i said HMM do have the synchronization with mmu notifier to take
> > care of and other user of GUP and dma map pattern do not care about
> > that. Hence why not everything can be share between device driver that
> > can not do mmu notifier and other.
> > 
> > Is that not acceptable to you ? Should every driver duplicate the code
> > HMM factorize ?
> > 
> 
> In the final API you envision will drivers be able to call gup_range_dma_map()
> _or_ hmm_range_dma_map()?
> 
> If so, at that time how will drivers know which to call and parameters control
> those calls?

Device that can do invalidation at anytime and thus that can support
mmu notifier will use HMM and thus the HMM version of it and they will
always stick with the HMM version.

Device that can not do invalidation at anytime and thus require pin
will use the GUP version and always the GUP version.

What the HMM version does is extra synchronization with mmu notifier
to ensure that not incrementing page refcount is fine. You can think
of HMM mirror as an helper than handle mmu notifier common device
driver pattern.

> 
> > 
> > > > So before converting HMM to use common GUP code under-neath those GUP
> > > > shortcoming (from HMM POV) need to be addressed and at the same time
> > > > the common dma map pattern can be added as an extra GUP helper.
> > > 
> > > If the HMM special cases are not being absorbed into the core-mm over
> > > time then I think this is going in the wrong direction. Specifically a
> > > direction that increases the long term maintenance burden over time as
> > > HMM drivers stay needlessly separated.
> > 
> > HMM is core mm and other thing like GUP do not need to absord all of HMM
> > as it would be forcing down on them mmu notifier and those other user can
> > not leverage mmu notifier. So forcing down something that is useless on
> > other is pointless, don't you agree ?
> > 
> > > 
> > > > The issue is that some of the above changes need to be done carefully
> > > > to not impact existing GUP users. So i rather clear some of my plate
> > > > before starting chewing on this carefully.
> > > 
> > > I urge you to put this kind of consideration first and not "merge
> > > first, ask hard questions later".
> > 
> > There is no hard question here. GUP does not handle THP optimization and
> > other thing HMM and ODP has. Adding this to GUP need to be done carefully
> > to not break existing GUP user. So i taking a small step approach since
> > when that is a bad thing. First merge HMM and ODP together then push down
> > common thing into GUP. It is a lot safer than a huge jump.
> 
> FWIW I think it is fine to have a new interface which allows new features
> during a transition is a good thing.  But if that comes at the price of leaving
> the old "deficient" interface sitting around that presents confusion for driver
> writers and we get users calling GUP when perhaps they should be calling HMM.

This is not the intention here, i am converting device driver that can use
HMM to HMM. Those device driver do not need GUP in the sense that they do
not need the page refcount increment and this is the short path the HMM does
provide today. Now i want to convert all device that can follow that to use
HMM (i posted patchset for amdgpu, radeon, nouveau, i915 and odp rdma for
that already).

Device driver that can not do mmu notifier will never use HMM and stick to
the GUP/dma map pattern. But i want to share the same underlying code for
both API latter on.

So i do not see how it would confuse anyone. I am probably bad at expressing
intent but HMM is not for all device driver it is only for device driver that
would be able to do mmu notifier but instead of doing mmu notifier directly
and duplicating common code they can use HMM which has all the common code
they would need.

> 
> I think having GPL exports helps to ensure we can later merge these to make it
> clear to driver writers what the right thing to do is.

I am fine with GPL export but i stress agains this does not help in the GPU
world we had tons of GPL driver that are not upstream. GPL was not the issue.
So i fail to see how GPL helps device driver writer in anyway.

> > 
> > > 
> > > > Also doing this patch first and then the GUP thing solve the first user
> > > > problem you have been asking for. With that code in first the first user
> > > > of the GUP convertion will be all the devices that use those two HMM
> > > > functions. In turn the first user of that code is the ODP RDMA patch i
> > > > already posted. Second will be nouveau once i tackle out some nouveau
> > > > changes. I expect amdgpu to come close third as a user and other device
> > > > driver who are working on HMM integration to come shortly after.
> > > 
> > > I appreciate that it has users, but the point of having users is so that
> > > the code review can actually be fruitful to see if the infrastructure makes
> > > sense, and in this case it seems to be duplicating an existing common
> > > pattern in the kernel.
> > 
> > It is not duplicating anything i am removing code at the end if you include
>            ^^^^^^^^^^^^^
> 
> The duplication is in how drivers indicate to the core that a set of pages is
> being used by the hardware the driver is controlling, what the rules for those
> pages are and how the use by that hardware is going to be coordinated with the
> other hardware vying for those pages.  There are differences, true, but
> fundamentally it would be nice for drivers to not have to care about the
> details.
> 
> Maybe that is a dream we will never realize but if there are going to be
> different ways for drivers to "get pages" then we need to make it clear what it
> means when those pages come to the driver and how they can be used safely.

This is exactly what HMM mirror is. Device driver do not have to care about
mm gory details or about mmu notifier subtilities, HMM provide an abstracted
API easy to understand for device driver and takes care of the sublte details.

Please read the HMM documentation and provide feedback if that is not clear.

Cheers,
Jérôme


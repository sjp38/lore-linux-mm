Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DE7CC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:38:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F01B721734
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:38:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F01B721734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BB108E0009; Wed, 24 Jul 2019 16:38:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96BED8E0002; Wed, 24 Jul 2019 16:38:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 833D48E0009; Wed, 24 Jul 2019 16:38:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65FE88E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:38:48 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l14so40327068qke.16
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:38:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=mYCnwlDrFOeB58JxVB5YgZuCp6wcmGxGKrxXr5i4nBc=;
        b=XfmQk1ZXWNKU2cKcLVtMcSAyBBbY4BpG49UNlOxNw7Vs6au9nXhF3V5K/1fulhFxmV
         UZJ03ulEOYPt5Aq2rQKyKxS/lNvQsnQjDafZh7Ie/GlcBZTfzVDcR85raalSvSY1Rlhs
         ne+jxTA+1A32CXU2DiLU6A4RdtbWH/OoHUs6SNBk1X+FmaN9YntQepRpRcoR4oXBwzRi
         xwTvLapYMHdLMXefy7GiHQWczctcud17xFwjdVZEijXn1jvMbCjUlMs8WtCqFnUFnNIW
         h75w/C3XxFvC1wVNyXUzAtPSmKFarJ30rEmLNEGmlIdShE91qo+1ltk0LYDNS/q5msvd
         jRFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUniiYJTkh6ebOX14Dxls3kWykvd7+eKWeUO3K9zwdgISiB4FEQ
	yZRiQUjqXgislMoGDQ9EVwXozFt23rUF4M+d8s7bpfDd7Ux2TclEW+OSVt/QG9tmk1qWZUk3OqR
	fTMELHWPLtW806oHaMXI1QWs3PQRBfTmRtom19KzEz2B5+8C+1/RGTqZNhUsFygo4ug==
X-Received: by 2002:a37:274a:: with SMTP id n71mr51554018qkn.448.1564000728135;
        Wed, 24 Jul 2019 13:38:48 -0700 (PDT)
X-Received: by 2002:a37:274a:: with SMTP id n71mr51553995qkn.448.1564000727440;
        Wed, 24 Jul 2019 13:38:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564000727; cv=none;
        d=google.com; s=arc-20160816;
        b=0u83abk2lxztKkTDluv6N8x4Mytc23IAp2PA59V5TJCp3KYjY+JecfWj+MyoFXBuLi
         bkZ6SIFAoY5GyzpnaRNQkfmfq7UuChgvZ3RoE46tYXSzCsdSdlmc+QIfZ2WLt/Hs0wvU
         QIE5k5iiHcNHivu67yPfc4iVVN/nVfB0nAI2FNnD4X/rbAUcR4WqM3IR72Sh0oXPQCdh
         RMf02tlXX/x68Z/erM+PaSP0nHgn49Cyr8fmWOHcyqmHu5TxeKtVl/QthgRQOCZiZfDL
         UDv3CkpEZNVuQK5uJOQQI510hJ+xt6tYoSXik3vnNHJx70jeSTDCrDQLQkFz2dXSVOct
         bKPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=mYCnwlDrFOeB58JxVB5YgZuCp6wcmGxGKrxXr5i4nBc=;
        b=aXwAdX9wgxspryPazK3HG5rUHapn6JA9cly7ICSbAaPCFoi5DBkLvDz3YshIa5OTHK
         pggzLrzbiNiDq1gqP88SWxeNMUg2NYej3xMmgYV1/z0r0qQUV5+i+lXGhLSglLKilQRv
         OGHzEynIADeQr63W1kXAyKNAtd7tg8RSEvoSaeO5Z2rTqntmH/4PM2nrN985a54qoUkr
         +TF8cBk8JSn6nh7FW22l9SsEP+AqytTn3FrXyJwD7FGVlf2ait7Omh/Mr7JEcvywaD8K
         f2F5VkWX8P1lhUQVHxoV5OIQ8jJdzcx7Lc01s1g4m6cpN5ou8vlKb4DQOPOnbMw6kvOh
         hnjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m50sor62813036qtf.44.2019.07.24.13.38.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 13:38:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwU3o8Gh0p3iTRF2eUwetU3mRzbYpX3En+58mi7Qps50FM4raDCZMFHQwALO71XaeJ6K+oBpg==
X-Received: by 2002:ac8:394b:: with SMTP id t11mr58254877qtb.286.1564000727125;
        Wed, 24 Jul 2019 13:38:47 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id a23sm19743310qtp.22.2019.07.24.13.38.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 13:38:46 -0700 (PDT)
Date: Wed, 24 Jul 2019 16:38:39 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
	david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
Message-ID: <20190724163516-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
 <088abe33117e891dd6265179f678847bd574c744.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <088abe33117e891dd6265179f678847bd574c744.camel@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 01:27:35PM -0700, Alexander Duyck wrote:
> On Wed, 2019-07-24 at 14:40 -0400, Nitesh Narayan Lal wrote:
> > On 7/24/19 12:54 PM, Alexander Duyck wrote:
> > > This series provides an asynchronous means of hinting to a hypervisor
> > > that a guest page is no longer in use and can have the data associated
> > > with it dropped. To do this I have implemented functionality that allows
> > > for what I am referring to as page hinting
> > > 
> > > The functionality for this is fairly simple. When enabled it will allocate
> > > statistics to track the number of hinted pages in a given free area. When
> > > the number of free pages exceeds this value plus a high water value,
> > > currently 32,
> > Shouldn't we configure this to a lower number such as 16?
> 
> Yes, we could do 16.
> 
> > >  it will begin performing page hinting which consists of
> > > pulling pages off of free list and placing them into a scatter list. The
> > > scatterlist is then given to the page hinting device and it will perform
> > > the required action to make the pages "hinted", in the case of
> > > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > > and as such they are forced out of the guest. After this they are placed
> > > back on the free list, and an additional bit is added if they are not
> > > merged indicating that they are a hinted buddy page instead of a standard
> > > buddy page. The cycle then repeats with additional non-hinted pages being
> > > pulled until the free areas all consist of hinted pages.
> > > 
> > > I am leaving a number of things hard-coded such as limiting the lowest
> > > order processed to PAGEBLOCK_ORDER,
> > Have you considered making this option configurable at the compile time?
> 
> We could. However, PAGEBLOCK_ORDER is already configurable on some
> architectures. I didn't see much point in making it configurable in the
> case of x86 as there are only really 2 orders that this could be used in
> that provided good performance and that MAX_ORDER - 1 and PAGEBLOCK_ORDER.
> 
> > >  and have left it up to the guest to
> > > determine what the limit is on how many pages it wants to allocate to
> > > process the hints.
> > It might make sense to set the number of pages to be hinted at a time from the
> > hypervisor.
> 
> We could do that. Although I would still want some upper limit on that as
> I would prefer to keep the high water mark as a static value since it is
> used in an inline function. Currently the virtio driver is the one
> defining the capacity of pages per request.
> 
> > > My primary testing has just been to verify the memory is being freed after
> > > allocation by running memhog 79g on a 80g guest and watching the total
> > > free memory via /proc/meminfo on the host. With this I have verified most
> > > of the memory is freed after each iteration. As far as performance I have
> > > been mainly focusing on the will-it-scale/page_fault1 test running with
> > > 16 vcpus. With that I have seen at most a 2% difference between the base
> > > kernel without these patches and the patches with virtio-balloon disabled.
> > > With the patches and virtio-balloon enabled with hinting the results
> > > largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a 2%
> > > drop in performance as I approached 16 threads,
> > I think this is acceptable.
> > >  however on the the lastest
> > > linux-next kernel I saw roughly a 4% to 5% improvement in performance for
> > > all tests with 8 or more threads. 
> > Do you mean that with your patches the will-it-scale/page_fault1 numbers were
> > better by 4-5% over an unmodified kernel?
> 
> Yes. That is the odd thing. I am wondering if there was some improvement
> in the zeroing of THP pages or something that is somehow improving the
> cache performance for the accessing of the pages by the test in the guest.

Well cache is indexed by the PA on intel, right?  So if you end up never
writing into the pages, reading them will be faster because you will end
up with a zero page. This will be offset by a fault when you finally do
write into the page.

> > > I believe the difference seen is due to
> > > the overhead for faulting pages back into the guest and zeroing of memory.
> > It may also make sense to test these patches with netperf to observe how much
> > performance drop it is introducing.
> 
> Do you have some test you were already using? I ask because I am not sure
> netperf would generate a large enough memory window size to really trigger
> much of a change in terms of hinting. If you have some test in mind I
> could probably set it up and run it pretty quick.
> 
> > > Patch 4 is a bit on the large side at about 600 lines of change, however
> > > I really didn't see a good way to break it up since each piece feeds into
> > > the next. So I couldn't add the statistics by themselves as it didn't
> > > really make sense to add them without something that will either read or
> > > increment/decrement them, or add the Hinted state without something that
> > > would set/unset it. As such I just ended up adding the entire thing as
> > > one patch. It makes it a bit bigger but avoids the issues in the previous
> > > set where I was referencing things before they had been added.
> > > 
> > > Changes from the RFC:
> > > https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
> > > Moved aeration requested flag out of aerator and into zone->flags.
> > > Moved bounary out of free_area and into local variables for aeration.
> > > Moved aeration cycle out of interrupt and into workqueue.
> > > Left nr_free as total pages instead of splitting it between raw and aerated.
> > > Combined size and physical address values in virtio ring into one 64b value.
> > > 
> > > Changes from v1:
> > > https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
> > > Dropped "waste page treatment" in favor of "page hinting"
> > We may still have to try and find a better name for virtio-balloon side changes.
> > As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.
> 
> We just need to settle on a name. Essentially all this requires is just a
> quick find and replace with whatever name we decide on.


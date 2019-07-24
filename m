Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBB13C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:00:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5657821873
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:00:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5657821873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6E596B0008; Wed, 24 Jul 2019 17:00:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1F1B6B000A; Wed, 24 Jul 2019 17:00:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9354A8E0002; Wed, 24 Jul 2019 17:00:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB486B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:00:38 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id k9so24826056pls.13
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:00:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=L3JKCmwuOKZkVMFJ0SgGZ7eiqsLsKTPAmax4+QI8MpE=;
        b=BJ2LuRiu7njCPJue6qDDsQPpK1AlbAyOtmD1woQ/2S7yirdX1J5jSqXf+6soQS/Yhd
         JTOQne553TJYwvQ3CTItmy+O0kKYHPfkhmeA0XaoR8werwnQkG5IM5z+PrjEveOHFlsB
         qmR++G3tcunxvpiANXOfS9hM4t6c97ObqkX8UpEb4LzLcNpfXs/mWtkTI9jMUywaFKJi
         XJ+WCt/igP9k0ESBLHZggcwN/Ycb6kfgSGGd1KfY4OV9fwyGK+/S+FY9Kqx7lr9SE0CL
         bEwr88Ay3mU7wjQe4zb+iBEBg6C1XnlwPDtWSXqx9wnWzvnH+aOstrpJVdil/+2SkvpS
         SMDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWdUmx5HLxmcaE8Nd/Agm4+keM/Og+tt3yABEgqThX3VveW15c1
	5bpmL100TZXCFJ9Yzbp5o4LT0+YQxFysHVtlewXvPp/PhDjkzqJ4byX/KqhnEUWqqaU9Cn0+ksM
	oMyXv6NKmQKkonx//ygxbxpqDdYmP8+ltuGHLWnnKntffq9KCT3weM7EkzBRLAA4rYA==
X-Received: by 2002:a17:90a:e38f:: with SMTP id b15mr91231047pjz.85.1564002037938;
        Wed, 24 Jul 2019 14:00:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw62s+TRRFSA5CNEnzBAMz8Ys8SP4Ki65lvpOIKWfXzYJrIbiFOOvXM0r5k9dbY9iMg+Rli
X-Received: by 2002:a17:90a:e38f:: with SMTP id b15mr91230939pjz.85.1564002036706;
        Wed, 24 Jul 2019 14:00:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564002036; cv=none;
        d=google.com; s=arc-20160816;
        b=ye/xNheB41ryCcZWw8CwySFJWCGqo7TEQMo2gx9hvrBHeBFtPWGzEWDaTweQ4yseQ2
         8xdcP9ggnw7UUjzIrFnbxbNyKfHsoOW2ldrRw1h9rM+tkzNbKJyzZ2Kh97vetfiAR0co
         Z6VKeLtMEGDt++m3bvGXgPFIc4TgDxa0nylS3YZzUhms53hx5K+Thid93Fvwqg6QMtIS
         RN/vv1LuLeokw6xlVYb0XJN+COlx01VGep5cvYhU5KUoI3ghb5vjfd0ZobQtkEEBT8lb
         9r4tWjulI+Mjy6xMyhY3Q8+m4dmgpkUS+oHtok1p3uRwNYV+qbvDQdGp4aGrLlkz+thn
         kvCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=L3JKCmwuOKZkVMFJ0SgGZ7eiqsLsKTPAmax4+QI8MpE=;
        b=M0eRFKpmkTiwBf038bd+yBGKfUIOyoVmqkZotOeRyh6wVwaeMPjvZ6S4/CTkIPWKgq
         wEiqrrXpLL4YY/M8vzSpGQ6FuMLYmzGKdDMmZKGIYPvWwDEmqCNz8cXRGJ7NgkglRO+b
         SWUV74icDqHyrRjdo9Kw16vq2GypxYS+WTftRE23IYtSHTalktQHVjxYCe2fky30dQhm
         IdqCbgVugXpi5Qsk4xYYd2PGDzcgoPc6+ll+VGzBwEIhKAWRRT28zmeNuJPoccMGTjuu
         8k7zqLIykitGBBKYR697o3+KaKiMgp6TzPtBRKT5OZLEU0ZN3PwKRsz0XXpyoe0+bd4a
         woCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id bx21si16913233pjb.21.2019.07.24.14.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 14:00:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 14:00:35 -0700
X-IronPort-AV: E=Sophos;i="5.64,304,1559545200"; 
   d="scan'208";a="175004483"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga006-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 14:00:35 -0700
Message-ID: <c5f6c247f9a28d374678bae01952ca7fd2c044b2.camel@linux.intel.com>
Subject: Re: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com, 
	aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com
Date: Wed, 24 Jul 2019 14:00:35 -0700
In-Reply-To: <e738fa65-cd1f-a9d2-8db5-318de3e49a81@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
	 <088abe33117e891dd6265179f678847bd574c744.camel@linux.intel.com>
	 <e738fa65-cd1f-a9d2-8db5-318de3e49a81@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-24 at 16:38 -0400, Nitesh Narayan Lal wrote:
> On 7/24/19 4:27 PM, Alexander Duyck wrote:
> > On Wed, 2019-07-24 at 14:40 -0400, Nitesh Narayan Lal wrote:
> > > On 7/24/19 12:54 PM, Alexander Duyck wrote:
> > > > This series provides an asynchronous means of hinting to a hypervisor
> > > > that a guest page is no longer in use and can have the data associated
> > > > with it dropped. To do this I have implemented functionality that allows
> > > > for what I am referring to as page hinting
> > > > 
> > > > The functionality for this is fairly simple. When enabled it will allocate
> > > > statistics to track the number of hinted pages in a given free area. When
> > > > the number of free pages exceeds this value plus a high water value,
> > > > currently 32,
> > > Shouldn't we configure this to a lower number such as 16?
> > Yes, we could do 16.
> > 
> > > >  it will begin performing page hinting which consists of
> > > > pulling pages off of free list and placing them into a scatter list. The
> > > > scatterlist is then given to the page hinting device and it will perform
> > > > the required action to make the pages "hinted", in the case of
> > > > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > > > and as such they are forced out of the guest. After this they are placed
> > > > back on the free list, and an additional bit is added if they are not
> > > > merged indicating that they are a hinted buddy page instead of a standard
> > > > buddy page. The cycle then repeats with additional non-hinted pages being
> > > > pulled until the free areas all consist of hinted pages.
> > > > 
> > > > I am leaving a number of things hard-coded such as limiting the lowest
> > > > order processed to PAGEBLOCK_ORDER,
> > > Have you considered making this option configurable at the compile time?
> > We could. However, PAGEBLOCK_ORDER is already configurable on some
> > architectures. I didn't see much point in making it configurable in the
> > case of x86 as there are only really 2 orders that this could be used in
> > that provided good performance and that MAX_ORDER - 1 and PAGEBLOCK_ORDER.
> > 
> > > >  and have left it up to the guest to
> > > > determine what the limit is on how many pages it wants to allocate to
> > > > process the hints.
> > > It might make sense to set the number of pages to be hinted at a time from the
> > > hypervisor.
> > We could do that. Although I would still want some upper limit on that as
> > I would prefer to keep the high water mark as a static value since it is
> > used in an inline function. Currently the virtio driver is the one
> > defining the capacity of pages per request.
> For the upper limit I think we can rely on max vq size. Isn't?

I would still want to limit how many pages could be pulled. Otherwise we
have the risk of a hypervisor that allocates a vq size of 1024 or
something like that and with 4M pages that could essentially OOM a 4G
guest.

That is why I figure what we probably should do is base the upper limit of
either 16 or 32 so that we only have at most something like 64M or 128M of
memory being held by the driver while it is being "reported". If we leave
spare room in the ring so be it, better that then triggering unneeded OOM
conditions.

> > > > My primary testing has just been to verify the memory is being freed after
> > > > allocation by running memhog 79g on a 80g guest and watching the total
> > > > free memory via /proc/meminfo on the host. With this I have verified most
> > > > of the memory is freed after each iteration. As far as performance I have
> > > > been mainly focusing on the will-it-scale/page_fault1 test running with
> > > > 16 vcpus. With that I have seen at most a 2% difference between the base
> > > > kernel without these patches and the patches with virtio-balloon disabled.
> > > > With the patches and virtio-balloon enabled with hinting the results
> > > > largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a 2%
> > > > drop in performance as I approached 16 threads,
> > > I think this is acceptable.
> > > >  however on the the lastest
> > > > linux-next kernel I saw roughly a 4% to 5% improvement in performance for
> > > > all tests with 8 or more threads. 
> > > Do you mean that with your patches the will-it-scale/page_fault1 numbers were
> > > better by 4-5% over an unmodified kernel?
> > Yes. That is the odd thing. I am wondering if there was some improvement
> > in the zeroing of THP pages or something that is somehow improving the
> > cache performance for the accessing of the pages by the test in the guest.
> The values you were observing on an unmodified kernel, were they consistent over
> fresh reboot?
> Do you have any sort of workload running in the host as that could also impact
> the numbers.

The host was an unmodified linux-next kernel. What I was doing is I would
reboot, load the guest run one kernel, swap the kernel in the guest and
just reboot the guest, run the next kernel, and then switch back to the
first kernel to make certain there wasn't anything that changed between
the runs.

I still need to do more research though. I'm still suspecting it has
something to do with the page zeroing on faults though as that was what
was showing up on a perf top when we hit about 8 or more threads active in
the guest.

> > > > I believe the difference seen is due to
> > > > the overhead for faulting pages back into the guest and zeroing of memory.
> > > It may also make sense to test these patches with netperf to observe how much
> > > performance drop it is introducing.
> > Do you have some test you were already using? I ask because I am not sure
> > netperf would generate a large enough memory window size to really trigger
> > much of a change in terms of hinting. If you have some test in mind I
> > could probably set it up and run it pretty quick.
> Earlier I have tried running netperf on a guest with 2 cores, i.e., netserver
> pinned to one and netperf running on the other.
> You have to specify a really large packet size and run the test for at least
> 15-30 minutes to actually see some hinting work.

I can take a look. I am not expecting much though.

> > > > Patch 4 is a bit on the large side at about 600 lines of change, however
> > > > I really didn't see a good way to break it up since each piece feeds into
> > > > the next. So I couldn't add the statistics by themselves as it didn't
> > > > really make sense to add them without something that will either read or
> > > > increment/decrement them, or add the Hinted state without something that
> > > > would set/unset it. As such I just ended up adding the entire thing as
> > > > one patch. It makes it a bit bigger but avoids the issues in the previous
> > > > set where I was referencing things before they had been added.
> > > > 
> > > > Changes from the RFC:
> > > > https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
> > > > Moved aeration requested flag out of aerator and into zone->flags.
> > > > Moved bounary out of free_area and into local variables for aeration.
> > > > Moved aeration cycle out of interrupt and into workqueue.
> > > > Left nr_free as total pages instead of splitting it between raw and aerated.
> > > > Combined size and physical address values in virtio ring into one 64b value.
> > > > 
> > > > Changes from v1:
> > > > https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
> > > > Dropped "waste page treatment" in favor of "page hinting"
> > > We may still have to try and find a better name for virtio-balloon side changes.
> > > As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.
> > We just need to settle on a name. Essentially all this requires is just a
> > quick find and replace with whatever name we decide on.
> I agree.

I will probably look at seeing if I can keep the kernel feature as free
page hinting and just make the virtio feature page reporting. It should be
pretty straight forward as I could just replace the mentions of react with
report and only have to tweak a few bits of patch 5.


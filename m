Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C856C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:27:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3508214AF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:27:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3508214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 557268E0005; Wed, 24 Jul 2019 16:27:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 506EC8E0002; Wed, 24 Jul 2019 16:27:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F6558E0005; Wed, 24 Jul 2019 16:27:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05C518E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:27:38 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z14so22026099pgr.22
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:27:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=gmB/9+wblEJMV44K6Z5Fc6AdxiHIkxCCl8e9AWzVAYc=;
        b=LPf0oB90aeuGONKmglEmTfhC1BkUNcqd0q517I5IyH/xO17gGlQQwoDBOC/0UvX38w
         hZ3wHyhWZFgIB5VS/TpZe/wq4BWNyP9WCmpDLxq6NhnU/7YJXjjIzRZYMg6cHBJAaH0V
         dKdy2vbF1nwt7+iZvoKReGNXXZeQpIDy28TDmyPU7op2ZX1WQO55k2DOoMRYHh8V3miM
         7+k66rz5H2URVIgBzIJt6w3F+QKh6qQxEavdTZ7asiygkPGtB0d/fDrGlxI/XPXvtRxn
         GLjysmjY4lIo6LJ2QyWeJOKUnHEOPxltBEItnWVnQnmj4+LhCy9TQ8ajC7muWMeMVr10
         pvYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUBGD14Q6aSOXFjsy6+g6caUy6OtThVPjzaIeHKmSgek1N2xtjZ
	TUEyP4OYc6x+qvg7XGAGfYhf8w6k2sy7C3E3m6qp3Q4yho0Kzt8gGEWmeI/IeLvtopt0NyZH91G
	jvI78M2MlP3O/unxvYaq1hD7xmOmeziXkq+ev/+eLkzDUmlo1nXkZjzSFo4r6kK+cAQ==
X-Received: by 2002:a65:4507:: with SMTP id n7mr79809298pgq.86.1564000057585;
        Wed, 24 Jul 2019 13:27:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbohyGeFVNvNk5uXFGkI/Ju99MZKPjuhsX0bLndqQuLtq74Gv7yV7rQNglxtSNPDV1havR
X-Received: by 2002:a65:4507:: with SMTP id n7mr79809254pgq.86.1564000056709;
        Wed, 24 Jul 2019 13:27:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564000056; cv=none;
        d=google.com; s=arc-20160816;
        b=sCB8o0TsVZOY2BNpWtujxh5XocF3fIj8M/fOpy37xteoc2TeV7IsjVcs/iYMmS9O39
         ZnfBIaaemkQD1wK6JK2KYrbdZRFtf0tunRurDZnmkCT39AO85Af2jTCN5GtYu1N980HC
         RKMtdlSBT1xCgSRCoPoKX7VxenwBODadlFdTWTaAzcbr2hn0vlJcCQxPyycSj6CbY4mc
         veVHKbbsqCK6TrrisYHn0QsqrjgjSZu4BQpT9Xz1/Sk73KCsNmM/vr3sM9KwqyxBDxWn
         zBsXqwEb1VuZXrCMWwITQW6s6q7iMDFKtuO18GP49CbFw658qVTDhglQSWu0ScCwYVOT
         IRSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=gmB/9+wblEJMV44K6Z5Fc6AdxiHIkxCCl8e9AWzVAYc=;
        b=H/D5RiHdAuKx2g/KCME7AFkBeBL0Qjf0lJ+fOHV2Gkk9gHWDWtefV2Xye/vwQwlmEv
         ji31Bwlt/4ZOGPG0/cCaRIKIIQoovRLMc4SynFzu23xy3zOd3kYIXz93Dnjt9X6vphhF
         TpU+R3qy6S/f3ut6lw4oXsyR8CE7JFWcr8bM4gMQBv/MKRG0c5Lb+0FoC7wN902ohvnE
         25PIDDLuHAvbInnrxq8hKy07wT2cw9GvpnQD7BJbUQXmuS0v7gmIaQka+nCYx1A5notG
         F1gNgpTfigZqCn9fyZ+7ZkBbffFFKoY5obN/hUhdBg/awm1kXqLb9o+WzBfud+RSIiXC
         WWzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x24si16468891pjt.88.2019.07.24.13.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 13:27:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 13:27:36 -0700
X-IronPort-AV: E=Sophos;i="5.64,304,1559545200"; 
   d="scan'208";a="163961711"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 13:27:35 -0700
Message-ID: <088abe33117e891dd6265179f678847bd574c744.camel@linux.intel.com>
Subject: Re: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com, 
	aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com
Date: Wed, 24 Jul 2019 13:27:35 -0700
In-Reply-To: <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-24 at 14:40 -0400, Nitesh Narayan Lal wrote:
> On 7/24/19 12:54 PM, Alexander Duyck wrote:
> > This series provides an asynchronous means of hinting to a hypervisor
> > that a guest page is no longer in use and can have the data associated
> > with it dropped. To do this I have implemented functionality that allows
> > for what I am referring to as page hinting
> > 
> > The functionality for this is fairly simple. When enabled it will allocate
> > statistics to track the number of hinted pages in a given free area. When
> > the number of free pages exceeds this value plus a high water value,
> > currently 32,
> Shouldn't we configure this to a lower number such as 16?

Yes, we could do 16.

> >  it will begin performing page hinting which consists of
> > pulling pages off of free list and placing them into a scatter list. The
> > scatterlist is then given to the page hinting device and it will perform
> > the required action to make the pages "hinted", in the case of
> > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > and as such they are forced out of the guest. After this they are placed
> > back on the free list, and an additional bit is added if they are not
> > merged indicating that they are a hinted buddy page instead of a standard
> > buddy page. The cycle then repeats with additional non-hinted pages being
> > pulled until the free areas all consist of hinted pages.
> > 
> > I am leaving a number of things hard-coded such as limiting the lowest
> > order processed to PAGEBLOCK_ORDER,
> Have you considered making this option configurable at the compile time?

We could. However, PAGEBLOCK_ORDER is already configurable on some
architectures. I didn't see much point in making it configurable in the
case of x86 as there are only really 2 orders that this could be used in
that provided good performance and that MAX_ORDER - 1 and PAGEBLOCK_ORDER.

> >  and have left it up to the guest to
> > determine what the limit is on how many pages it wants to allocate to
> > process the hints.
> It might make sense to set the number of pages to be hinted at a time from the
> hypervisor.

We could do that. Although I would still want some upper limit on that as
I would prefer to keep the high water mark as a static value since it is
used in an inline function. Currently the virtio driver is the one
defining the capacity of pages per request.

> > My primary testing has just been to verify the memory is being freed after
> > allocation by running memhog 79g on a 80g guest and watching the total
> > free memory via /proc/meminfo on the host. With this I have verified most
> > of the memory is freed after each iteration. As far as performance I have
> > been mainly focusing on the will-it-scale/page_fault1 test running with
> > 16 vcpus. With that I have seen at most a 2% difference between the base
> > kernel without these patches and the patches with virtio-balloon disabled.
> > With the patches and virtio-balloon enabled with hinting the results
> > largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a 2%
> > drop in performance as I approached 16 threads,
> I think this is acceptable.
> >  however on the the lastest
> > linux-next kernel I saw roughly a 4% to 5% improvement in performance for
> > all tests with 8 or more threads. 
> Do you mean that with your patches the will-it-scale/page_fault1 numbers were
> better by 4-5% over an unmodified kernel?

Yes. That is the odd thing. I am wondering if there was some improvement
in the zeroing of THP pages or something that is somehow improving the
cache performance for the accessing of the pages by the test in the guest.

> > I believe the difference seen is due to
> > the overhead for faulting pages back into the guest and zeroing of memory.
> It may also make sense to test these patches with netperf to observe how much
> performance drop it is introducing.

Do you have some test you were already using? I ask because I am not sure
netperf would generate a large enough memory window size to really trigger
much of a change in terms of hinting. If you have some test in mind I
could probably set it up and run it pretty quick.

> > Patch 4 is a bit on the large side at about 600 lines of change, however
> > I really didn't see a good way to break it up since each piece feeds into
> > the next. So I couldn't add the statistics by themselves as it didn't
> > really make sense to add them without something that will either read or
> > increment/decrement them, or add the Hinted state without something that
> > would set/unset it. As such I just ended up adding the entire thing as
> > one patch. It makes it a bit bigger but avoids the issues in the previous
> > set where I was referencing things before they had been added.
> > 
> > Changes from the RFC:
> > https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
> > Moved aeration requested flag out of aerator and into zone->flags.
> > Moved bounary out of free_area and into local variables for aeration.
> > Moved aeration cycle out of interrupt and into workqueue.
> > Left nr_free as total pages instead of splitting it between raw and aerated.
> > Combined size and physical address values in virtio ring into one 64b value.
> > 
> > Changes from v1:
> > https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
> > Dropped "waste page treatment" in favor of "page hinting"
> We may still have to try and find a better name for virtio-balloon side changes.
> As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.

We just need to settle on a name. Essentially all this requires is just a
quick find and replace with whatever name we decide on.


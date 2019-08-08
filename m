Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC6F0C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:11:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66A7B217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:11:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66A7B217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BA0A6B0007; Thu,  8 Aug 2019 11:11:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16A286B0008; Thu,  8 Aug 2019 11:11:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 080E96B000A; Thu,  8 Aug 2019 11:11:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2C556B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:11:29 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r142so59219431pfc.2
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:11:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=8ryn0mTSvtZfZZWd6sps/pXPu27Z0h8myxaw8I0Z8Fs=;
        b=oVh7d+HTPLx0GOVH8ytdpL1LSxC57xW/P8TR48d7MyMqWPWSO49mGoWc3RYUbWMdHs
         qq2obejvz5pX5w6b/gB2YFqPPkligNfh7HZ08zjPP1kj2YrgDaBV+dn7nEg6t3WV2iDd
         SLpI5o+OZ8vs0LJSbj3+hVf1i3YVvyxZ/QLxRpLsbSYLYuEydGM+SQChh8lPBXMLZINY
         azNTrlaV3BI0bUd4+zLu5Y5WLTfzCR/DWrgj310Jv0lCIKtvuCH9XHpNAjQtdEE93mvI
         EIPe601C99vQc3k9/IMoWAnq75UbGrqV0avwWwlvZKX98IVX9o0kqHOG9NIQJ+coRwEx
         NrpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVjPCFIihSJ/8jVjNj8SNa0apQwy53OJZJ3DX6ja0DMOG7BpcIx
	2N0VAnf4kjzf3ZAaQNh9tb/Ava4w4Pd5B8OHh5hOWt5peMTeSroWuIYLPvPZlhpWOOr5gRD40Gx
	ZpvGKzJbnDqyef9sHxHZsV3BL9QPR94qq7vwKeiC398oRakhL4TW+xl4QasyJjpnefg==
X-Received: by 2002:a62:1597:: with SMTP id 145mr15471922pfv.180.1565277089449;
        Thu, 08 Aug 2019 08:11:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmywJ6FDNj4gXg9t8jxj+YiWKAMKy5yt668zs2yAkhXOsJc+xPPC4QIfp41qnQPKgcdW32
X-Received: by 2002:a62:1597:: with SMTP id 145mr15471840pfv.180.1565277088446;
        Thu, 08 Aug 2019 08:11:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565277088; cv=none;
        d=google.com; s=arc-20160816;
        b=CN1ztaxKVKQ1YvFU1tyYmWFs5kn+rKND6bOqgEgSS85RCcJzQ9gZNE/dTCO1b0MRBX
         n4WK8Q9w469P9Z6gDNpyh0Slgazanr5YEWTvwYStAYMnAMB5OpPQ2QZUowSk5Y3yQK2W
         8q3fBowDM/IEu2zDh1hkoqDw8KxqPecWmC6jB7gF1sAvHBvyMOfPCc1sW1X4taW+d7aF
         02GjiNGGyYvNt/HNqNQXB4Oj06eP2serkOpox2Y2iMJ5hvf8lvjS7JRzU2TUjGF1yO1v
         NfSL2RGH8vLGZ7jBQZ1/Kc+IMvLc4aoZs2qeNbz5mvWOnCur4YW+ZSo89Q8CdOTzVV8z
         13SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=8ryn0mTSvtZfZZWd6sps/pXPu27Z0h8myxaw8I0Z8Fs=;
        b=Uyk3dIeu63aBJT5gBHnM0g9EG/Ti/89tpmvYcVGaBzstu9MgLsrUf+0NHiSXK3Wx7M
         LwczHwmmtm+IDKWafVPgRqpVY3WF92/COWP8KiR2Pde28rOmCBYYlJScVKxSAHWodGwC
         ZK0lRzurnOiMssZWVk5Edlngt7L4+mAJ5Zfh1psT0VqDg9SpWwgymMroUdO257w01mQ7
         8qOa/3tM6OBF0RVXUgvxVi/+LeTl7rIriPpTYdsv/Jfv1gi9gzfJDhzhNeicAy2Ylu3D
         f6d3gSjGUmZux91uahGArQGT/kciiVdBAaDiekqmal9j1nG3PvSsaWIPMj2PaHEPWEM9
         Eh+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id n9si53094146pgj.171.2019.08.08.08.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 08:11:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Aug 2019 08:11:27 -0700
X-IronPort-AV: E=Sophos;i="5.64,361,1559545200"; 
   d="scan'208";a="350202217"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga005-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Aug 2019 08:11:27 -0700
Message-ID: <f721f0642c3eff7bf2d07110e16cc4ce199ab23a.camel@linux.intel.com>
Subject: Re: [PATCH v4 4/6] mm: Introduce Reported pages
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com, 
	dan.j.williams@intel.com
Date: Thu, 08 Aug 2019 08:11:27 -0700
In-Reply-To: <ad008459-5618-0859-82cb-6cc7c8e5dcc4@redhat.com>
References: <20190807224037.6891.53512.stgit@localhost.localdomain>
	 <20190807224206.6891.81215.stgit@localhost.localdomain>
	 <ad008459-5618-0859-82cb-6cc7c8e5dcc4@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-08-08 at 09:45 -0400, Nitesh Narayan Lal wrote:
> On 8/7/19 6:42 PM, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > In order to pave the way for free page reporting in virtualized
> > environments we will need a way to get pages out of the free lists and
> > identify those pages after they have been returned. To accomplish this,
> > this patch adds the concept of a Reported Buddy, which is essentially
> > meant to just be the Uptodate flag used in conjunction with the Buddy
> > page type.
> > 
> > It adds a set of pointers we shall call "boundary" which represents the
> > upper boundary between the unreported and reported pages. The general idea
> > is that in order for a page to cross from one side of the boundary to the
> > other it will need to go through the reporting process. Ultimately a
> > free_list has been fully processed when the boundary has been moved from
> > the tail all they way up to occupying the first entry in the list.
> > 
> > Doing this we should be able to make certain that we keep the reported
> > pages as one contiguous block in each free list. This will allow us to
> > efficiently manipulate the free lists whenever we need to go in and start
> > sending reports to the hypervisor that there are new pages that have been
> > freed and are no longer in use.
> > 
> > An added advantage to this approach is that we should be reducing the
> > overall memory footprint of the guest as it will be more likely to recycle
> > warm pages versus trying to allocate the reported pages that were likely
> > evicted from the guest memory.
> > 
> > Since we will only be reporting one zone at a time we keep the boundary
> > limited to being defined for just the zone we are currently reporting pages
> > from. Doing this we can keep the number of additional pointers needed quite
> > small. To flag that the boundaries are in place we use a single bit
> > in the zone to indicate that reporting and the boundaries are active.
> > 
> > The determination of when to start reporting is based on the tracking of
> > the number of free pages in a given area versus the number of reported
> > pages in that area. We keep track of the number of reported pages per
> > free_area in a separate zone specific area. We do this to avoid modifying
> > the free_area structure as this can lead to false sharing for the highest
> > order with the zone lock which leads to a noticeable performance
> > degradation.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  include/linux/mmzone.h         |   40 +++++
> >  include/linux/page-flags.h     |   11 +
> >  include/linux/page_reporting.h |  138 ++++++++++++++++++
> >  mm/Kconfig                     |    5 +
> >  mm/Makefile                    |    1 
> >  mm/memory_hotplug.c            |    1 
> >  mm/page_alloc.c                |  136 +++++++++++++++++
> >  mm/page_reporting.c            |  313 ++++++++++++++++++++++++++++++++++++++++
> >  8 files changed, 637 insertions(+), 8 deletions(-)
> >  create mode 100644 include/linux/page_reporting.h
> >  create mode 100644 mm/page_reporting.c
> > 
> > 

<snip>

> > diff --git a/mm/page_reporting.c b/mm/page_reporting.c
> > new file mode 100644
> > index 000000000000..ae26dd77bce9
> > --- /dev/null
> > +++ b/mm/page_reporting.c
> > @@ -0,0 +1,313 @@

<snip>

> > +/*
> > + * The page reporting cycle consists of 4 stages, fill, report, drain, and idle.
> > + * We will cycle through the first 3 stages until we fail to obtain any
> > + * pages, in that case we will switch to idle.
> > + */
> > +static void page_reporting_cycle(struct zone *zone,
> > +				 struct page_reporting_dev_info *phdev)
> > +{
> > +	/*
> > +	 * Guarantee boundaries and stats are populated before we
> > +	 * start placing reported pages in the zone.
> > +	 */
> > +	if (page_reporting_populate_metadata(zone))
> > +		return;
> > +
> > +	spin_lock(&zone->lock);
> > +
> > +	/* set bit indicating boundaries are present */
> > +	__set_bit(ZONE_PAGE_REPORTING_ACTIVE, &zone->flags);
> > +
> > +	do {
> > +		/* Pull pages out of allocator into a scaterlist */
> > +		unsigned int nents = page_reporting_fill(zone, phdev);
> > +
> > +		/* no pages were acquired, give up */
> > +		if (!nents)
> > +			break;
> > +
> > +		spin_unlock(&zone->lock);
> > +
> > +		/* begin processing pages in local list */
> > +		phdev->report(phdev, nents);
> > +
> > +		spin_lock(&zone->lock);
> > +
> > +		/*
> > +		 * We should have a scatterlist of pages that have been
> > +		 * processed. Return them to their original free lists.
> > +		 */
> > +		page_reporting_drain(zone, phdev);
> > +
> > +		/* keep pulling pages till there are none to pull */
> > +	} while (test_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags));
> > +
> > +	/* processing of the zone is complete, we can disable boundaries */
> > +	__clear_bit(ZONE_PAGE_REPORTING_ACTIVE, &zone->flags);
> > +
> > +	spin_unlock(&zone->lock);
> > +}
> > +
> > +static void page_reporting_process(struct work_struct *work)
> > +{
> > +	struct delayed_work *d_work = to_delayed_work(work);
> > +	struct page_reporting_dev_info *phdev =
> > +		container_of(d_work, struct page_reporting_dev_info, work);
> > +	struct zone *zone = first_online_pgdat()->node_zones;
> > +
> > +	do {
> > +		if (test_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags))
> > +			page_reporting_cycle(zone, phdev);
> > +
> > +		/*
> > +		 * Move to next zone, if at the end of the list
> > +		 * test to see if we can just go into idle.
> > +		 */
> > +		zone = next_zone(zone);
> > +		if (zone)
> > +			continue;
> > +		zone = first_online_pgdat()->node_zones;
> > +
> > +		/*
> > +		 * As long as refcnt has not reached zero there are still
> > +		 * zones to be processed.
> > +		 */
> 
> can you please explain the reason why you are not using
> for_each_populated_zone() here?
> 
> 
> > +	} while (atomic_read(&phdev->refcnt));
> > +}
> > +

It mostly has to do with the way this code evolved. Originally I had this
starting at the last zone that was processed and resuming there with the
assumption that a noisy zone was going to trigger frequent events so why
walk the zones each time. However we aren't starting the loop that often
so I just decided to start at the beginning and walk the zones until I
found the one that had requested the reporting.

Also I probably wouldn't bother with the "populated" version of the call
since we already have a field to search for so it would just be a matter
of creating my own macro that would only give us zones that are requesting
reporting.

The last bit is that really the exit condition isn't that we hit the end
of the zone list. The exit condition for this loop is that phdev->refcnt
is zero. The problem with using for_each_zone is that you would keep
walking the zone list anyway until you hit the end of it even if we have
already processed the zones that requested reporting.


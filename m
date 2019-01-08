Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E2DBC43612
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 21:53:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4338620660
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 21:53:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4338620660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFBCB8E009D; Tue,  8 Jan 2019 16:53:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C84798E0038; Tue,  8 Jan 2019 16:53:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B25E58E009D; Tue,  8 Jan 2019 16:53:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0AA8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 16:53:06 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so2897809plb.18
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 13:53:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=G5O8wtLqCBPHHIqC79aJwgSZzGJC16jAuPeFQLK0h/c=;
        b=iAxg5VvOrAa5Sh9jszp0ZcUE/1X4+LJj4NBwsRh3UOXs3dVc26D+2WKGVo1iHQUsnN
         Uz+XqjvBmrTvVlo/ms9ol1/Aw6NmnJKaTp+iMiC+wDTGX3W9JwnLy7+Yj1ruLkcbxGdC
         7IOVc3ySf/1qgBaEyIUe3oAObOG194gjn3mwM7KDSIyduNom6uKdxxBAhkXuaRVVxKLA
         M7YVQ48RyH91ftzbaU7Ja4Ydq+T8BjEbx0d+c1vp47i4Zc7ISflRRbZbZNsDeJi3MblC
         9anXWNTKKtrF55zSXdsDbTTbZCmxWMEsCq0VCe9zSoymooxAqCjQQFWgQDFu/Veof9Tr
         fEnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukeapQvTo4uLk3XJue/YjeuWN3DcXufvNberHPd45jdGzPDEeXuL
	LQBgFZyc+evxbBD5pulNkd70ZqhByo141wptYCbhrrJPdFLGQXWKU8Iv6scC8cgoGnSkVi4OkuT
	mUsGZ2ZhYLcAuwcfrdIxlco2h8VvylKDkGDJJClBFf28dJiernXyKsVesD3yOip4ZyQ==
X-Received: by 2002:a62:a1a:: with SMTP id s26mr3431707pfi.31.1546984386107;
        Tue, 08 Jan 2019 13:53:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6LUggyNiGaeh/GC8uLGBTUk4m7fDljrOxfRrsvmEMTOPSfXKTFaO9OptGhgPRDSQz7L405
X-Received: by 2002:a62:a1a:: with SMTP id s26mr3431663pfi.31.1546984385186;
        Tue, 08 Jan 2019 13:53:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546984385; cv=none;
        d=google.com; s=arc-20160816;
        b=r/lxHugkwETIKbcUr9qlGB/cj+sg2jeBOvl7kydMnAEC/ybI5REwxbWCg1U6PTFTTm
         RAqSGdFyuzQvhnisyiR+fcJTpuF1eIIltYA/i7TJywXoYJLCdUrQnfTs/6XxjBkzFroI
         m61jCMrdMW8NhnEc6ZtzoAqN8MrSfIPmBvhW9Gahbqf+HF0ymiRnCwiBFjWt/MbgWfp+
         ciijdV9T/hExsUVEkwCUMboJ6i4ZN9KENcLSIQg0pnmO1dT238glRKSjsa0V6TTJ+7Gc
         uTzO27vg77usz/Akqjkh49+YKyTJG2Zgjxyx5mUgAxrTGF7Prmt7DBU/B872lL8dKc9F
         cZug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=G5O8wtLqCBPHHIqC79aJwgSZzGJC16jAuPeFQLK0h/c=;
        b=wbM10TwH9zVXzB1MGY3lssOn5oiNMNZZHQMQqBX0ONHJBUTTrbVuCA2nYd89A32zfs
         bZ6P4E9Ayw9tm+woUmQx6LtMW+71uR4/g2EgJL4bh6trLL5/Vhd2+ttE57v/dyb3dZtv
         mrByr4HxaUyrn8YROM5dQ4UodVLOyo0nMnFwnsq65qLyrusS0P5aBhY/F2Xj7iUFdyCR
         hkwz7SNrK1oZVpEBEbwrZ58EZj2xNJ2jKeRwPPsBXH3ypoNSONMZsLpkhVYUKaSS6nzi
         cEH/g9XyCGqDatlsbxpy4+PEf0X+qTOjW2io1SntNK13sLS+6NIzf3LmDmdHhBT/317w
         ehmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j14si10968118pgg.44.2019.01.08.13.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 13:53:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Jan 2019 13:53:04 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,455,1539673200"; 
   d="scan'208";a="105029250"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga007.jf.intel.com with ESMTP; 08 Jan 2019 13:53:03 -0800
Message-ID: <bbb4c6e046bb37b4a81573f5547cfb946cebe972.camel@linux.intel.com>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, 
	akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com
Date: Tue, 08 Jan 2019 13:53:03 -0800
In-Reply-To: <20190108200436.GK31793@dhcp22.suse.cz>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
	 <37498672d5b2345b1435477e78251282af42742b.camel@linux.intel.com>
	 <20190108200436.GK31793@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108215303.UlUc_HHWgqj7j7NXfpsya91NvS8h8GT97v5l4xIk6Eo@z>

On Tue, 2019-01-08 at 21:04 +0100, Michal Hocko wrote:
> On Tue 08-01-19 10:40:18, Alexander Duyck wrote:
> > On Fri, 2019-01-04 at 10:31 +0530, Arun KS wrote:
> > > When freeing pages are done with higher order, time spent on coalescing
> > > pages by buddy allocator can be reduced.  With section size of 256MB, hot
> > > add latency of a single section shows improvement from 50-60 ms to less
> > > than 1 ms, hence improving the hot add latency by 60 times.  Modify
> > > external providers of online callback to align with the change.
> > > 
> > > Signed-off-by: Arun KS <arunks@codeaurora.org>
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > Reviewed-by: Oscar Salvador <osalvador@suse.de>
> > 
> > After running into my initial issue I actually had a few more questions
> > about this patch.
> > 
> > > [...]
> > > +static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
> > > +{
> > > +	unsigned long end = start + nr_pages;
> > > +	int order, ret, onlined_pages = 0;
> > > +
> > > +	while (start < end) {
> > > +		order = min(MAX_ORDER - 1,
> > > +			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
> > > +
> > > +		ret = (*online_page_callback)(pfn_to_page(start), order);
> > > +		if (!ret)
> > > +			onlined_pages += (1UL << order);
> > > +		else if (ret > 0)
> > > +			onlined_pages += ret;
> > > +
> > > +		start += (1UL << order);
> > > +	}
> > > +	return onlined_pages;
> > >  }
> > >  
> > 
> > Should the limit for this really be MAX_ORDER - 1 or should it be
> > pageblock_order? In some cases this will be the same value, but I seem
> > to recall that for x86 MAX_ORDER can be several times larger than
> > pageblock_order.
> 
> Does it make any difference when we are in fact trying to onine nr_pages
> and we clamp to it properly?

I'm not entirely sure if it does or not.

What I notice looking through the code though is that there are a
number of checks for the pageblock migrate type. There ends up being
checks in __free_one_page, free_one_page, and __free_pages_ok all
related to this. It might be moot since we are starting with a offline
section, but I just brought this up because I know in the case of
deferred page init we were limiting ourselves to pageblock_order and I
wasn't sure if there was some specific reason for doing that.

> > >  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> > >  			void *arg)
> > >  {
> > > -	unsigned long i;
> > >  	unsigned long onlined_pages = *(unsigned long *)arg;
> > > -	struct page *page;
> > >  
> > >  	if (PageReserved(pfn_to_page(start_pfn)))
> > 
> > I'm not sure we even really need this check. Getting back to the
> > discussion I have been having with Michal in regards to the need for
> > the DAX pages to not have the reserved bit cleared I was originally
> > wondering if we could replace this check with a call to
> > online_section_nr since the section shouldn't be online until we set
> > the bit below in online_mem_sections.
> > 
> > However after doing some further digging it looks like this could
> > probably be dropped entirely since we only call this function from
> > online_pages and that function is only called by memory_block_action if
> > pages_correctly_probed returns true. However pages_correctly_probed
> > should return false if any of the sections contained in the page range
> > is already online.
> 
> Yes you are right but I guess it would be better to address in a
> separate patch that deals with PageReserved manipulation in general.
> I do not think we want to remove the check silently. People who might be
> interested in backporting this for whatever reason might screatch their
> head why the test is not needed anymore.

Yeah I am already working on that, it is what led me to review this
patch. Just thought I would bring it up since it would make it possible
to essentially reduce the size and/or need for a new function.


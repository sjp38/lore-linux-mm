Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15636C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 22:36:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A373B21916
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 22:36:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A373B21916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E71E46B0003; Thu, 21 Mar 2019 18:36:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E20F66B0006; Thu, 21 Mar 2019 18:36:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D10CF6B0007; Thu, 21 Mar 2019 18:36:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA576B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 18:36:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h69so297113pfd.21
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 15:36:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/J9nv2hX6UWKMr2II9vzpM3SerBuBExGQmcOvxECRaM=;
        b=XHqatQMQ0ukYJjD6eeuJuYKn2UV88ywVzNyl+AYy/KVnP/OVMk7EhhPmOdDx2CLg1h
         EpIkyGKkPPKxI9z6v8pysSZuukswwLjHNfLf6Dr6/qd4x2uRfV9HF7TpRvW5+8RF89rK
         +Z/LbQaUgf9hm3g9FoDyowGdJVqLHjf3c+BUEOfKAywDMX2DE0KgZ6UCurpSa1UHmgwq
         XWKLef5Ipdk0FbeaxBnlKiPJ4EhAdyBqMBxDAE35OIFoKmZOIeKF40kq9C8h0VfQoxKZ
         V9+XWY3f9yIBi0sx0FfcuFERjbiUU06fvwVO1utpH0i5OzzqRmMFDKmanKcHwg8Vcq1y
         zjgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW87bHhsOO9FsRW1Il1NpCCK5tmz96+LBbQncMivHEdukg8Bpak
	dEA3JEgAWRm33NTCcrXSVzS49J1IBUSXjSRuceXLnN/9RpB0hY1N72dZ0mhRCiJvsCtK1zhRhcP
	gs/he0CuyeHlnWgPpHJuKPXxMoosbe0q2opg5DQvpQZE96DDqmNOygoYWDrzP9ibTqQ==
X-Received: by 2002:a17:902:7c94:: with SMTP id y20mr4227009pll.263.1553207770224;
        Thu, 21 Mar 2019 15:36:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqBPbJ8Dumg7WSdu6sWf0L73xoiQFTJfch3gZ653NPfDPuzO/dHxIjTvJ4/tFPorQuWqIV
X-Received: by 2002:a17:902:7c94:: with SMTP id y20mr4226925pll.263.1553207769336;
        Thu, 21 Mar 2019 15:36:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553207769; cv=none;
        d=google.com; s=arc-20160816;
        b=0xoqI0aYK1j0VkJfWHgBWLyNXV+f8Ysz8QVgIsspk7AzOnnwJOSZfbS3kVqMJs7pCJ
         YMT3Ly2QCklXwqt0jiOnw22FMEN3HCnc5UdqssP3t2O+fDX70Sa/ItgctzbT7JXpoOGK
         NTWLe8jd7fC5Ca/onUGLh4haeyheCetgLB14AIei3CsW72rcGgORdbL+6IFPAFu7omPf
         AIF2jZ48dBJ4b20g4CBWvccDLOCgU4Jk+pJnBunE7Yr7GotbnSZEZnb3SNJoBDp1FTmF
         Ik6aTIh6ZYGBBbVHPqbBXCdP3RGS8CmntBpJ7nKZUoJvKrEsNWYR04E6Q2kuokiljSoy
         TeNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/J9nv2hX6UWKMr2II9vzpM3SerBuBExGQmcOvxECRaM=;
        b=gqhZaPug0X0GS6B+4Qi0jDYs5qPcOWNaYYR6AwpCHA5bfTNBQyDdLb2Ne6zae+5vvI
         DRPli5y+0J1zQ1UPrP4fq7Zf3krgTaNH3IGMx1MGoMUrEaaE5d9mLutdnman2whnWfVy
         6SHx05U/gUquS6QS8/alCESddHB9FF0x1RweCfFJF8QyiuF3fUF7ezOilJq67D7ehSjr
         S7egR9JW5RNiyhnTHQHuZkf6OUs7VGNzB5KIFikff68MKOq18BoggqwhXwrcz96o98tw
         xJTdWskzIqJfzDmrex1Z61q7gY23gqMm5ADXZT/W7UU5r6Y0FACdK7R/9tcKz0ncppkX
         vo8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l11si3413041pgp.216.2019.03.21.15.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 15:36:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Mar 2019 15:36:08 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,254,1549958400"; 
   d="scan'208";a="154574896"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga004.fm.intel.com with ESMTP; 21 Mar 2019 15:36:08 -0700
Date: Thu, 21 Mar 2019 16:37:08 -0600
From: Keith Busch <keith.busch@intel.com>
To: Zi Yan <ziy@nvidia.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	David Nellans <dnellans@nvidia.com>
Subject: Re: [PATCH 0/5] Page demotion for memory reclaim
Message-ID: <20190321223706.GA29817@localhost.localdomain>
References: <20190321200157.29678-1-keith.busch@intel.com>
 <5B5EFBC2-2979-4B9F-A43A-1A14F16ACCE1@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5B5EFBC2-2979-4B9F-A43A-1A14F16ACCE1@nvidia.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 02:20:51PM -0700, Zi Yan wrote:
> 1. The name of “page demotion” seems confusing to me, since I thought it was about large pages
> demote to small pages as opposite to promoting small pages to THPs. Am I the only
> one here?

If you have a THP, we'll skip the page migration and fall through to
split_huge_page_to_list(), then the smaller pages can be considered,
migrated and reclaimed individually. Not that we couldn't try to migrate
a THP directly. It was just simpler implementation for this first attempt.

> 2. For the demotion path, a common case would be from high-performance memory, like HBM
> or Multi-Channel DRAM, to DRAM, then to PMEM, and finally to disks, right? More general
> case for demotion path would be derived from the memory performance description from HMAT[1],
> right? Do you have any algorithm to form such a path from HMAT?

Yes, I have a PoC for the kernel setting up a demotion path based on
HMAT properties here:

  https://git.kernel.org/pub/scm/linux/kernel/git/kbusch/linux.git/commit/?h=mm-migrate&id=4d007659e1dd1b0dad49514348be4441fbe7cadb

The above is just from an experimental branch.

> 3. Do you have a plan for promoting pages from lower-level memory to higher-level memory,
> like from PMEM to DRAM? Will this one-way demotion make all pages sink to PMEM and disk?

Promoting previously demoted pages would require the application do
something to make that happen if you turn demotion on with this series.
Kernel auto-promotion is still being investigated, and it's a little
trickier than reclaim.

If it sinks to disk, though, the next access behavior is the same as
before, without this series.

> 4. In your patch 3, you created a new method migrate_demote_mapping() to migrate pages to
> other memory node, is there any problem of reusing existing migrate_pages() interface?

Yes, we may not want to migrate everything in the shrink_page_list()
pages. We might want to keep a page, so we have to do those checks first. At
the point we know we want to attempt migration, the page is already
locked and not in a list, so it is just easier to directly invoke the
new __unmap_and_move_locked() that migrate_pages() eventually also calls.
 
> 5. In addition, you only migrate base pages, is there any performance concern on migrating THPs?
> Is it too costly to migrate THPs?

It was just easier to consider single pages first, so we let a THP split
if possible. I'm not sure of the cost in migrating THPs directly.


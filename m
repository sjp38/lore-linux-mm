Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96D30C10F05
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:13:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4362A2147C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:13:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4362A2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC5CC6B0005; Thu,  4 Apr 2019 03:13:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D73A66B0007; Thu,  4 Apr 2019 03:13:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3B9B6B0008; Thu,  4 Apr 2019 03:13:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8636B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 03:13:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n24so862937edd.21
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 00:13:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bzXBhDCo5MEIGyQLwGYB52EX7hSgdilRXyadZpt7j20=;
        b=IWPkPd30Xb/0XVlmHoToX1Dx6E64smX++pO1NmzssBI7lR5QuP4frkebEk+WfjMrBZ
         UFpOxZmM9ZmHAgOMQDiNUt83G5Mft5A6GEirMPLyhIuU6o99WCtrZ4FgJkt1oW69L1hP
         BRey0zI4g/GMZnB+dsB7i0uOh4bxk477MIz+lHv1jUuV6Xu17Umc/q1HAVUEj2c3u7oN
         cmmchnuq3ueKgH5sD6Wu/vLbH2JbHx5htBHC7kp4HgLqCVifIXxeSdd3TCmGMGGTsEqB
         lf4s2tWOzh+48l4lPkZhh0HUzDuymKm+1I8SZXLbQCrhCTpJwS39qNTbtqJaZ/3EZTmY
         1/qg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXqz4b8SamBvwbw3hpZHXP5GlDQmDf2GakPWBcDTik1inqbYosx
	xhKm1cnWnWxJYtXYONePnyim44sGYQlglRyYs1jjbJ0uV/CugHVfmowlbh3rXjaZnyIEz317IGC
	OVnGyDGIznPOv2dQtQEMavY7eEnITU7yvm5WxA5u6kmi3P8bgi+j0iSJHt5jsHRk=
X-Received: by 2002:aa7:d954:: with SMTP id l20mr2677999eds.156.1554361997025;
        Thu, 04 Apr 2019 00:13:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLzx4AS77iTUlkE3vOCpu4Yx2rCfyqn3gTVrS4Yi2iDvFyfZZIm4kEwYqUvwWHs2KAGBOE
X-Received: by 2002:aa7:d954:: with SMTP id l20mr2677958eds.156.1554361996205;
        Thu, 04 Apr 2019 00:13:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554361996; cv=none;
        d=google.com; s=arc-20160816;
        b=c4EWg6H8P1AhTb+Af8hGRFU33BcJ8Vd0gZnqInAGpx5keuJEypbfkTOd1jQoD7Oj22
         obES/2B4yTRfzP4r9xpoKeRV/N7hS9Lh0nJGE5lxUJT885GNwDp46nitfWA+/K4SUKfQ
         juQWGJ2Y8ZcBGwnxf1rjJ6W343uercKAcXaXpBrDpmwP8EZCw9bpPhQ9yJ2v5sk1U7Ep
         jNOQOFO80HpAswxbrLLu6VPi8nOn3PK4Pfs/+/qTEgfJmTmRegsE3wdWxN0649d5kmIl
         J/54H2yWJwtraJAZZ7Klm+ab53YdPqafWgZFmg56i84zs3AWHlxGZl1KxmHgarTD3EJ1
         ReWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bzXBhDCo5MEIGyQLwGYB52EX7hSgdilRXyadZpt7j20=;
        b=YUm5UVcyNaSZXNjHVHNCBmxcnIeeQOiDPPokpREgsRHi+CMEMeCskFflCJf8yOCCZi
         FJIRZRCXjwRSLjcoNnZfkjSEbFias3Tms1JUlT3rftcw27kLS6JMOGHJdoX6nDsmsRX0
         yVPCF6E8I8ne44L5BhN2c4tpintk+JkqZBuRF+nnOWCos0RjaqcgrLR3ixLsLC6lq9w1
         Sb1BEuY2shNU2m20Uc3M5f55MLFBOzNegmu4xc/cyr9UTw+QkaeBjQpeKKrA3HJMpY3H
         FC57JbeeA9wceBIQfYzs1oNSb9Mk6X9DrYT5ha2jygLp3YZfu0eY7SNn+F4xBbovnJVW
         kjYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bq5si6673817ejb.119.2019.04.04.00.13.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 00:13:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 046F0B11F;
	Thu,  4 Apr 2019 07:13:14 +0000 (UTC)
Date: Thu, 4 Apr 2019 09:13:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: ziy@nvidia.com
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 00/25] Accelerate page migration and use memcg for
 PMEM management
Message-ID: <20190404071312.GD12864@dhcp22.suse.cz>
References: <20190404020046.32741-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-04-19 19:00:21, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
> 
> Thanks to Dave Hansen's patches, which make PMEM as part of memory as NUMA nodes.
> How to use PMEM along with normal DRAM remains an open problem. There are
> several patchsets posted on the mailing list, proposing to use page migration to
> move pages between PMEM and DRAM using Linux page replacement policy [1,2,3].
> There are some important problems not addressed in these patches:
> 1. The page migration in Linux does not provide high enough throughput for us to
> fully exploit PMEM or other use cases.
> 2. Linux page replacement is running too infrequent to distinguish hot and cold
> pages.
[...]
>  33 files changed, 4261 insertions(+), 162 deletions(-)

For a patch _this_ large you should really start with a real world
usecasing hitting bottlenecks with the current implementation. Should
microbenchmarks can trigger bottlenecks much easier but do real
application do the same? Please give us some numbers.
-- 
Michal Hocko
SUSE Labs


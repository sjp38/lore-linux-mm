Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDD72C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 08:07:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A273821873
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 08:07:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A273821873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 407BA6B0003; Thu, 21 Mar 2019 04:07:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3904C6B0006; Thu, 21 Mar 2019 04:07:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 230866B0007; Thu, 21 Mar 2019 04:07:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB24A6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 04:07:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id v26so1859633edr.23
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 01:07:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fbGoxH4umKl3Qxa86TBP5T5qqe0ByZ98JBv0PMF8/2s=;
        b=mKvM/ShcktMvEzEvp5jNcc9X5BgCZqZ21SPz/ABjdn6ZD5RN3lsclQDGjpgXsa7dPO
         9T6poqvepI5V1AbtfVxaQiejPDw3hx661TGHlbBZ2cdeZOcSJFb5JjH5/+OIApWfAggC
         1EluYiwavtOyQ9rp+8rqO5FzAO99zRPeyCgRwNfBTN2Ca4F31i4mdSVU5mU4mLpkn593
         DXVSk8O2YVimYdVlWkdnLRPqfBgO0DfkN67n5b4G1WlOHgdhXg4IIrAdw+KRIN09WOcP
         pgDcrgwAlpgygEbJAsHZTC2bkKZ7qG1e2jiy2/siJpbdRICuZMmEuhl+q86k2wA5xj7r
         9oEw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVayvYn9pIri40VLfljfiyOyieMZdSxDd45uVSKPxmu9A9nxMu+
	wINUrA0knWdsVXayw9eTvfQKJy+eGLT6cuQbLBvjh3xvkt4xfUhFhc5k+I2HTjaF1a0AaCvgvgF
	fMzkXoKeXT76r50IdkI/H6hEcRwcLQzVn7Q9Ms5Rl7FvtHaSBbALXTksr0nBzi9g=
X-Received: by 2002:a50:e606:: with SMTP id y6mr1540651edm.271.1553155625364;
        Thu, 21 Mar 2019 01:07:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWMqs8YiK5Nl735Nf+wQoXVlGSU89sJ2QYYM5/5EvQWbvuwGmftj2mibXAZ3o8yihzqgrd
X-Received: by 2002:a50:e606:: with SMTP id y6mr1540610edm.271.1553155624485;
        Thu, 21 Mar 2019 01:07:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553155624; cv=none;
        d=google.com; s=arc-20160816;
        b=ryglXhwwNuC+OgGf9HXSi4PE/5w8JD040334d/vo/ZVD28bLGbtJpFh3/bOwc5pw6j
         t77kiL99cfk5VM5wvKhcZZ8kLHZFdRmzptLFRNgKZO+NLSp7MVNuThZhRFPcZXzbW3II
         RYh84+wNxhKEpsxYzj/96+CWCnvjwxpUsTLRaw5jHmBY6In4m2vvFX08iL6Lnhf6lOH1
         SYGVlwZQPuEBf5hHUHIl3DTEdjOg2/QzJPyMqLIa2vJLFXtGWvwEhOUhiRcjbYyWJEf7
         Pk3QnX1wdjrkNz7vNow+2EGKL5qsXG4BbgHWvEVi2Inwzs+SC4tdbdciK8RACKAluoHO
         obxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fbGoxH4umKl3Qxa86TBP5T5qqe0ByZ98JBv0PMF8/2s=;
        b=ksemOdTygor6OUOxExGM9QJJFFEEigCruRmX3bwAbhzE8x/xnvVzn651divwh5+xRF
         kJaTCticgqpbjadVKA2FIJURKORU7Bt0xT3ygAKByA0pORCt605Rjiqmd0aaZYJQNYJ+
         3suZFmtLuNiB4BRQhnY2aYNlT46Ajrc4+vvdOX4td+PFCVM+RSYQMemCGJGOGhvQZ5VW
         remK/t2FUD3Pitlg6gtf1fqrnBMO+fiuKFHR4x9xBWI/fvnHkrlUtWzwmaux9Erp+roh
         PcI1gU334rdmUlU+zmXVyMCi+TSMkZd3S76xn+qNSZjbEjWjsPLCk9gCJhOpIx15GPEw
         NdOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e27si1199823edb.395.2019.03.21.01.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 01:07:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AD88AAC58;
	Thu, 21 Mar 2019 08:07:03 +0000 (UTC)
Date: Thu, 21 Mar 2019 09:07:02 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Zi Yan <ziy@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, mike.kravetz@oracle.com,
	osalvador@suse.de, akpm@linux-foundation.org
Subject: Re: [PATCH] mm/isolation: Remove redundant pfn_valid_within() in
 __first_valid_page()
Message-ID: <20190321080702.GG8696@dhcp22.suse.cz>
References: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
 <8AB57711-48C0-4D95-BC5F-26B266DC3AE8@nvidia.com>
 <cda4f247-4eea-decf-3f4a-3dc09364de27@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cda4f247-4eea-decf-3f4a-3dc09364de27@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-03-19 11:03:18, Anshuman Khandual wrote:
> 
> 
> On 03/21/2019 10:31 AM, Zi Yan wrote:
> > On 20 Mar 2019, at 21:13, Anshuman Khandual wrote:
> > 
> >> pfn_valid_within() calls pfn_valid() when CONFIG_HOLES_IN_ZONE making it
> >> redundant for both definitions (w/wo CONFIG_MEMORY_HOTPLUG) of the helper
> >> pfn_to_online_page() which either calls pfn_valid() or pfn_valid_within().
> >> pfn_valid_within() being 1 when !CONFIG_HOLES_IN_ZONE is irrelevant either
> >> way. This does not change functionality.
> >>
> >> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
> > 
> > I would not say this patch fixes the commit 2ce13640b3f4 from 2017,
> > because the pfn_valid_within() in pfn_to_online_page() was introduced by
> > a recent commit b13bc35193d9e last month. :)
> 
> Right, will update the tag with this commit.

The patch is correct but I wouldn't bother to add Fixes tag at all. The
current code is obviously not incorrect. Do you see any actual
performance issue?
-- 
Michal Hocko
SUSE Labs


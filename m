Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E6ADC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:39:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF6A3206A3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:39:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF6A3206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 529B66B000A; Fri, 24 May 2019 06:39:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DAD36B000C; Fri, 24 May 2019 06:39:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F06F6B000D; Fri, 24 May 2019 06:39:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7A6C6B000A
	for <linux-mm@kvack.org>; Fri, 24 May 2019 06:39:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n52so13604164edd.2
        for <linux-mm@kvack.org>; Fri, 24 May 2019 03:39:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=p/rh5WLkvubTA7Yw0tThgkOg6m43SCIMxoCMgADuqZs=;
        b=Zc3rNpR8JBBiOWYG6JsuEsCnbwN0g95m6T0Y1vEj190eEogvgajnPANNQqPzj2DCJs
         fPVroSRlfA/XUeMOc/Qc/KqB2ng+FTGFxfyrftkCWXJBpZm1Cq7EoIy9XUFvXgYS6jYM
         mrJOwbWrJluRHmEsasRv83SxgmYOBnGiOZj8df50if4u03YRfMLn1Zm9gCbCgYvufUbh
         JBcN3xPusADpaphrWTxY+eC6PJb3I29hvoCWGjkbRhTabWOEtlKuM2SJGgab2HtNeUHF
         AhsWI386KKcDKw9hh58DN+qnRSz9NqfHZIXmeh+ORH8uh5gXzhdnBrdq74cNu9p7MFPm
         SJ6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAU+PjLDAvCSuW5+lWetqErbqkWwdJcyy2iWcZt5GUomKhjzUeoY
	iStzE1VQ7PaMoQGld31mDgTdNu4mvtSVu3E9S6Zj2JfW3XE23mqoRRU7vhoKw1expUZOGY9i3SM
	CNCA8ko1O/0vHVZ3TATdkWDweiUjQCI9Qev+/8AWz8iiVw3LLdQ8vaSAbX8dVdi1S9A==
X-Received: by 2002:a17:906:329a:: with SMTP id 26mr27485689ejw.9.1558694367476;
        Fri, 24 May 2019 03:39:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaTQxLkNaIMIP6ihYM4b1wxhI+cno6JRXVDEhvG2/EIPAskhvhL1fohDoQbBSS7vig9mTG
X-Received: by 2002:a17:906:329a:: with SMTP id 26mr27485636ejw.9.1558694366569;
        Fri, 24 May 2019 03:39:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558694366; cv=none;
        d=google.com; s=arc-20160816;
        b=BFzuNEVbX8uX3NTJWCrq1NqGPVwSgwOnZ/zZtCBZF9OJdKDCt/RrXuhkh3NR1jlc5X
         YxgtacnrQcVapp8ivLK9uNXrBwlR5SORr6m9ZL4KshvKUb4+XnZlR0gwb2OiLA8UmTZt
         oy5t4+Oa5rDAkogDWIbWzKvXI6z9SmrwNaj2pgu+1Vh6gEPj5D7oTaHaORHF7p7mSMQV
         nQJy6Qh6D6k8yCosYpnrnJCnCc+6D3hbbd7rA9HII09HPX225b9JGr3terfv+ISeFjuV
         zcYHbkSqbwKttRKV7Pab7UxvxKY1OHjr7z/WhzN4AB4XrmqO3N6/eafzJtCpo2P8FiOd
         t4wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=p/rh5WLkvubTA7Yw0tThgkOg6m43SCIMxoCMgADuqZs=;
        b=qLfW/o7EjhKhVY3XhbsluLJrR9VMazxCf3CBPstjcPUspIuC0ScsbC01xsA3GGLD4e
         ql90RdHoxTiof+73qaMRcskhsLoSxe3vkUx+z/XGyYyx/uP5FeseESIUiAz6QLGti20j
         saFB8pf46rVzkz5tj/Im0UdI2Vvb5/898z8thGZTBLICrhqlu5IRFDTOTHKzCaldYQen
         Ow4+wNsOcdNJZuhdN/5/XxoVZbdeB0Ibbe/03ZtmObXt52GntIxvsHnyxKIvgpE223L7
         43mZCmr8ORqtOpelJBRsottBRePyUWFSLfXrI0IkL7wLy+MggwO4+smSpYj9o4LB6xb9
         dQfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id k32si919490eda.157.2019.05.24.03.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 03:39:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) client-ip=81.17.249.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 4350A981E0
	for <linux-mm@kvack.org>; Fri, 24 May 2019 10:39:26 +0000 (UTC)
Received: (qmail 32417 invoked from network); 24 May 2019 10:39:26 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 24 May 2019 10:39:26 -0000
Date: Fri, 24 May 2019 11:39:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Suzuki K Poulose <suzuki.poulose@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com,
	cai@lca.pw, linux-kernel@vger.kernel.org, marc.zyngier@arm.com,
	kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org
Subject: Re: mm/compaction: BUG: NULL pointer dereference
Message-ID: <20190524103924.GN18914@techsingularity.net>
References: <1558689619-16891-1-git-send-email-suzuki.poulose@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1558689619-16891-1-git-send-email-suzuki.poulose@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 10:20:19AM +0100, Suzuki K Poulose wrote:
> Hi,
> 
> We are hitting NULL pointer dereferences while running stress tests with KVM.
> See splat [0]. The test is to spawn 100 VMs all doing standard debian
> installation (Thanks to Marc's automated scripts, available here [1] ).
> The problem has been reproduced with a better rate of success from 5.1-rc6
> onwards.
> 
> The issue is only reproducible with swapping enabled and the entire
> memory is used up, when swapping heavily. Also this issue is only reproducible
> on only one server with 128GB, which has the following memory layout:
> 
> [32GB@4GB, hole , 96GB@544GB]
> 
> Here is my non-expert analysis of the issue so far.
> 
> Under extreme memory pressure, the kswapd could trigger reset_isolation_suitable()
> to figure out the cached values for migrate/free pfn for a zone, by scanning through
> the entire zone. On our server it does so in the range of [ 0x10_0000, 0xa00_0000 ],
> with the following area of holes : [ 0x20_0000, 0x880_0000 ].
> In the failing case, we end up setting the cached migrate pfn as : 0x508_0000, which
> is right in the center of the zone pfn range. i.e ( 0x10_0000 + 0xa00_0000 ) / 2,
> with reset_migrate = 0x88_4e00, reset_free = 0x10_0000.
> 
> Now these cached values are used by the fast_isolate_freepages() to find a pfn. However,
> since we cant find anything during the search we fall back to using the page belonging
> to the min_pfn (which is the migrate_pfn), without proper checks to see if that is valid
> PFN or not. This is then passed on to fast_isolate_around() which tries to do :
> set_pageblock_skip(page) on the page which blows up due to an NULL mem_section pointer.
> 
> The following patch seems to fix the issue for me, but I am not quite convinced that
> it is the right fix. Thoughts ?
> 

I think the patch is valid and the alternatives would be unnecessarily
complicated. During a normal scan for free pages to isolate, there
is a check for pageblock_pfn_to_page() which uses a pfn_valid check
for non-contiguous zones in __pageblock_pfn_to_page. Now, while the
non-contiguous check could be made in the area you highlight, it would be a
relatively small optimisation that would be unmeasurable overall. However,
it is definitely the case that if the PFN you highlight is invalid that
badness happens. If you want to express this as a signed-off patch with
an adjusted changelog then I'd be happy to add

Reviewed-by: Mel Gorman <mgorman@techsingularity.net>

If you are not comfortable with rewriting the changelog and formatting
it as a patch then I can do it on your behalf and preserve your
Signed-off-by. Just let me know.

Thanks for researching this, I think it also applies to other people but
had not found the time to track it down.

-- 
Mel Gorman
SUSE Labs


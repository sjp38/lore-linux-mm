Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65CBBC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:45:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08E1C21019
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:45:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08E1C21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A45E6B026B; Mon, 13 May 2019 17:45:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92EBC6B026C; Mon, 13 May 2019 17:45:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 844446B026D; Mon, 13 May 2019 17:45:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4FAF66B026B
	for <linux-mm@kvack.org>; Mon, 13 May 2019 17:45:07 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e21so19920396edr.18
        for <linux-mm@kvack.org>; Mon, 13 May 2019 14:45:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2uXiQPla5ltb3lP2kqjtPrNHFe9vETyultN6QJpJDEM=;
        b=bvNfq4MQbuh7WcCoQBXJHEWvFVW5/ew6I1benL9rB5Y0jZ9q5+ZDhVPEYub9bOen9C
         cnOjjiGYmgg09/Xa94b1vx4RrHUTkzS/kI18XEiyZ/SZ5r3FqsBOCNsK96Lhz5uh7c4m
         VaXuw1gXqGONtFr+DyavJLcyWMZuk7Hp2ozmUNFSrURaH1nn2WQzzm2wg11wb7hU0bH9
         HhKP2zkKUK9NjGN6sQ/iiuDN7KoFyoV2yid0sOQwrnhgB6AFLo9t1bGwQLLXMNRdFt5E
         unLTLVe4f+2e15g88kq0ymg8+HMI1Yqu684gRTpWHauNkUQNlT5EJE37zEl056MpVV0J
         vboQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXRjUMgksLaz2UhNabmm1j49VckF6ArQYuDrrPAti24OqBRfXGh
	cSvD+bUyv6KG7xDZnNNChh6YkJLJ2dlEgSAgaiHFRi/EgC4/qAzM4FRvRRLAB4nEWd7u5kwQxj8
	TPXDd6gkDAV7Cg2ES446/fxfzg99ZUbCZT1Ve2T/hZkIw6ZkzHGiQKdG0BC0JB6E=
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr5672133ejb.5.1557783906845;
        Mon, 13 May 2019 14:45:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwotkYewMZ1D6KpU1n5kH2f0EYXi4wwnyNwiIb1dzxx4/OEpZw26je/697gS2Bu4wpvR/L9
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr5672066ejb.5.1557783905632;
        Mon, 13 May 2019 14:45:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557783905; cv=none;
        d=google.com; s=arc-20160816;
        b=aGT1tYsU5QFuA8jmjJVBbo++NK9XHphL5CWs2Ivff1DrZZ+qdy30vSJxqlBP1qf/ah
         FFaVFV90wmaammeUVGqH08gLpiVcZc0IX8yAD8JYsck6Y3GNUqTMh1HqGffGaA4WYgmf
         DKzl0UHUS1lOeI+fPpIxJsmgpYpNFTI8j+wmdU8TCPhNrzOIevyyfwtiQl8pCft8QaSw
         yHFKzb0GYZSmdyPYTW+d9al5AgGJLYIhw6dP/BjJEBTX7UPAkv3nfgDh6a+5XhLDs8wA
         vrnkRrhEQvxF647Ang4aJRRwVWc1Rf+64Cr0ujM3ZZ7TjVy6gq0dWsT+dx2FFTlruNoC
         VADw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2uXiQPla5ltb3lP2kqjtPrNHFe9vETyultN6QJpJDEM=;
        b=ELSoOQSVonU5sQaVI9cpgK7OH7no7i9yX4KPSKzLI8GY1G+9OpyBKY4CM10i0WIRfQ
         97/VEFK8hskrOEUJGQdP8vZN1tWPGUHSg5gxvtfsZNqCU23laY7X4HblbrkUMzLp5FNF
         p/K18OhUgO4EThVpifuiXjMa5os12+c54P9rOpc1e8N5wL2eQm7pEmKmK5JLDBsRrzXy
         8gmPbTYNHpD3ymYRvL2mIdOmiWduYCMdtKBO/ytAAxm8d0aHJRmjkVUKEkJMxvR+ax90
         U3bgCLhikzVsMFI8dZHyAZ8Prex295uTNsiv8J/fShd2huxL79CKSLCJonDeCbj7J6tz
         iJrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v28si403475edc.12.2019.05.13.14.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 14:45:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A9351AC94;
	Mon, 13 May 2019 21:45:04 +0000 (UTC)
Date: Mon, 13 May 2019 23:45:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com, hannes@cmpxchg.org, mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com, hughd@google.com,
	shakeelb@google.com, william.kucharski@oracle.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: vmscan: correct nr_reclaimed for THP
Message-ID: <20190513214503.GB25356@dhcp22.suse.cz>
References: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513080929.GC24036@dhcp22.suse.cz>
 <c3c26c7a-748c-6090-67f4-3014bedea2e6@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c3c26c7a-748c-6090-67f4-3014bedea2e6@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 13-05-19 14:09:59, Yang Shi wrote:
[...]
> I think we can just account 512 base pages for nr_scanned for
> isolate_lru_pages() to make the counters sane since PGSCAN_KSWAPD/DIRECT
> just use it.
> 
> And, sc->nr_scanned should be accounted as 512 base pages too otherwise we
> may have nr_scanned < nr_to_reclaim all the time to result in false-negative
> for priority raise and something else wrong (e.g. wrong vmpressure).

Be careful. nr_scanned is used as a pressure indicator to slab shrinking
AFAIR. Maybe this is ok but it really begs for much more explaining
than "it should be fine". This should have happened when THP swap out
was implemented...

-- 
Michal Hocko
SUSE Labs


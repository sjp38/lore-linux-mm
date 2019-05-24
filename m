Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C209C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:56:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B8F320856
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:56:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B8F320856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D80BF6B0005; Fri, 24 May 2019 06:56:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D30F36B0007; Fri, 24 May 2019 06:56:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C47B46B000A; Fri, 24 May 2019 06:56:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7858E6B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 06:56:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so13630684edm.7
        for <linux-mm@kvack.org>; Fri, 24 May 2019 03:56:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=mX1G/NnWrmJ4POVjl86oaxgnsC1UhHQ9fr8JRBsPQ+4=;
        b=Qter2ZNXttp/xGeSpxdbPpE2h7935lbvq+F+XB7YYh5/W3oMuuZ8SE3gctqF44kBPD
         iM2POS6voiXwGK+7NoSmzw5Y98GxzhjjdLECcxGAoS9G35PLcQQJ+ip0Ojc5R+0bkjFI
         PPvfBVoxaDO+nk51ikALerKTL8d8ryPbJgEojdJnQIslEiNO9ZojojsOScrSLI4qcwb9
         dCbSPAw3iwmqsDo5kV/TpxUA8WMhcGGqXizzDZrfiAlJLoU9YSSUOCA/H5Dl+6RxZfRc
         Ziee1bKK+JQKtEc2Mm9Ad9cMWHt/teiopydZZFe2+LU2/GAsLylB6HNSpQnmmeCPr+Xd
         Fofg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUxpoR1HXkdpLJIp/J1w9m0JKbO3HkO/554et+Fznembk8nq2EX
	oykG+e0fsB05/EFUxQXMGHWFcdTzQTS/JJtM/Krn7PWFdkmCg14sD9CmTb+2r+xWFHgNHdMW5m1
	OdzjSt0sLxqlkZRoApQtk9y+UcXzJX4ySg/MKsfCaCG6ztmUUHnB8ioPfscM1pIjP4g==
X-Received: by 2002:a50:ba6e:: with SMTP id 43mr102731227eds.201.1558695372067;
        Fri, 24 May 2019 03:56:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRPSTOKp5FuvuFUY+ZY0EfJiBLgGnqlq2tZU+fB8vOk5buyOAzWGFF8jhxH3k09/c6iSS9
X-Received: by 2002:a50:ba6e:: with SMTP id 43mr102731186eds.201.1558695371380;
        Fri, 24 May 2019 03:56:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558695371; cv=none;
        d=google.com; s=arc-20160816;
        b=ANHYsLnrKS68x1ifMtX1A5I1i6AgVKFKMU53NOlPlvV0j9RUuvb7DVilFGsTXoTbHV
         99wNACe3QjH8JsiE8aTVwNSOh7Q6i3UYmWoPUENqh/ra4k4znY1toL4WFmKdMJDL9fD5
         rtm4T3QZTCzr8piD0K1KexekgsSpi6GfVa5JeLAv+eWC954sLXlGwNentlPduwbu5IvN
         IxQcJ3jzs7ThNEmkd6o2rQJpQx2+v05GH7G48Fwh+zfdIzYQCXIkdhEvbmPHTvnkDgx8
         2ItwwnnoEA5IYjCEjHGJ2YGytjgikjWX/SMT/mrGNu6Q8Nnt+oTVQJszMmpnTayxrQaM
         270Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=mX1G/NnWrmJ4POVjl86oaxgnsC1UhHQ9fr8JRBsPQ+4=;
        b=fBFUWtqLRHWnZoo4Qp9NDDs39vzRM0M8aGICZipcsiqu3s698pKAPLf/d9Uj6hHYHj
         CCDBTSXu0Rf+b6tcLKg5Y1GsKxb6hIiFWqNYSqSErLXHPqMmqJ+STFWSCOKt+rEBGQEb
         d//UkqMI3Ze+88BhZjuTYJtMT01VZJ1v214McR/s8EEH/H1jcE9x/sAy0S3QBcUIBj9R
         EQlhnc8ihrkc/w7PATz10rr/VvQQsYyLwNO73NKWe+0E3CKcqU9osx5hvB6HnwFV6hvu
         WFBG9h/fVKBXERN8yA9CSu8hIcSR9DhJXWpAQ5/ACo9CkVHi6aflfSiKxgLYCrWEUSbq
         lPhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t22si1597224edb.422.2019.05.24.03.56.10
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 03:56:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0EC91374;
	Fri, 24 May 2019 03:56:10 -0700 (PDT)
Received: from [10.162.42.134] (p8cg001049571a15.blr.arm.com [10.162.42.134])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B23593F703;
	Fri, 24 May 2019 03:56:06 -0700 (PDT)
Subject: Re: mm/compaction: BUG: NULL pointer dereference
To: Suzuki K Poulose <suzuki.poulose@arm.com>, linux-mm@kvack.org
Cc: mgorman@techsingularity.net, akpm@linux-foundation.org, mhocko@suse.com,
 cai@lca.pw, linux-kernel@vger.kernel.org, marc.zyngier@arm.com,
 kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org
References: <1558689619-16891-1-git-send-email-suzuki.poulose@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <cfddd75a-b302-5557-05b8-2b328bba27c8@arm.com>
Date: Fri, 24 May 2019 16:26:16 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1558689619-16891-1-git-send-email-suzuki.poulose@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/24/2019 02:50 PM, Suzuki K Poulose wrote:
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
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9febc8c..9e1b9ac 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1399,7 +1399,7 @@ fast_isolate_freepages(struct compact_control *cc)
>  				page = pfn_to_page(highest);
>  				cc->free_pfn = highest;
>  			} else {
> -				if (cc->direct_compaction) {
> +				if (cc->direct_compaction && pfn_valid(min_pfn)) {
>  					page = pfn_to_page(min_pfn);

pfn_to_online_page() here would be better as it does not add pfn_valid() cost on
architectures which does not subscribe to CONFIG_HOLES_IN_ZONE. But regardless if
the compaction is trying to scan pfns in zone holes, then it should be avoided.


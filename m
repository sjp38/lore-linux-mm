Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96144C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 13:15:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D53621734
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 13:15:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D53621734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC2DF6B026B; Wed, 27 Mar 2019 09:15:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E71996B026C; Wed, 27 Mar 2019 09:15:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D60DA6B026D; Wed, 27 Mar 2019 09:15:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86AC26B026B
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 09:15:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w27so6687666edb.13
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:15:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GEtzH18pxflGCh4fsPKnFh81TrQk13EDIy90arT8Ntc=;
        b=gG2ATjCOtmrhU7vOd7ztg0ReGVNcrVH3pfM5+21EI991s+R/Q3LBM4VzHvlPEvypyb
         a2dr8AhWoGryGrHOE8CFLaiKQOYQ7r8N177YAynXkXvK3QX7VobLoOWcUPKjNyQV+QeT
         DcTtJv2ZtigWFnfQ83QgxMOoRInBcTJidq0g3uqW1LvPN7pGdNdd300HTXPLE5AUdxYh
         jIpe0DtSF99eKHkp3Z/TuhFjf0OTAj3xXwo1cQaOCXzAiEIHC0IW7g7lRqwQiJskpZ17
         e9S9Heb2FEnKay2u6y7ZnSoHb7wtyG6jZ3T+RunqFnOFL0iLKN8Mb9WRVdAjFUTbOkkU
         KHbA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV1x3+9Gg0d6dYOXdpQhzUIHb8WZBk+s3/CgFgaO22gZzmwL2dc
	QuNhFRRM2t68bLo7M+JMS6uB7OXS4R81t3ftHtLojD5reO8BNgw8b9PxjjXXRawVI/Gj5mke+bc
	TC2Xt2XEhgsFLtvRSBcgatZIRTtROLraRwdM2+kSx/mNFcohagnscMJyD2Eh+u9U=
X-Received: by 2002:a17:906:6ad7:: with SMTP id q23mr19984891ejs.210.1553692509110;
        Wed, 27 Mar 2019 06:15:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBpAi2bS1SU4dsSqDbDbILi4Dqpo2r4XelbHf5RcKJPutuNzvOjAOmBtdgSmGlaKeUX+sc
X-Received: by 2002:a17:906:6ad7:: with SMTP id q23mr19984856ejs.210.1553692508341;
        Wed, 27 Mar 2019 06:15:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553692508; cv=none;
        d=google.com; s=arc-20160816;
        b=nyjJeP4KWRio3TT84TzsqNiKVG3BW03H9B5rosJ0tcIka6laI12J6UZqpgCjjm6Hjf
         miyn0oGnhwUQ0uyCp4M3WdOl1uK7R9Vn9DnxwNegN3nCJab14ftvBID3GSo0Nfay4R/0
         Xo0R39fJjuXn+2ymZ6HXGi+mXOZAadRhFm0N8vYn3dpPOrHsrrh4/vwroihEqNN/mkyJ
         ItUYOHjAqN3VRBbKT3CMR4GDEbKY9sz4YEETKWeF0UMtzmYl50QrJZmCDis+tgOnHjJZ
         t1X22GB4QutSm3Xi3KYeWJCJhXMaU7pCHi1YImozx1ItiedHfuNZAUmLRbXPeV0zq9uK
         s1cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GEtzH18pxflGCh4fsPKnFh81TrQk13EDIy90arT8Ntc=;
        b=d4XJk7DGsWNu3b6zEOSPGUJiTeP4h/tOLDg+M1OaI1x/T+Cw3Uku4yRSB9F+ujbF6X
         b05cb78lZ0qLcON9W6tOmdrC9HbAWnBS+K+JG9iHJmRAcpXJQeQGMZwHwAA5d6l7wpxc
         ulXvABALMkrSTNKKCeLZmXUlDKsatr0wZPjAe7Q8ybd9fv1pNT89jQEvnuM7uj1ImYyE
         ZEfQHiLft6Q9rdd6uY7KJKOT6oYu9SDVQOA/Z27xC+h0hKvdhMC13cnikX1+EM1EiKYn
         nB9HzOOUa73LT2gac/a750P351PnV+lND+Pl8Xit1We8Yv/95hpiq+QuqMtiALDQWYhU
         MTng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y21si3318817edd.139.2019.03.27.06.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 06:15:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7D0A9AFD1;
	Wed, 27 Mar 2019 13:15:07 +0000 (UTC)
Date: Wed, 27 Mar 2019 14:15:06 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org,
	david@redhat.com, vbabka@suse.cz, willy@infradead.org,
	akpm@linux-foundation.org, Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH] mm/page-flags: Check enforce parameter in PF_ONLY_HEAD()
Message-ID: <20190327131506.GI11927@dhcp22.suse.cz>
References: <1553689672-28343-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553689672-28343-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Nick]

On Wed 27-03-19 17:57:52, Anshuman Khandual wrote:
> Just check for enforce parameter in PF_ONLY_HEAD() wrapper before calling
> VM_BUG_ON_PGFLAGS() for tail pages.

Why is this an actual fix? Only TESTPAGEFLAG doesn't enforce the check
but I suspect that Nick just wanted the check to be _always_ performed
as the name suggests. What kind of problem are you trying to solve?

> Fixes: 62906027091f ("mm: add PageWaiters indicating tasks are waiting for a page bit")
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  include/linux/page-flags.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 9f8712a4b1a5..82539e287bc6 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -229,7 +229,7 @@ static inline void page_init_poison(struct page *page, size_t size)
>  #define PF_ANY(page, enforce)	PF_POISONED_CHECK(page)
>  #define PF_HEAD(page, enforce)	PF_POISONED_CHECK(compound_head(page))
>  #define PF_ONLY_HEAD(page, enforce) ({					\
> -		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
> +		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
>  		PF_POISONED_CHECK(page); })
>  #define PF_NO_TAIL(page, enforce) ({					\
>  		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DC39C46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 08:30:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E36BA218A3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 08:29:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E36BA218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CB8A6B0006; Fri,  5 Jul 2019 04:29:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 755218E0003; Fri,  5 Jul 2019 04:29:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61C938E0001; Fri,  5 Jul 2019 04:29:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EEA56B0006
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 04:29:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k15so5203420eda.6
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 01:29:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=truOZNgtMUGFgutf3nq0xVBssoY2U9qGFwatSDNHV1w=;
        b=pll6qQxpT+226/kFHBvQn4ZRp0PWEQKYTIdYfwUBzZLa70Zg7t/ZcLagEG8gAW+GUi
         m5LqezaMO7f3bkbMl+rjvHv++4CArIZ6MDtwqzgPndgzg5QceS6+Qiih0/aHwsMTiiS0
         kajOfJcnwAGzjl1MYzPeQfPkRFAdhxu0mU2XikMbxaY7Kfzmd1u/sfFmPBtfJDtXfAZE
         nAlrkyOp5xjSnGvpsPdwSfDD5TBU/hQ0pgJH7HS+sSGrUo9LP8fFwBjUpLB5H1Q0zf4Z
         sN0heT9d/3mabn8D9huhxx8ps5JbLA6nheoUOO2QJXiwHKUUtIg4dp8U93/MwwSTuXjK
         j7Pw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWH/a6MJiN+kcPND19f1cvxWn8zhz2gc7OGVpY+7ral6NJHZQll
	gwB0ke1/7FPH7GsZR2DANprVHyp0BBO2Dohq8Vhjsm5RKkY3xYBaeB0ZTlFnwD8C5eE3ww7B8lE
	aNf0xjMC+RshS8QzYs3dMltWv/o3t1JQicCzSmo6fpwO5jUD47A7zrK6qmwDOp41N+Q==
X-Received: by 2002:a17:907:110b:: with SMTP id qu11mr2349840ejb.18.1562315398557;
        Fri, 05 Jul 2019 01:29:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrbVv7+ws6Z/8M0pEc8SqH4nWUC/Nnvrz1YtLdCBgEF5oFLXsMxhBDfKDQc2eyTSOCoiE4
X-Received: by 2002:a17:907:110b:: with SMTP id qu11mr2349798ejb.18.1562315397721;
        Fri, 05 Jul 2019 01:29:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562315397; cv=none;
        d=google.com; s=arc-20160816;
        b=ORmrigTWW9K44a0VcFneM6mRR4sO1kdja30fGA2IJXBar+zeIdHJPLDJAuOQYGlkMF
         Euh4gKfbnH0NT+k80kqjwEmkE8Cit+6O9eHTtNRMzACb5HQefoWTsD+CFA52Skb2mqRt
         s0tApRHa+GG95NY4AkLn54+6C8Gqbr6Kf1vw00mpQIZk05UEzoFTn8URlSfQjUIQib/y
         PtP5hPVsyFEMRX0y/qEuoSBEYTZ5K7LLBrUePF1d17Joci2Ym6pdeP7SuL83Tx+7S73p
         HNPdidjzZ0WFFZLdFlde/Tx7JUymYHVpooIMG2uI8UnTPHaTC7PRemJSLHYABZ6xF51B
         n4BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=truOZNgtMUGFgutf3nq0xVBssoY2U9qGFwatSDNHV1w=;
        b=RoTiBaohT4D+9vWFZh9NlXGQvtSC3FTdZ0fLFZwmyu/nfzd1y3ODZBV9BImv1K9PVX
         weVSFz/nE+8React2VSRAqSSTYT/PN/VL6IYv8vxsi4AohLgg60PU3/XFwUWtLyKyVFH
         BFBKeYOwmTruB80liSOG/b/wRsfeyirVpgo8gKnLcXj3MsmquvqOjJabJNqK2n0hCtDQ
         Dpsihc9MgafijwKUZJ+S3pL5FD875KGS4fify7KhVf/wA5KcQaw08wzIvOAlMuH8vK5P
         RrkdMfGFhDtRryI2tAASQfR302OtLvHiQ0vSMNs/aZoEd8m/xMLMVvIzX0lJrHbI2phs
         puew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id q4si6585072edg.35.2019.07.05.01.29.57
        for <linux-mm@kvack.org>;
        Fri, 05 Jul 2019 01:29:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BA26C2B;
	Fri,  5 Jul 2019 01:29:56 -0700 (PDT)
Received: from [10.162.41.127] (p8cg001049571a15.blr.arm.com [10.162.41.127])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B2C713F246;
	Fri,  5 Jul 2019 01:29:54 -0700 (PDT)
Subject: Re: [PATCH] mm/isolate: Drop pre-validating migrate type in
 undo_isolate_page_range()
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Qian Cai
 <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
References: <1562307161-30554-1-git-send-email-anshuman.khandual@arm.com>
 <20190705075857.GA28725@linux>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ae5e183b-c5f7-2a37-2c14-110102ec37ed@arm.com>
Date: Fri, 5 Jul 2019 14:00:22 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190705075857.GA28725@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/05/2019 01:29 PM, Oscar Salvador wrote:
> On Fri, Jul 05, 2019 at 11:42:41AM +0530, Anshuman Khandual wrote:
>> unset_migratetype_isolate() already validates under zone lock that a given
>> page has already been isolated as MIGRATE_ISOLATE. There is no need for
>> another check before. Hence just drop this redundant validation.
>>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Qian Cai <cai@lca.pw>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> Is there any particular reason to do this migratetype pre-check without zone
>> lock before calling unsert_migrate_isolate() ? If not this should be removed.
> 
> I have seen this kinda behavior-checks all over the kernel.
> I guess that one of the main goals is to avoid lock contention, so we check
> if the page has the right migratetype, and then we check it again under the lock
> to see whether that has changed.

So the worst case when it becomes redundant might not affect the performance much ?

> 
> e.g: simultaneous calls to undo_isolate_page_range

Right.

> 
> But I am not sure if the motivation behind was something else, as the changelog
> that added this code was quite modest.

Agreed.

> 
> Anyway, how did you come across with this?
> Do things get speed up without this check? Or what was the motivation to remove it?

Detected this during a code audit. I figured it can help save some cycles. The other
call site start_isolate_page_range() does not check migrate type because the page
block is guaranteed to be MIGRATE_ISOLATE ? I am not sure if a non-lock check first
in this case is actually improving performance. In which case should we just leave
the check as is ?


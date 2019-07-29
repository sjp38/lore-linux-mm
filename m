Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 553ABC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 03:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 233FB2070D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 03:05:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 233FB2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9E908E0005; Sun, 28 Jul 2019 23:05:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4ED58E0002; Sun, 28 Jul 2019 23:05:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B65598E0005; Sun, 28 Jul 2019 23:05:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F17C8E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 23:05:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h27so37499455pfq.17
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 20:05:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=8vHB8k0HqNq5ttKesHLBUTMbIdDB+jh8xUd4U4t5NEg=;
        b=qgglXXWw2uunjbXG1vR43qOtaFmtzkK/2n/21mO7hjpVLZpD/psfkvdkzSNSGOwlCu
         iUkR0Xf8J+LIoCiaFlUB1orHK665s8EuorVCe0BWg0XpWI2OECrYr/ZY6vHezqNpL89p
         7NRrHiVsBoyVgKLeRGTnbbrhQYzEozK6SHTEFgGNdGPJcpuAJaewGZXmqKZhs0WRIKbh
         n6/YldSzeqHfDxUi9oG82Pwly8pLbJzbsZFqsnyt4heBf+7e5URS/xnh+dvq5QCqFgGT
         jBWi4e+5SNtVFpy19Ukrd9auewyBWzlp88F/6kDQCUhwL34u/bfbh9bGXHEjPZBAsr4k
         rohA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVfrrWSCm0VLtopNm8PfNSfqXAo7QIfyL9erg2jCMy7aYyWecNJ
	+yUDWkqBRAOjHKtVoxwchJ9VDQbZrLN7BUIphBFOlF24NAXYuKjMzMugE8GktSb7sqOheuEcyry
	uoTrE+qLhTQaJ37l3YWM8R3d6Jqxnl3YnJPEXgGlUimQwWBYhHOI4GlnKs4Q7e8Cgag==
X-Received: by 2002:a63:520f:: with SMTP id g15mr97901729pgb.28.1564369504930;
        Sun, 28 Jul 2019 20:05:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdI/ojNkypPTivmnvCaRjguqO0IInaIw78JgU92EuCK7ct0ITSSICjS8wNDMBCxJzKj3vZ
X-Received: by 2002:a63:520f:: with SMTP id g15mr97901678pgb.28.1564369504065;
        Sun, 28 Jul 2019 20:05:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564369504; cv=none;
        d=google.com; s=arc-20160816;
        b=x9iNhZR7loCjhvrc9GDCYxTTgPZiDAFHqUHySfLPuxwI5Y7JQACR1U/+HnmOITe8Ps
         /h9H0Hs2fYfoTNGaH7d4KfdaAgpJaRAF/LGKsQ/JmLMbL+QvdvKry7rHRhwef6nQO2XV
         +m9EFHK6wm2GCZY7+mis4aNREPFaeGJkmgqv8+Pr7MEsbE268uv+BR0LtTjbuHJto4I4
         HumzOw03/276b9/iFPZLsFrhGHMvDgCpTuk7PvsAEmGh/AELvMqeB1pHYQzuVtOwWuft
         M7uYRPGNYCGDpht1fP7t/Sk0m8+hp1IEVJm0YZ3pyQ9M/91MpxiEugLSN3vrLtbAp+B9
         ipug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=8vHB8k0HqNq5ttKesHLBUTMbIdDB+jh8xUd4U4t5NEg=;
        b=ti9qtQc7PmwNXJ2VGl3w1CDo7K5tDuq3zpqBnavNXHshP/9E8a80C7O+aRe2rKrGhH
         9bz/zSYplWdJHRusSGXtAdXQwzMSXt7d0ulru5rTs2X5O9DlNMut2GCJrOcwVqANIb+u
         52HAF46780s3TmuRXxqvbOY8s6LAxLEOOmShDJOhkqs/2fYMXbJbvap+7bCC/4ytKV7f
         gy0+0PtFBUm6b4eJG3A3ge9MESpsfhgo1aE0VNsSaQo47WIbhYijWS+nDr9+syP0G2NM
         MH+3YhUX3/mEOu1Tmp1y7lM9qT8PvocvlQGy8d40pX+Zx3BsxRcjiYxtC9FRFkNTmgzr
         l4ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 4si27824563pfo.266.2019.07.28.20.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 20:05:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jul 2019 20:05:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,321,1559545200"; 
   d="scan'208";a="173741429"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by orsmga003.jf.intel.com with ESMTP; 28 Jul 2019 20:04:59 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>,  Ingo Molnar <mingo@kernel.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Rik van Riel <riel@redhat.com>,  Mel Gorman <mgorman@suse.de>,  <jhladky@redhat.com>,  <lvenanci@redhat.com>,  Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] autonuma: Fix scan period updating
References: <20190725080124.494-1-ying.huang@intel.com>
	<20190725173516.GA16399@linux.vnet.ibm.com>
	<87y30l5jdo.fsf@yhuang-dev.intel.com>
	<20190726092021.GA5273@linux.vnet.ibm.com>
Date: Mon, 29 Jul 2019 11:04:58 +0800
In-Reply-To: <20190726092021.GA5273@linux.vnet.ibm.com> (Srikar Dronamraju's
	message of "Fri, 26 Jul 2019 14:50:21 +0530")
Message-ID: <87ef295yn9.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:

> * Huang, Ying <ying.huang@intel.com> [2019-07-26 15:45:39]:
>
>> Hi, Srikar,
>> 
>> >
>> > More Remote + Private page Accesses:
>> > Most likely the Private accesses are going to be local accesses.
>> >
>> > In the unlikely event of the private accesses not being local, we should
>> > scan faster so that the memory and task consolidates.
>> >
>> > More Remote + Shared page Accesses: This means the workload has not
>> > consolidated and needs to scan faster. So we need to scan faster.
>> 
>> This sounds reasonable.  But
>> 
>> lr_ratio < NUMA_PERIOD_THRESHOLD
>> 
>> doesn't indicate More Remote.  If Local = Remote, it is also true.  If
>
> less lr_ratio means more remote.
>
>> there are also more Shared, we should slow down the scanning.  So, the
>
> Why should we slowing down if there are more remote shared accesses?
>
>> logic could be
>> 
>> if (lr_ratio >= NUMA_PERIOD_THRESHOLD)
>>     slow down scanning
>> else if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
>>     if (NUMA_PERIOD_SLOTS - lr_ratio >= NUMA_PERIOD_THRESHOLD)
>>         speed up scanning

Thought about this again.  For example, a multi-threads workload runs on
a 4-sockets machine, and most memory accesses are shared.  The optimal
situation will be pseudo-interleaving, that is, spreading memory
accesses evenly among 4 NUMA nodes.  Where "share" >> "private", and
"remote" > "local".  And we should slow down scanning to reduce the
overhead.

What do you think about this?

Best Regards,
Huang, Ying

>>     else
>>         slow down scanning
>> } else
>>    speed up scanning
>> 
>> This follows your idea better?
>> 
>> Best Regards,
>> Huang, Ying


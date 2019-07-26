Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAA63C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 03:48:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FF9C21951
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 03:48:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FF9C21951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1AEB6B0003; Thu, 25 Jul 2019 23:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA4806B0005; Thu, 25 Jul 2019 23:48:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B45038E0002; Thu, 25 Jul 2019 23:48:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1736B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 23:48:03 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id k9so27570207pls.13
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:48:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=tPeJjiluU9mSY396p6Lmy2uk/2AVVsZAMf3HKQjDyiU=;
        b=eCZS6NzThN+hEuKfHsr0KHHvkS8vkHhAYisWnbF8caOkKT/h57/MAk3bCr60V0mQmO
         r5CbgMXFz+47VhyVtt9ehv6mIMNqfDPkXfHX/amckQitLzZ3Sus5xKGAApcEq1CSEnFC
         rhe4yE+WB9/kljlsMw5GiG/hJghuhE0X0fXoQYylQ84rTzfX9Xc3E+ymhExUxAIC/P/l
         2K631JcoEgHcTyWkasLsd5MH0Kq2roPdhyZh6PODBtL/tRtfU4pu5JYsMvUOSdYjEOaB
         3crDqS1Jgqx/HBunZLoDHZTsq0SrKbTE+4zF8zcF1eueerDH15YMJLKyKa3udY/uxWpZ
         zTWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXV0OUNbsxgsxonkvkv4cE8UOD5vfAFXI/e7ERSSZrQCY+G0FX7
	SjhVFCn/bio+o88QUBymjHJZJqr0fJJPtihUT6Xa2pFR/p171bMd2n3bAjPJdBdHwrwpiMOsvLc
	wWnEGacUrDJM5BD1sZoU5U/dpnQpaQYyoQZ2OtAxPqWGslr4YAbzLSuEN/Bx1a7s7cA==
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr97155001pje.9.1564112883136;
        Thu, 25 Jul 2019 20:48:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwJA4hS4WGPq/u+EHXCX/Mx2F3e1ESQJA1s+X5ZQNVsEPlkCgu+4bCI3Hj3+aSAipYi+Fa
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr97154961pje.9.1564112882332;
        Thu, 25 Jul 2019 20:48:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564112882; cv=none;
        d=google.com; s=arc-20160816;
        b=Unoyrfr+t2fyclKNk6q8Ijqzs0P7J5Uta+Y5F8399kX4IAup7WSrC0b00ap1N4xgwM
         YaS0qmJA2H6Cctpj+cKyeixPZ6yphOjb+Wqjq9diStD1VhL8SjgTorALrbqafydLhIcN
         v/1nB+DLFTlBuef+fCYhVeMjTnTkuQK4muyXmHgPxsMerv72cxR9r9c9fmmnH8V/6P3L
         KIJA3c0MrJ/b4cMO+DkMC2bwNT8oKBGC7g0Pt69Yxk/ljyRCfXu3S2NQcfHQHlRcDF9y
         p0BPVkzbeeDaqKG6pxtvtn9He5VDFk5KTGJXiqlbAh/LS4DPgouYsU6RGxGHMpRhGh2W
         c7og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=tPeJjiluU9mSY396p6Lmy2uk/2AVVsZAMf3HKQjDyiU=;
        b=gc/Pr0G4lPjTpygh7VeaCwbHQqXhINOnCSb8lnbL177ZoT9jsh5eSsql9Kjv6BjHbn
         cGc6LVtXgR8GIJibzxXNrKmB5qTUcUlcZxQwcl/7oLI8FlLPe2+Hn9zm0FFP4wSLNBlo
         jeSCumwGZzRmNVhKOspwOrg0PpJL2Z4Ok+VrfpEhY9fiX8zgC7btoO8ZNWC+wFgYvgiB
         5J7B+1FsyreaWpaRD8VfJMVXUia/aQqr4DG09xcZEjY6QN9OkyZsuKFw4jWliTAULe7z
         JW1HqpgoYJxMxRsriuksIc8EIbkZruOrmhZ3wFWRb1pE/mRRUimFWaLib76D+yCndvZW
         Mf3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h16si18293241plr.94.2019.07.25.20.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 20:48:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav103.sakura.ne.jp (fsav103.sakura.ne.jp [27.133.134.230])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x6Q3HSqQ076299;
	Fri, 26 Jul 2019 12:17:28 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav103.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav103.sakura.ne.jp);
 Fri, 26 Jul 2019 12:17:28 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav103.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x6Q3HRtg076212
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Fri, 26 Jul 2019 12:17:27 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm, oom: simplify task's refcount handling
To: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>,
        Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
        Andrew Morton <akpm@linux-foundation.org>
References: <1563940476-6162-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190724064110.GC10882@dhcp22.suse.cz>
 <d6aebef5-60f8-a61c-0564-5bb4595e8e2c@i-love.sakura.ne.jp>
 <20190724080726.GA5584@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <542908c5-56a0-2fbc-355d-d41c2653c06d@i-love.sakura.ne.jp>
Date: Fri, 26 Jul 2019 12:17:26 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724080726.GA5584@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/24 17:07, Michal Hocko wrote:
> On Wed 24-07-19 16:37:35, Tetsuo Handa wrote:
>> On 2019/07/24 15:41, Michal Hocko wrote:
> [...]
>>> That being said, I do not think this patch gives any improvement.
>>>
>>
>> This patch avoids RCU during select_bad_process().
> 
> It just shifts where the RCU is taken. Do you have any numbers to show
> that this is an improvement? Basically the only potentially expensive
> thing down the oom_evaluate_task that I can see is the task_lock but I
> am not aware of a single report that this would be a contributor for RCU
> stalls. I can be proven wrong but 
> 

I don't have numbers (nor intent to show numbers). What I said is "we can
do reschedulable things from select_bad_process() if future development
found that it is nice to do, for oom_evaluate_task() is called without RCU".
For now just cond_resched() would be added into select_bad_process() iteration.

>> This patch allows
>> possibility of doing reschedulable things there; e.g. directly reaping
>> only a portion of OOM victim's memory rather than wasting CPU resource
>> by spinning until MMF_OOM_SKIP is set by the OOM reaper.
> 
> We have been through direct oom reaping before and I haven't changed my
> possition there. It is just too tricky to be worth it.
> 

Not limited to direct OOM reaping. Anything that future development would
find.

Anyway, traversing only once (by this patch) allows showing consistent snapshot
of OOM victim candidates. In other words, this patch makes sure that OOM victim
candidates shown by dump_tasks() are what select_bad_process() has evaluated, for
you said that the main purpose of the listing is to double check the list to
understand the OOM victim selection. This patch removes race window of adding
or removing OOM victim candidates.


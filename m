Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E89DC76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:17:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBE2A20880
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:17:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBE2A20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B5526B0005; Thu, 18 Jul 2019 07:17:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 565F08E0001; Thu, 18 Jul 2019 07:17:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42D486B000A; Thu, 18 Jul 2019 07:17:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1796B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:17:51 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q11so13732439pll.22
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:17:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=GJwqUhdtZXTugt+DwgCaHA70ff4tj7hQabNdBLmjNvA=;
        b=IVX5nszfJSmlHG3iCNDf21purC5yxJ7NHQbW1IkRYsL1Hm8u79Z8xaiRSQQvsWbISm
         dcs9is2KLlRt4WqgybvmWDOz680DAWWeU90SjWgHRYYhlOLcM1TuRs/hhbIxp88oC8px
         mHhKTztDX4MTDKwoLhudAQ/0OG1PJ85E1GglbBL2XPMf7UbCgVwhnA8beijcdCHVsifu
         m1xCPSieOfYWQ81shVfE30xPcyKemJb1M0cmk3+cPq2I7bxtOnCRwqU3xUyQ47JqnHWO
         TIidX1RoXCR02zFb4Bt/5DBYivnkghMbZT3gYYZfttWKXy2iSJ1z2F/cEWmld4b0oVPM
         EDRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUZvJGMamBMSRnspb3g8nl+I9O9K3b0Ds73ujlMnbtn6IsRX2Rp
	w4ZE6kKMfMVdbCsAqBOIA0yxjkXZRydUR/9jwPBa5Q+XwWCU+vZ6kwrXKIYRUYBLYpnTBgnaGbM
	v0fbhXi1NfCwu4IQhOTdQfef+fAw6AhYb6yzNwzp6NKFK3r6eQP75+fInvP4J/ZYhAQ==
X-Received: by 2002:a63:5a0a:: with SMTP id o10mr47937477pgb.282.1563448670657;
        Thu, 18 Jul 2019 04:17:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBvME0NRD9tfNukMVARB2zhZs4c5QVAm8cvNCoKpaXrnI7Yu8KWQYAZZeju42Mi1S95s4w
X-Received: by 2002:a63:5a0a:: with SMTP id o10mr47937391pgb.282.1563448669618;
        Thu, 18 Jul 2019 04:17:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563448669; cv=none;
        d=google.com; s=arc-20160816;
        b=NLAWnIPDSLlQIhLB+3ZWbaQgJbpD5qlyEoXq8DhOpEtNbnXpp7MxDAH+mLM8Jq0a3y
         oBo7hxf9zzDuf5BMpQyconX4D3nJDh0seCMn/vlACTSuPAUjRhMCH2GfNL5P4ja6nTk0
         fbAK2iEfaZofNmMoBI1K0KcHqIrtpJg3PiW08yQisLyAgOVnZwRa0FxSEtozB6fm2gDi
         c+Ryi40JY/ytaXPf/cMzEDzdYBzyXeNeNL2zKUeP19IEWIW0zr3x6hMoG4utrTnKoxGX
         xYP8Kt8l/E/6D7vM2Erl5OV7McsY3Dg7XSKS9ygcSSX9c4PN3pwXmswVQPeTTE7datG8
         xOXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=GJwqUhdtZXTugt+DwgCaHA70ff4tj7hQabNdBLmjNvA=;
        b=UOxNQt+kSC5YaAUobUhGuh3uk/kgDtMjZWKRvzJRuI3ukkHgmFjTniOOSEFyfxGQyu
         I3nYxBG6DSwkcWz9227VDpwyyAo1OqzAEmRj9N5YpvF75i4waik95fLVclJzE3LedOoA
         ES5ewfY+1/183W+XM3lEapkpLAsvT4gRrxdMmySiD3PWThexA+M6h5jVh+FoHlavYk3q
         EbqQDkWjORAjAqdYQoaOWEQih8ySQZLqqnnFk+r7iMSVmaNmQ0xSHO0pQVp3AYlx//ep
         3THDOYfL1kvKFCKVcbVih7gQl1rR+0ND5DLKYQeJ2MxKaQHCSQVWusDu64GQ5nARlRXE
         F+9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r4si28594367pgb.245.2019.07.18.04.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 04:17:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav303.sakura.ne.jp (fsav303.sakura.ne.jp [153.120.85.134])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x6IAMAGg024116;
	Thu, 18 Jul 2019 19:22:10 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav303.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp);
 Thu, 18 Jul 2019 19:22:10 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x6IAM48r023912
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Thu, 18 Jul 2019 19:22:10 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm, oom: avoid printk() iteration under RCU
To: Shakeel Butt <shakeelb@google.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>
References: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <CALvZod7kBpDC+rdz=-FrLn_jVAEdBNSLNEgAzGKeBe9HpJvkpA@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <68706110-199d-a6ec-5b1d-7a433b4cccb9@i-love.sakura.ne.jp>
Date: Thu, 18 Jul 2019 19:22:04 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CALvZod7kBpDC+rdz=-FrLn_jVAEdBNSLNEgAzGKeBe9HpJvkpA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/18 9:31, Shakeel Butt wrote:
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index 8dc1811..cb6696b 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -1246,6 +1246,7 @@ struct task_struct {
>>  #ifdef CONFIG_MMU
>>         struct task_struct              *oom_reaper_list;
>>  #endif
>> +       struct list_head                oom_victim_list;
> 
> Shouldn't there be INIT_LIST_HEAD(&tsk->oom_victim_list) somewhere?

Yes if we need to use list_empty(&tsk->oom_victim_list) test.
This patch does not use such test; tsk->oom_victim_list is initialized
by list_add_tail() inside the OOM killer.

> 
>>  #ifdef CONFIG_VMAP_STACK
>>         struct vm_struct                *stack_vm_area;
>>  #endif


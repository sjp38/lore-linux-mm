Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9744C282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:39:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF15020811
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:39:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF15020811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CD378E00D3; Wed,  6 Feb 2019 11:39:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47CD08E00D1; Wed,  6 Feb 2019 11:39:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 345C28E00D3; Wed,  6 Feb 2019 11:39:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E426D8E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:39:10 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o9so4956240pgv.19
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:39:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yA962mChOKqapk3mW/1PB6O3aZR+1mwjVfR/AePVhn8=;
        b=mGwNOTMf64IFxKQIOg/i0Gl5mkTHogLMy9GjxVH7xFNzqXQr5xQo7+ts80aL0RMnL4
         QxemaYozkJTtzvIaOyo9t1wLdndAXIHRXGixgZIGJFJtKmlz0OcIfUu5/9x7w+0mgZQh
         McreT+5JBFVg1yGLWbi3uXcWOjstPIGwEBaDALBGSNA1ULNzsni94U6c9VQ2EpfYUKVc
         0smxLZ5+kNZDsM3p/j4OPDsc/b6s0DMyDE6yyTBya9zZqFezq40KXmW5gs+5smjTkYef
         2tiw3m3Y+3kriSlMxsLMPZt4OPMzpFwj+G8QVR7MgjxLBGWhkHroWuLu2Px0JmcuOq9k
         ztfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAual12jZ6BpSKbAqOexn7IKYOrlmD+D+bcsLbjbTWyKc4gQazQXC
	qqoXonYRc6vI5/TRWmzWJ5RCbezOFGeta/x85AnYrL+x6yXDpP8w40MDDnLbWw/6cvbDEVdfHSU
	SybIKq+Q32HwHkB3X9EdiGTvcSIqyUSCktaZzXmI3TzGR9FaKrJA0GfK0DgLw9Qb+sQ==
X-Received: by 2002:a17:902:4624:: with SMTP id o33mr11341242pld.289.1549471150574;
        Wed, 06 Feb 2019 08:39:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYnsFRnidGSUA9Lw220tL4lt+NalI75NLkDM880/WvQoqwRM/M0XPe9MbUvgVO4A0jE+TlM
X-Received: by 2002:a17:902:4624:: with SMTP id o33mr11341187pld.289.1549471149816;
        Wed, 06 Feb 2019 08:39:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549471149; cv=none;
        d=google.com; s=arc-20160816;
        b=RAs0zycSK4ZG2kpHSjEez1VLOHOzQQ5tAZAAksIYuLS3fIzvb7NwI9v15JRjI7zp/E
         sczJvjc4jkrpJ6ITJkQxejmZcm9T6fmCJpNA2WVq1wQAKtsWR4Jc+TNok2IPKcgfPYTv
         okpfpQOkGSqWVqwxuy8STiE3z44VrBZwWRV4zGQ+lKX/Fd6jmw8L3SihFEGag6H55C0I
         O9LUEeEIPq2ipPDu/oXS/WD1YrMDVqg7ho4FV/9mv/ntZW/TbfVSRFnryPmbdZ7aIL+S
         x1qjCy0PxzuTGw5f+ev8GLluJDHhpeikWLT9/1WEDz+T6KRU+t3N5p3H5dgGayxH869D
         p9Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yA962mChOKqapk3mW/1PB6O3aZR+1mwjVfR/AePVhn8=;
        b=q4TZsgrRKCQRfFR7CdSP3yyCk9Dn5BjQbHtHOgkH7TaZs7PA7IIe0OF1SMCVut3NGd
         8322qVzpiSjhCrRdn8ixQTVvErzM7znvNxl2CWSwNOarw+7399kRzATml7LImxTKvaMb
         g6WiqBLfyxZFKQ2e3jUyDCH4YL2s4BesBCw+8siuD49DbZpdm7P2KTGMuniposeIqXYr
         KWCvzXd5lZNKEuKk3kw143+FTxsHhA/RRmgb8j4DtRgbmJIU8cO3AfsF3BFrcLbFglX2
         zrAngbeagwZGwSn9X61hgWZEye5kq/cTgTrqEjnCzsKUDmpjfOb+Q8+atpGnGpIvWTgc
         1cPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k22si2565841pll.276.2019.02.06.08.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:39:09 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav106.sakura.ne.jp (fsav106.sakura.ne.jp [27.133.134.233])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x16GcjE2011572;
	Thu, 7 Feb 2019 01:38:45 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav106.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp);
 Thu, 07 Feb 2019 01:38:45 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x16Gciib011569
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Thu, 7 Feb 2019 01:38:45 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: linux-next: tracebacks in workqueue.c/__flush_work()
To: Guenter Roeck <linux@roeck-us.net>
Cc: Rusty Russell <rusty@rustcorp.com.au>,
        Chris Metcalf <chris.d.metcalf@gmail.com>,
        linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>
References: <72e7d782-85f2-b499-8614-9e3498106569@i-love.sakura.ne.jp>
 <87munc306z.fsf@rustcorp.com.au>
 <201902060631.x166V9J8014750@www262.sakura.ne.jp>
 <20190206143625.GA25998@roeck-us.net>
 <e4dd7464-a787-c54f-24f9-9caaeb759cfc@i-love.sakura.ne.jp>
 <20190206162359.GA30699@roeck-us.net>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <d2764efb-5298-2e90-d617-d5cedcac783b@i-love.sakura.ne.jp>
Date: Thu, 7 Feb 2019 01:38:41 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190206162359.GA30699@roeck-us.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/07 1:23, Guenter Roeck wrote:
> On Wed, Feb 06, 2019 at 11:57:45PM +0900, Tetsuo Handa wrote:
>> On 2019/02/06 23:36, Guenter Roeck wrote:
>>> On Wed, Feb 06, 2019 at 03:31:09PM +0900, Tetsuo Handa wrote:
>>>> (Adding linux-arch ML.)
>>>>
>>>> Rusty Russell wrote:
>>>>> Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> writes:
>>>>>> (Adding Chris Metcalf and Rusty Russell.)
>>>>>>
>>>>>> If NR_CPUS == 1 due to CONFIG_SMP=n, for_each_cpu(cpu, &has_work) loop does not
>>>>>> evaluate "struct cpumask has_work" modified by cpumask_set_cpu(cpu, &has_work) at
>>>>>> previous for_each_online_cpu() loop. Guenter Roeck found a problem among three
>>>>>> commits listed below.
>>>>>>
>>>>>>   Commit 5fbc461636c32efd ("mm: make lru_add_drain_all() selective")
>>>>>>   expects that has_work is evaluated by for_each_cpu().
>>>>>>
>>>>>>   Commit 2d3854a37e8b767a ("cpumask: introduce new API, without changing anything")
>>>>>>   assumes that for_each_cpu() does not need to evaluate has_work.
>>>>>>
>>>>>>   Commit 4d43d395fed12463 ("workqueue: Try to catch flush_work() without INIT_WORK().")
>>>>>>   expects that has_work is evaluated by for_each_cpu().
>>>>>>
>>>>>> What should we do? Do we explicitly evaluate has_work if NR_CPUS == 1 ?
>>>>>
>>>>> No, fix the API to be least-surprise.  Fix 2d3854a37e8b767a too.
>>>>>
>>>>> Doing anything else would be horrible, IMHO.
>>>>>
>>>>
>>>> Fixing 2d3854a37e8b767a might involve subtle changes. If we do
>>>>
>>>
>>> Why not fix the macros ?
>>>
>>> #define for_each_cpu(cpu, mask)                 \
>>>         for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)
>>>
>>> does not really make sense since it does not evaluate mask.
>>>
>>> #define for_each_cpu(cpu, mask)                 \
>>>         for ((cpu) = 0; (cpu) < 1 && cpumask_test_cpu((cpu), (mask)); (cpu)++)
>>>
>>> or something similar might do it.
>>
>> Fixing macros is fine, The problem is that "mask" becomes evaluated
>> which might be currently undefined or unassigned if CONFIG_SMP=n.
>> Evaluating "mask" generates expected behavior for lru_add_drain_all()
>> case. But there might be cases where evaluating "mask" generate
>> unexpected behavior/results.
> 
> Interesting notion. I would have assumed that passing a parameter
> to a function or macro implies that this parameter may be used.
> 
> This makes me wonder - what is the point of ", (mask)" in the current
> macros ? It doesn't make sense to me.

I guess it is to avoid "unused argument" warning; but optimization
accepted passing even "undefined argument".

> 
> Anyway, I agree that fixing the macro might result in some failures.
> However, I would argue that those failures would actually be bugs,
> hidden by the buggy macros. But of course that it just my opinion.

Yes, they are bugs which should be fixed. But since suddenly changing
these macros might break something, I suggest temporarily managing at
lru_add_drain_all() side for now, and make sure we have enough period
at linux-next.git for testing changes to these macros.


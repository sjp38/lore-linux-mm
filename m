Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52E5CC31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:49:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09D7E2073F
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:49:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09D7E2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8750B6B0003; Sat, 15 Jun 2019 12:49:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 825B16B0005; Sat, 15 Jun 2019 12:49:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EE388E0001; Sat, 15 Jun 2019 12:49:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 477BA6B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 12:49:11 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id f19so1970039oib.4
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 09:49:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=7v6m5zjani9cKQIGotPTf0MHk6h3+L+CMeKIJNGss4k=;
        b=ffzktnbMLQeQYzGI1DaITelP1jkFZ0XXeTRC90kS+0Ut8cmChzXRNQYq26V6iimSuD
         wxiiW+3agwII1y7yhS2lEDyT+8GX9QF/CTxs3inh8mjBn55PvLs60gpo0YTnwtktM3/l
         mQgeg3DAwm/3zxCQGhTFlBpnWOxB2Gqx2RcB3Ia445re+hwwx2585JcAvQYx2zLLJu+P
         qfUb10nBXd5Sa9Vd/T9q3BOxhtkQ0kA+lAb7m1FJRnytyKFDj+uzgHEGwkDqcYVKfxqs
         Bd/E//jYKzhybImyZjINfQm42S6eR+mdK1CkLSvdm4rm/T14SAKuEz8g6lHaK+tHbYV/
         bwkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAWVg2SKGw9BvG45+2MRzgYB6rqqMIJull8PoboSbDtVhPDB+NGm
	L8o3mzxN1C4i0pjMTZ8goyz4n6lpLDyv1vnRRO6gGwWJSUhnBToDzaWcSIwA2KKnpXzkWThHsvd
	M0dkAmXfp+nl8bGT+enVn9iI1cchYqmXZkfDnA3KBntykr3jLfvuo8ofhmbWe8+wNSQ==
X-Received: by 2002:a9d:5512:: with SMTP id l18mr18158238oth.260.1560617350912;
        Sat, 15 Jun 2019 09:49:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6G95jLKKCixZcVK6qX1q0YtBMhVvoYuA9+2pFibiaNrcre9vjnvaA2+P7ZoSZNUO36JzE
X-Received: by 2002:a9d:5512:: with SMTP id l18mr18158213oth.260.1560617350317;
        Sat, 15 Jun 2019 09:49:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560617350; cv=none;
        d=google.com; s=arc-20160816;
        b=i+spRf/p8vcVisk88rk7lShogIIHkEkcYbEok0/Sq8udeJ2zAJ5pcjhcL6knFAeCm6
         kj56EDE73AEllrPHA8dny51ggl3V+ony9zjUm//df3ZqNWGAhv7dgyjBi6Y03a3V1aag
         LwH/VJ/aHxhjrZIYmkF1vFlUCvKLaERx2HFCXh9euZRiLkgDyLfCcfNrreHQGJxw2toQ
         oDfdyty/dLU83aNiIGXuEQG1E6NjZnuKHmo4LDPdTbX918zmgCOdAX9ms/VjOyzkXO/3
         ypfSVIa9Kc5XyJBkHdy3DluLcViXa00ZQmm1ud8YvpdEsth8atvllH38QZ4W3GlfcgBi
         8jWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=7v6m5zjani9cKQIGotPTf0MHk6h3+L+CMeKIJNGss4k=;
        b=l0CJQlr3a17SAF5ceJaGplx7fMqIyVX4rzpbrV3mkv5HMVHv2MUd5zDKeTCghQOWY1
         IAudr3TF1rqi6YXRQYg6hnHx12I58NJc8Qnd+UlMb6+h63P2kVZdOdKSOooDiPcU90Rc
         8a5nHa6U0nf3JKm2urQ4VmGsyDwZ16W+levnmOunbR/5ATedNa8/gKu0YPvr5uytZHG0
         0ec9wBv9QX4dtDXzG+yzLRemcUCN5g+wtaHtdnR5b9Y8P8AgDD/wF8jh4eY/P67BX8um
         FXZKieKORpXYS49P5ndZa80f1miybd/z0SHxhHIZOXRnxmhT8i4tQYhKqBrRVCauAUAR
         sWfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f14si3757863otl.238.2019.06.15.09.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 09:49:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav106.sakura.ne.jp (fsav106.sakura.ne.jp [27.133.134.233])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5FGmXSn070660;
	Sun, 16 Jun 2019 01:48:33 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav106.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp);
 Sun, 16 Jun 2019 01:48:33 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5FGmXuT070654
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sun, 16 Jun 2019 01:48:33 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: general protection fault in oom_unkillable_task
To: Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
        syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
        yuzhoujian@didichuxing.com
References: <0000000000004143a5058b526503@google.com>
 <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz>
 <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <5bb1fe5d-f0e1-678b-4f64-82c8d5d81f61@i-love.sakura.ne.jp>
Date: Sun, 16 Jun 2019 01:48:31 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/06/16 1:11, Shakeel Butt wrote:
> On Sat, Jun 15, 2019 at 6:50 AM Michal Hocko <mhocko@kernel.org> wrote:
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 5a58778c91d4..43eb479a5dc7 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -161,8 +161,8 @@ static bool oom_unkillable_task(struct task_struct *p,
>>                 return true;
>>
>>         /* When mem_cgroup_out_of_memory() and p is not member of the group */
>> -       if (memcg && !task_in_mem_cgroup(p, memcg))
>> -               return true;
>> +       if (memcg)
>> +               return false;
> 
> This will break the dump_tasks() usage of oom_unkillable_task(). We
> can change dump_tasks() to traverse processes like
> mem_cgroup_scan_tasks() for memcg OOMs.

While dump_tasks() traverses only each thread group, mem_cgroup_scan_tasks()
traverses each thread. To avoid printk()ing all threads in a thread group,
moving that check to

	if (memcg && !task_in_mem_cgroup(p, memcg))
		continue;

in dump_tasks() is better?

> 
>>
>>         /* p may not have freeable memory in nodemask */
>>         if (!has_intersects_mems_allowed(p, nodemask))


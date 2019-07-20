Return-Path: <SRS0=pjJT=VR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D971C76188
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 12:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71F7B2085A
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 12:17:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71F7B2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B98766B0005; Sat, 20 Jul 2019 08:17:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4B426B0006; Sat, 20 Jul 2019 08:17:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A39798E0001; Sat, 20 Jul 2019 08:17:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2D26B0005
	for <linux-mm@kvack.org>; Sat, 20 Jul 2019 08:17:53 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y22so17201115plr.20
        for <linux-mm@kvack.org>; Sat, 20 Jul 2019 05:17:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5/KZFCpo5qsIwMxpKyOMepZVgZTt4aeAZ+y4FTo5pqU=;
        b=IDGMuMx08Odc9CCU+E2oI8NUGi8STownzhJlHa2+t7NxlNxKFO1xtJ7C7WCUu/K2Og
         fFSjQ7mOcIQO14oaq9RBXwFY8mLm4sYhhijAhPgUXAp7WGcvtRvGQXXw4V/DgIdpj2sK
         iYqlRcH9nx5PnE07xiwJzcROPqXnHpEr3lTk3odQINnfMC0Hli8D+RCILSddPCJjhWMx
         I4Xh5NsBYjnY+XUpBBHU+vgMvN5x6oxbNUWKtwqMekndIA0NL5CiGNk1N2c/kvqb3t8V
         aFqK1Rz86ZKxEivKdU49t0ueU4d3U321LNyi2p+8Xdrfarg6HSa0u3uCcmCCOYmDJ4+J
         r2kQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUcw8+W66OuBPXzapcjltchdgmTHBj0wJm9wblDXCdeNizf3v9s
	7fK69UzeQW3VChq3INGhj1QpGimv5NUokxSKLLAFfI5qxgMtyCktBp3K6kFOH+S6dmfmMWbRdmP
	0/6ll/hFMoo+NPCgJ5+Bv40lf0k75FSijdV5uagM0TM3GYpG+J6MgLKYzfOsQ+rHm6Q==
X-Received: by 2002:a63:5a4b:: with SMTP id k11mr414733pgm.143.1563625072815;
        Sat, 20 Jul 2019 05:17:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd+mIJuDqasCr0FmBQWpsarVIfw6MDwkSV+DShoyqEwQrUExvrjDFid+RZnOIZMAfRV2Qu
X-Received: by 2002:a63:5a4b:: with SMTP id k11mr414665pgm.143.1563625071836;
        Sat, 20 Jul 2019 05:17:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563625071; cv=none;
        d=google.com; s=arc-20160816;
        b=c95nkWHY1RpwFNEKx+gqzPDgRTOV3sviDtQ5nDlNC53QqKRmUPNLtWg5Y3x3y9NuJF
         8KcPBK3/KZJg4SeRfCXjUdtT1DAEwXL24SHYq7MWPPHfUaqIOpvuvE5SZ3rjPldKoSHN
         1NdvGFe+huvSsEM6Afw0+yVTAXkplizGrDhfThNUsaI6K8t60E6br1XdGCLawBfWs9c3
         xkGgFqV+8buGvj4WCb/If/0hXSbCO9f7JZUyfhqDz1MTun/GUQhQB7xdWPLiGeBIK2Ue
         upQk1rpAcR+lXvlPfEvrM+NzuYG46dxl3oEfCGhtgxkKgo3a4t1ckD28n+cBVrMBikB3
         gW7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5/KZFCpo5qsIwMxpKyOMepZVgZTt4aeAZ+y4FTo5pqU=;
        b=hwQdNhlRVP4s31uvhjXjF8so0hmaK8xCI6l3+AkiE4gejLQKaDTHSuCX5cMYrXenqB
         9CxCWEVFF2sfmxcMkPBvcyzJmRI/p/jL/aLp3qSFSSM8FBAt8bW9G+bxtZLccH+7B8xF
         mxoeASjkOv8V+EtH5IzLLjiKexsrY32vG2Hm8mPbGZbuoZQ2JXMj74fHY8MjgAGlPyB5
         70hvjKCO58FZqpsmH2Ypr6pbab6Zwjz1hg90FC81q74NUSZjeMoj9mDx486402CCyAex
         LPPgP7pYuhDHEx5nRNbCmT0QKV/PM13XvRtFb6XOqu/8lTySUmYw+6cJFtyDKPRgsR7m
         argg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a7si5610009pfc.54.2019.07.20.05.17.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jul 2019 05:17:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav303.sakura.ne.jp (fsav303.sakura.ne.jp [153.120.85.134])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x6KBTR7g079218;
	Sat, 20 Jul 2019 20:29:27 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav303.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp);
 Sat, 20 Jul 2019 20:29:27 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x6KBTNdY079107
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sat, 20 Jul 2019 20:29:27 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm, oom: avoid printk() iteration under RCU
To: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
        linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
References: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190718083014.GB30461@dhcp22.suse.cz>
 <7478e014-e5ce-504c-34b6-f2f9da952600@i-love.sakura.ne.jp>
 <20190718140224.GC30461@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <4291b98c-a961-5648-34d1-6f9347e65782@i-love.sakura.ne.jp>
Date: Sat, 20 Jul 2019 20:29:23 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190718140224.GC30461@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/18 23:02, Michal Hocko wrote:
> On Thu 18-07-19 22:50:14, Tetsuo Handa wrote:
>> On 2019/07/18 17:30, Michal Hocko wrote:
>>> On Wed 17-07-19 19:55:01, Tetsuo Handa wrote:
>>>> Currently dump_tasks() might call printk() for many thousands times under
>>>> RCU, which might take many minutes for slow consoles.
>>>
>>> Is is even wise to enable dumping tasks on systems with thousands of
>>> tasks and slow consoles? I mean you still have to call printk that is
>>> slow that many times. So why do we actually care? Because of RCU stall
>>> warnings?
>>>
>>
>> That's a stupid question. WE DO CARE.
> 
> -ENOARGUMENT
> 
>> We are making efforts for avoid calling printk() on each thread group (e.g.
>>
>>   commit 0c1b2d783cf34324 ("mm/oom_kill: remove the wrong fatal_signal_pending() check in oom_kill_process()")
> 
> removes fatal_signal_pending rather than focusing on printk

No. Its focus is to suppress printk(), for it fixes fatal_signal_pending() test
introduced by commit 840807a8f40bb25a ("mm/oom_kill.c: suppress unnecessary
"sharing same memory" message").

> 
>>   commit b2b469939e934587 ("proc, oom: do not report alien mms when setting oom_score_adj"))
> 
> removes a printk of a dubious value.

No. Its focus is to remove printk(), for that printk() allows the system to
TASK_UNINTERRUPTIBLE stall for 44 days (even without slow consoles) in addition
to RCU stall for 2 minutes.

> 
>> ) under RCU and this patch is one of them (except that we can't remove
>> printk() for dump_tasks() case).
> 
> No, this one adds a complexity for something that is not clearly a huge
> win or the win is not explained properly.
> 

The win is already explained properly by the past commits. Avoiding RCU stalls
(even without slow consoles) is a clear win. The duration of RCU stall avoided
by this patch is roughly the same with commit b2b469939e934587.

We haven't succeeded making printk() asynchronous (and potentially we won't
succeed making printk() asynchronous because we need synchronous printk()
when something critical is undergoing outside of out_of_memory()). Thus,
bringing printk() to outside of RCU section is a clear win we can make for now.


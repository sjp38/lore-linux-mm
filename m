Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4286BC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:56:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 020C421721
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:56:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 020C421721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A48386B0005; Mon,  1 Jul 2019 09:56:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FAA58E0003; Mon,  1 Jul 2019 09:56:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E7F58E0002; Mon,  1 Jul 2019 09:56:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f206.google.com (mail-pl1-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id 553496B0005
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 09:56:24 -0400 (EDT)
Received: by mail-pl1-f206.google.com with SMTP id q11so7310502pll.22
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 06:56:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=f8slnb0U5mjXGWvuov0dEwebMZZbVdz0BGUzP7LbZgg=;
        b=NEMZD78vmpwVBXuRlilrp3hMY4+/ugr/d4UYLogcAiswNZQO0+CeHCAnQ9Ng+LFrJ5
         L/WfeF7Fc+r5oWfbPI1u7oceOXzIQjWaIjEjCfjZRubJFJFpNWGu20d+4tTVtu7RNdqr
         bQYKcPGsEwnvrkJcyFFmS5IWXPdyKpbgP/WZpisSmeHixLL6U0k4mmN25aiCGu8mgRH/
         Vl03ugbkuer9ciFKIJ5/M8Jpgy48exlFOtnUofi1NSAZBPDOrCzv/MXGrX/bruKkBHSt
         p9bflPMBf3H6sLrNGBCoBpIbnVhBvLdHDoagjurt7wDNmKPbqKQVW6VJhT/a4lFGOTWi
         XDOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUOXqHKzKAS9TQXDDVM6B70twoscuNIeOsymKQ2MT5q6WxbG8HL
	tplKPkQe3OfIqFnID9Bdl26mem9wiOSL9saoXEh02aUEt2seNuRZDZeN792fjqvG00+48OF/oN8
	lP7ImyrHT62ipXPLCcokIy0KOGUGB6LTvoYttxB+G2bUWw/6Ovx+/Opn450YI+D+qDQ==
X-Received: by 2002:a63:4f07:: with SMTP id d7mr24337101pgb.77.1561989383883;
        Mon, 01 Jul 2019 06:56:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytgR6yJgpIxSXrEoh0fEFzB+oNrCkkRdCKV2qncZ6AuoL9jN80oG5zu9kjyL36QoPnWKu0
X-Received: by 2002:a63:4f07:: with SMTP id d7mr24337060pgb.77.1561989383182;
        Mon, 01 Jul 2019 06:56:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561989383; cv=none;
        d=google.com; s=arc-20160816;
        b=gmxiaKuxzM9qMU4ZE7Do04uuExQsf8OMInLWli1tzNR8dY6vQNNhKy1w2vrySC0KGt
         +VDljoBFJl6qZ6Nme6jPY7BW6fEpcBZSx5pYgkz/yRYEFLWCvCw4Ru6CbuahQqPwY4OZ
         s5XlAnPtGdf624RVx3j2gIrZmcipPl/7wmGiG1DPkyMa0oPPxXV8lVGHXrMqN8nzrwjn
         XKVT4Q3uo/Hmq3KnkwaNz/px05xnIUjbuW6+ZHPKYCCSnWLAO3I4lXKPCKLaNqBuvYgM
         Io14qu7QKsf6wFiPtt5C8MUyP3mChjjwFdhKGsEuWYHSXkdgw+NBB0M1mc2P27FKWmHH
         Lm4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=f8slnb0U5mjXGWvuov0dEwebMZZbVdz0BGUzP7LbZgg=;
        b=iTvjECPxnJDAxrZERmD4ymhhswSKalZYS17YtffCdrfsricUhEoAjr0bBu/0SVKCHi
         oWDVNqCfAvcvrskFub2Xf2FDWhaRL4zWJwFbZWcaSRYyq0HcY2Mqm82w4/yPDWWpnkdC
         BMfaPZpcHcaevYIBIsJ4O+hibMZcTrZod9ALgnOEvZnNB6t3VT4M4eZhHFwFRqQcLqS4
         Jhte6NApjgT6+HoV2V36cL9TkxwZbthegN4lcCw7vvOv+dYwAJ++G9PohHR+NZ+PFlkC
         wDoXjDsebQ8oikz049srdY3W6Wp/no3j2YGoh/shrzO3GHLcgjvE+j06IawWtYiTYKP/
         BVlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id bj12si9984618plb.378.2019.07.01.06.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 06:56:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav403.sakura.ne.jp (fsav403.sakura.ne.jp [133.242.250.102])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x61DuG7r086597;
	Mon, 1 Jul 2019 22:56:16 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav403.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp);
 Mon, 01 Jul 2019 22:56:16 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x61DuFMW086570
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Mon, 1 Jul 2019 22:56:16 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
 <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
 <20190701131736.GX6376@dhcp22.suse.cz>
 <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
 <20190701134859.GZ6376@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <a78dbba0-262e-87c5-e278-9e17cf9a63f7@i-love.sakura.ne.jp>
Date: Mon, 1 Jul 2019 22:56:12 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701134859.GZ6376@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/01 22:48, Michal Hocko wrote:
> On Mon 01-07-19 22:38:58, Tetsuo Handa wrote:
>> On 2019/07/01 22:17, Michal Hocko wrote:
>>> On Mon 01-07-19 22:04:22, Tetsuo Handa wrote:
>>>> But I realized that this patch was too optimistic. We need to wait for mm-less
>>>> threads until MMF_OOM_SKIP is set if the process was already an OOM victim.
>>>
>>> If the process is an oom victim then _all_ threads are so as well
>>> because that is the address space property. And we already do check that
>>> before reaching oom_badness IIRC. So what is the actual problem you are
>>> trying to solve here?
>>
>> I'm talking about behavioral change after tsk became an OOM victim.
>>
>> If tsk->signal->oom_mm != NULL, we have to wait for MMF_OOM_SKIP even if
>> tsk->mm == NULL. Otherwise, the OOM killer selects next OOM victim as soon as
>> oom_unkillable_task() returned true because has_intersects_mems_allowed() returned
>> false because mempolicy_nodemask_intersects() returned false because all thread's
>> mm became NULL (despite tsk->signal->oom_mm != NULL).
> 
> OK, I finally got your point. It was not clear that you are referring to
> the code _after_ the patch you are proposing. You are indeed right that
> this would have a side effect that an additional victim could be
> selected even though the current process hasn't terminated yet. Sigh,
> another example how the whole thing is subtle so I retract my Ack and
> request a real life example of where this matters before we think about
> a proper fix and make the code even more complex.
> 

Instead of checking for mm != NULL, can we move mpol_put_task_policy() from
do_exit() to __put_task_struct() ? That change will (if it is safe to do)
prevent exited threads from setting mempolicy = NULL (and confusing
mempolicy_nodemask_intersects() due to mempolicy == NULL).


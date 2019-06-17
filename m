Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EFFBC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:57:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40A1820848
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:57:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40A1820848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B74148E0003; Mon, 17 Jun 2019 05:57:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B24B38E0001; Mon, 17 Jun 2019 05:57:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EC3D8E0003; Mon, 17 Jun 2019 05:57:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75F718E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:57:41 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id a8so4671689oti.8
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:57:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8Ek60o+XUQVNLave7oemVnEx612nPoF6Ue4OUqhFnBo=;
        b=snt9Ze3Bz9sIWEYzUY69SfbkKhxdnWH/Pp6LBlnoGLW8mfhbJlclvX14AkFmpdyoJ7
         sKIcZU++Qgjn12xO0iWmB3Th+zXWLMnubbG+KRla4KkD+7aETkjYYFabM1OVTBDqeGL+
         H+ETDFdCMyawpuD5pAGNpu3E5na0biP68HUc98Zqt3a2cFp1xAA79icqD4g2HNYzPuCC
         Z409GUlTs6YhZD0zQiCKMyLrYWDkRQwk+NtcP7xCQnOxsMTsf+0Rrsc7VWEHKV9ro5fq
         wxTw2KCRLgO4120wQuGXjWiKcOEMs5G6gGKwdTub1Uj+IPAWc1TI7o0fw5Syt/Jp6uky
         lYuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUmprV/+Q2Al+EkPemrmtHjUVmMH/2k97iAe9m95KkjcOFWr+cM
	pbhc3OWguBxOwoSOEEqvGEe0e+o4SwLqeN9CtdWjwzt4pUanNXxVWKL8/wWUdSC6/YS26/7Uy/9
	WZuH7N3heZZl0o2PCqIWGQ9OHivw6kqL3lrLN0nUeJApVFyvJoc+kku3zzZuW6doirQ==
X-Received: by 2002:a9d:22e4:: with SMTP id y91mr54976016ota.40.1560765461101;
        Mon, 17 Jun 2019 02:57:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5GmwLg14nvE5yi15u6tgdkPOTXz43+GK6YAcH1VyDv6AeB32kC2f07ZlFqD2rNJC67Rnj
X-Received: by 2002:a9d:22e4:: with SMTP id y91mr54975981ota.40.1560765460434;
        Mon, 17 Jun 2019 02:57:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560765460; cv=none;
        d=google.com; s=arc-20160816;
        b=QAEdyYpH9zg5ilvFgD5/ZdRboezpkp06RVDZQJ3+qYEXFHse6jVXZQrBsX8pHJYF+1
         TTBYHTo8jXtQo/NzXJ8uGcuZTxTLeWevbPmYuO3ZMTUZOoU2uxc7H1jVQTKcJbzKHMIC
         y4sWg1rKaMSGEO5DfrAcDQ+4lb/R3IOFGhou6Wu8iX2YxnLGg3IzMmhnC96DcxC4Saad
         YEG8lythQYhf7qwt7s0/bK7+qk7mOv11zoFH/l2d4XP6M7eg+zaj+hH1E07fxRzbq21G
         Gax0Jk+bidSiLRpfazOlNFvipFU3BbNeL/KFekvA5dGa8468M3iPu2wfrsxSHpVLbpfk
         sdTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8Ek60o+XUQVNLave7oemVnEx612nPoF6Ue4OUqhFnBo=;
        b=R+A7+DLi0zvg/uEQSyGXTPIroXSrtWPjLo2skE1PX718zYEjaEImeT6PmUB8+r94Ed
         apf59NuKKKSzspvrWUMb2OyeVyUaEkWMj4a/ZHTy2qqTCJgHquUSFe+q/4ukPBfOa8I5
         0j2kj4IPr/gOg6ZONygmkbZeNYsHBbHR8RMPtGGtRnoVZKTK5xcAxKyMZdcVatUm8ryf
         DaGQ/YFW26V1317ktXC/sEXCPL4vQ6GgOUCdoeowCSUSt5QB3b/J1Jp3Cb2ai6AATC+w
         VOsoOYp6FR/x6mFsdf0Al9UdOIPL/WP00vEes7Ij/55J4qVTSD2iV67QM25GAyAfHfTu
         Hrvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v23si4669942oif.133.2019.06.17.02.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 02:57:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav401.sakura.ne.jp (fsav401.sakura.ne.jp [133.242.250.100])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5H9upm3052739;
	Mon, 17 Jun 2019 18:56:51 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav401.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp);
 Mon, 17 Jun 2019 18:56:51 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5H9uksP052600
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Mon, 17 Jun 2019 18:56:50 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: general protection fault in oom_unkillable_task
To: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>
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
 <20190617063319.GB30420@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <268214f9-18ef-b63e-2d4f-c344a7dd5e72@i-love.sakura.ne.jp>
Date: Mon, 17 Jun 2019 18:56:47 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190617063319.GB30420@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/06/17 15:33, Michal Hocko wrote:
> On Sat 15-06-19 09:11:37, Shakeel Butt wrote:
>> On Sat, Jun 15, 2019 at 6:50 AM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
>>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>>> index 5a58778c91d4..43eb479a5dc7 100644
>>> --- a/mm/oom_kill.c
>>> +++ b/mm/oom_kill.c
>>> @@ -161,8 +161,8 @@ static bool oom_unkillable_task(struct task_struct *p,
>>>                 return true;
>>>
>>>         /* When mem_cgroup_out_of_memory() and p is not member of the group */
>>> -       if (memcg && !task_in_mem_cgroup(p, memcg))
>>> -               return true;
>>> +       if (memcg)
>>> +               return false;
>>
>> This will break the dump_tasks() usage of oom_unkillable_task(). We
>> can change dump_tasks() to traverse processes like
>> mem_cgroup_scan_tasks() for memcg OOMs.
> 
> Right you are. Doing a similar trick to the oom victim selection is
> indeed better. We should really strive to not doing a global process
> iteration when we can do a targeted scan. Care to send a patch?

I posted a patch that (as a side effect) avoids oom_unkillable_task() from dump_tasks() at
https://lore.kernel.org/linux-mm/1558519686-16057-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp/ .
What do you think?


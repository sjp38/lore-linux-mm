Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC2396B026B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:14:37 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 91so985273otr.18
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:14:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l8si8263903oth.273.2018.10.09.06.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 06:14:36 -0700 (PDT)
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
References: <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
 <20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
 <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p2>
 <20181008083855epcms1p20e691e5a001f3b94b267997c24e91128@epcms1p2>
 <f5bdf4a7-e491-1cda-590c-792526f49050@i-love.sakura.ne.jp>
 <20181009063541.GB8528@dhcp22.suse.cz> <20181009075015.GC8528@dhcp22.suse.cz>
 <df4b029c-16b4-755f-2672-d7ec116f78ba@i-love.sakura.ne.jp>
 <20181009111005.GK8528@dhcp22.suse.cz>
 <99008444-b6b1-efc9-8670-f3eac4d2305f@i-love.sakura.ne.jp>
 <20181009125841.GP8528@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <41754dfe-3be7-f64e-45c9-2525d3b20d62@i-love.sakura.ne.jp>
Date: Tue, 9 Oct 2018 22:14:24 +0900
MIME-Version: 1.0
In-Reply-To: <20181009125841.GP8528@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: ytk.lee@samsung.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2018/10/09 21:58, Michal Hocko wrote:
> On Tue 09-10-18 21:52:12, Tetsuo Handa wrote:
>> On 2018/10/09 20:10, Michal Hocko wrote:
>>> On Tue 09-10-18 19:00:44, Tetsuo Handa wrote:
>>>>> 2) add OOM_SCORE_ADJ_MIN and do not kill tasks sharing mm and do not
>>>>> reap the mm in the rare case of the race.
>>>>
>>>> That is no problem. The mistake we made in 4.6 was that we updated oom_score_adj
>>>> to -1000 (and allowed unprivileged users to OOM-lockup the system).
>>>
>>> I do not follow.
>>>
>>
>> http://tomoyo.osdn.jp/cgi-bin/lxr/source/mm/oom_kill.c?v=linux-4.6.7#L493
> 
> Ahh, so you are not referring to the current upstream code. Do you see
> any specific problem with the current one (well, except for the possible
> race which I have tried to evaluate).
> 

Yes. "task_will_free_mem(current) in out_of_memory() returns false due to MMF_OOM_SKIP
being already set" is a problem for clone(CLONE_VM without CLONE_THREAD/CLONE_SIGHAND)
with the current code.

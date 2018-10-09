Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA9356B0008
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:51:14 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id h8so1100755otb.4
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:51:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x26si3452896ote.36.2018.10.09.06.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 06:51:13 -0700 (PDT)
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
References: <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p2>
 <20181008083855epcms1p20e691e5a001f3b94b267997c24e91128@epcms1p2>
 <f5bdf4a7-e491-1cda-590c-792526f49050@i-love.sakura.ne.jp>
 <20181009063541.GB8528@dhcp22.suse.cz> <20181009075015.GC8528@dhcp22.suse.cz>
 <df4b029c-16b4-755f-2672-d7ec116f78ba@i-love.sakura.ne.jp>
 <20181009111005.GK8528@dhcp22.suse.cz>
 <99008444-b6b1-efc9-8670-f3eac4d2305f@i-love.sakura.ne.jp>
 <20181009125841.GP8528@dhcp22.suse.cz>
 <41754dfe-3be7-f64e-45c9-2525d3b20d62@i-love.sakura.ne.jp>
 <20181009132622.GR8528@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0ab96b81-042e-b9d9-8d63-b423941d8072@i-love.sakura.ne.jp>
Date: Tue, 9 Oct 2018 22:51:00 +0900
MIME-Version: 1.0
In-Reply-To: <20181009132622.GR8528@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: ytk.lee@samsung.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2018/10/09 22:26, Michal Hocko wrote:
> On Tue 09-10-18 22:14:24, Tetsuo Handa wrote:
>> On 2018/10/09 21:58, Michal Hocko wrote:
>>> On Tue 09-10-18 21:52:12, Tetsuo Handa wrote:
>>>> On 2018/10/09 20:10, Michal Hocko wrote:
>>>>> On Tue 09-10-18 19:00:44, Tetsuo Handa wrote:
>>>>>>> 2) add OOM_SCORE_ADJ_MIN and do not kill tasks sharing mm and do not
>>>>>>> reap the mm in the rare case of the race.
>>>>>>
>>>>>> That is no problem. The mistake we made in 4.6 was that we updated oom_score_adj
>>>>>> to -1000 (and allowed unprivileged users to OOM-lockup the system).
>>>>>
>>>>> I do not follow.
>>>>>
>>>>
>>>> http://tomoyo.osdn.jp/cgi-bin/lxr/source/mm/oom_kill.c?v=linux-4.6.7#L493
>>>
>>> Ahh, so you are not referring to the current upstream code. Do you see
>>> any specific problem with the current one (well, except for the possible
>>> race which I have tried to evaluate).
>>>
>>
>> Yes. "task_will_free_mem(current) in out_of_memory() returns false due to MMF_OOM_SKIP
>> being already set" is a problem for clone(CLONE_VM without CLONE_THREAD/CLONE_SIGHAND)
>> with the current code.
> 
> a) I fail to see how that is related to your previous post and b) could
> you be more specific. Is there any other scenario from the two described
> in my earlier email?
> 

I do not follow. Just reverting commit 44a70adec910d692 and commit 97fd49c2355ffded
is sufficient for closing the copy_process() versus __set_oom_adj() race.

We went too far towards complete "struct mm_struct" based OOM handling. But stepping
back to "struct signal_struct" based OOM handling solves Yong-Taek's for_each_process()
latency problem and your copy_process() versus __set_oom_adj() race problem and my
task_will_free_mem(current) race problem.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E74B86B0007
	for <linux-mm@kvack.org>; Thu, 31 May 2018 11:24:34 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j12-v6so12155111oiw.10
        for <linux-mm@kvack.org>; Thu, 31 May 2018 08:24:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k66-v6si5162733oiy.173.2018.05.31.08.24.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 08:24:33 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
References: <20180525083118.GI11881@dhcp22.suse.cz>
 <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
 <20180525114213.GJ11881@dhcp22.suse.cz>
 <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
 <20180528124313.GC27180@dhcp22.suse.cz>
 <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
 <20180529060755.GH27180@dhcp22.suse.cz>
 <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
 <16eca862-5fa6-2333-8a81-94a2c2692758@i-love.sakura.ne.jp>
 <20180531104450.GN15278@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <7276d450-5e66-be56-3a17-0fc77596a3b6@i-love.sakura.ne.jp>
Date: Fri, 1 Jun 2018 00:23:57 +0900
MIME-Version: 1.0
In-Reply-To: <20180531104450.GN15278@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org

On 2018/05/31 19:44, Michal Hocko wrote:
> On Thu 31-05-18 19:10:48, Tetsuo Handa wrote:
>> On 2018/05/30 8:07, Andrew Morton wrote:
>>> On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>>>
>>>>> I suggest applying
>>>>> this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
>>>>
>>>> Well, I hope the whole pile gets merged in the upcoming merge window
>>>> rather than stall even more.
>>>
>>> I'm more inclined to drop it all.  David has identified significant
>>> shortcomings and I'm not seeing a way of addressing those shortcomings
>>> in a backward-compatible fashion.  Therefore there is no way forward
>>> at present.
>>>
>>
>> Can we apply my patch as-is first?
> 
> No. As already explained before. Sprinkling new sleeps without a strong
> reason is not acceptable. The issue you are seeing is pretty artificial
> and as such doesn're really warrant an immediate fix. We should rather
> go with a well thought trhough fix. In other words we should simply drop
> the sleep inside the oom_lock for starter unless it causes some really
> unexpected behavior change.
> 

The OOM killer did not require schedule_timeout_killable(1) to return
as long as the OOM victim can call __mmput(). But now the OOM killer
requires schedule_timeout_killable(1) to return in order to allow the
OOM victim to call __oom_reap_task_mm(). Thus, this is a regression.

Artificial cannot become the reason to postpone my patch. If we don't care
artificialness/maliciousness, we won't need to care Spectre/Meltdown bugs.

I'm not sprinkling new sleeps. I'm just merging existing sleeps (i.e.
mutex_trylock() case and !mutex_trylock() case) and updating the outdated
comments.

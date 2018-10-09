Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 447BE6B026B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 06:01:04 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c5-v6so885802ioa.0
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 03:01:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e3-v6si15420588jab.96.2018.10.09.03.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 03:01:03 -0700 (PDT)
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
References: <67eedc4c-7afa-e845-6c88-9716fd820de6@i-love.sakura.ne.jp>
 <af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
 <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
 <20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
 <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p2>
 <20181008083855epcms1p20e691e5a001f3b94b267997c24e91128@epcms1p2>
 <f5bdf4a7-e491-1cda-590c-792526f49050@i-love.sakura.ne.jp>
 <20181009063541.GB8528@dhcp22.suse.cz> <20181009075015.GC8528@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <df4b029c-16b4-755f-2672-d7ec116f78ba@i-love.sakura.ne.jp>
Date: Tue, 9 Oct 2018 19:00:44 +0900
MIME-Version: 1.0
In-Reply-To: <20181009075015.GC8528@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: ytk.lee@samsung.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2018/10/09 16:50, Michal Hocko wrote:
> On Tue 09-10-18 08:35:41, Michal Hocko wrote:
>> [I have only now noticed that the patch has been reposted]
>>
>> On Mon 08-10-18 18:27:39, Tetsuo Handa wrote:
>>> On 2018/10/08 17:38, Yong-Taek Lee wrote:
> [...]
>>>> Thank you for your suggestion. But i think it would be better to seperate to 2 issues. How about think these
>>>> issues separately because there are no dependency between race issue and my patch. As i already explained,
>>>> for_each_process path is meaningless if there is only one thread group with many threads(mm_users > 1 but 
>>>> no other thread group sharing same mm). Do you have any other idea to avoid meaningless loop ? 
>>>
>>> Yes. I suggest reverting commit 44a70adec910d692 ("mm, oom_adj: make sure processes
>>> sharing mm have same view of oom_score_adj") and commit 97fd49c2355ffded ("mm, oom:
>>> kill all tasks sharing the mm").
>>
>> This would require a lot of other work for something as border line as
>> weird threading model like this. I will think about something more
>> appropriate - e.g. we can take mmap_sem for read while doing this check
>> and that should prevent from races with [v]fork.
> 
> Not really. We do not even take the mmap_sem when CLONE_VM. So this is
> not the way. Doing a proper synchronization seems much harder. So let's
> consider what is the worst case scenario. We would basically hit a race
> window between copy_signal and copy_mm and the only relevant case would
> be OOM_SCORE_ADJ_MIN which wouldn't propagate to the new "thread".

The "between copy_signal() and copy_mm()" race window is merely whether we need
to run for_each_process() loop. The race window is much larger than that; it is
between "copy_signal() copies oom_score_adj/oom_score_adj_min" and "the created
thread becomes accessible from for_each_process() loop".

>                                                                    OOM
> killer could then pick up the "thread" and kill it along with the whole
> process group sharing the mm.

Just reverting commit 44a70adec910d692 and commit 97fd49c2355ffded is
sufficient.

>                               Well, that is unfortunate indeed and it
> breaks the OOM_SCORE_ADJ_MIN contract. There are basically two ways here
> 1) do not care and encourage users to use a saner way to set
> OOM_SCORE_ADJ_MIN because doing that externally is racy anyway e.g.
> setting it before [v]fork & exec. Btw. do we know about an actual user
> who would care?

I'm not talking about [v]fork & exec. Why are you talking about [v]fork & exec ?

> 2) add OOM_SCORE_ADJ_MIN and do not kill tasks sharing mm and do not
> reap the mm in the rare case of the race.

That is no problem. The mistake we made in 4.6 was that we updated oom_score_adj
to -1000 (and allowed unprivileged users to OOM-lockup the system). Now that we set
MMF_OOM_SKIP, there is no need to worry about "oom_score_adj != -1000" thread group
and "oom_score_adj == -1000" thread group sharing the same mm. Since updating
oom_score_adj to -1000 is a privileged operation, it is administrator's wish if
such case happened; the kernel should respect the administrator's wish.

> 
> I would prefer the firs but if this race really has to be addressed then
> the 2 sounds more reasonable than the wholesale revert.
> 

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C70C36B786C
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:51:02 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 2-v6so5413812plc.11
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:51:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p12-v6si4346972pls.53.2018.09.06.04.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:51:01 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <0aeb76e1-558f-e38e-4c66-77be3ce56b34@I-love.SAKURA.ne.jp>
 <20180906113553.GR14951@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <87b76eea-9881-724a-442a-c6079cbf1016@i-love.sakura.ne.jp>
Date: Thu, 6 Sep 2018 20:50:53 +0900
MIME-Version: 1.0
In-Reply-To: <20180906113553.GR14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On 2018/09/06 20:35, Michal Hocko wrote:
> On Sat 01-09-18 20:48:57, Tetsuo Handa wrote:
>> On 2018/08/07 5:51, Michal Hocko wrote:
>>>> At the risk of continually repeating the same statement, the oom reaper 
>>>> cannot provide the direct feedback for all possible memory freeing.  
>>>> Waking up periodically and finding mm->mmap_sem contended is one problem, 
>>>> but the other problem that I've already shown is the unnecessary oom 
>>>> killing of additional processes while a thread has already reached 
>>>> exit_mmap().  The oom reaper cannot free page tables which is problematic 
>>>> for malloc implementations such as tcmalloc that do not release virtual 
>>>> memory. 
>>>
>>> But once we know that the exit path is past the point of blocking we can
>>> have MMF_OOM_SKIP handover from the oom_reaper to the exit path. So the
>>> oom_reaper doesn't hide the current victim too early and we can safely
>>> wait for the exit path to reclaim the rest. So there is a feedback
>>> channel. I would even do not mind to poll for that state few times -
>>> similar to polling for the mmap_sem. But it would still be some feedback
>>> rather than a certain amount of time has passed since the last check.
>>
>> Michal, will you show us how we can handover as an actual patch? I'm not
>> happy with postponing current situation with just your wish to handover.
> 
> I am sorry but I am bussy with other higher priority issues. I believe I
> have outlined the scheme that might work (see above). All it takes is to
> look into that closer a play with it.

If you are too busy, please show "the point of no-blocking" using source code
instead. If such "the point of no-blocking" really exists, it can be executed
by allocating threads. I think that such "the point of no-blocking" is so late
stage of freeing that it makes no difference with timeout based back off.

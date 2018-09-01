Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 770C96B5C64
	for <linux-mm@kvack.org>; Sat,  1 Sep 2018 07:49:28 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r2-v6so8238751pgp.3
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 04:49:28 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 92-v6si12896647plw.81.2018.09.01.04.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Sep 2018 04:49:27 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <0aeb76e1-558f-e38e-4c66-77be3ce56b34@I-love.SAKURA.ne.jp>
Date: Sat, 1 Sep 2018 20:48:57 +0900
MIME-Version: 1.0
In-Reply-To: <20180806205121.GM10003@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On 2018/08/07 5:51, Michal Hocko wrote:
>> At the risk of continually repeating the same statement, the oom reaper 
>> cannot provide the direct feedback for all possible memory freeing.  
>> Waking up periodically and finding mm->mmap_sem contended is one problem, 
>> but the other problem that I've already shown is the unnecessary oom 
>> killing of additional processes while a thread has already reached 
>> exit_mmap().  The oom reaper cannot free page tables which is problematic 
>> for malloc implementations such as tcmalloc that do not release virtual 
>> memory. 
> 
> But once we know that the exit path is past the point of blocking we can
> have MMF_OOM_SKIP handover from the oom_reaper to the exit path. So the
> oom_reaper doesn't hide the current victim too early and we can safely
> wait for the exit path to reclaim the rest. So there is a feedback
> channel. I would even do not mind to poll for that state few times -
> similar to polling for the mmap_sem. But it would still be some feedback
> rather than a certain amount of time has passed since the last check.

Michal, will you show us how we can handover as an actual patch? I'm not
happy with postponing current situation with just your wish to handover.

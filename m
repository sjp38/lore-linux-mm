Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFD96B18BF
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 07:02:38 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id l185-v6so14100881ite.2
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 04:02:38 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r189-v6si3692148iod.237.2018.08.20.04.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 04:02:37 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: OOM victims do not need to select next OOM
 victim unless __GFP_NOFAIL.
References: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180820105336.GJ29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <1341c62b-cb21-a592-f062-d162da01f912@i-love.sakura.ne.jp>
Date: Mon, 20 Aug 2018 20:02:30 +0900
MIME-Version: 1.0
In-Reply-To: <20180820105336.GJ29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>

On 2018/08/20 19:53, Michal Hocko wrote:
> On Mon 20-08-18 19:37:45, Tetsuo Handa wrote:
>> Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
>> oom_reaped tasks") changed to select next OOM victim as soon as
>> MMF_OOM_SKIP is set. But since OOM victims can try ALLOC_OOM allocation
>> and then give up (if !memcg OOM) or can use forced charge and then retry
>> (if memcg OOM), OOM victims do not need to select next OOM victim unless
>> they are doing __GFP_NOFAIL allocations.
> 
> I do not like this at all. It seems hackish to say the least. And more
> importantly...
> 
>> This is a quick mitigation because syzbot is hitting WARN(1) caused by
>> this race window [1]. More robust fix (e.g. make it possible to reclaim
>> more memory before MMF_OOM_SKIP is set, wait for some more after
>> MMF_OOM_SKIP is set) is a future work.
> 
> .. there is already a patch (by Johannes) for that warning IIRC.

You mean http://lkml.kernel.org/r/20180808144515.GA9276@cmpxchg.org ?
But I can't find that patch in linux-next.git . And as far as I know,
no patch was sent to linux.git for handling this problem. Therefore,
I wrote this patch so that we can apply for 4.19-rc1.

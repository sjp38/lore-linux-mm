Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 32F0F6B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 06:48:19 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h7-v6so2214809itj.7
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 03:48:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d20-v6si10947810iof.99.2018.07.31.03.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 03:48:17 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
References: <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
 <20180730093257.GG24267@dhcp22.suse.cz>
 <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
 <20180730191005.GC24267@dhcp22.suse.cz>
 <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp>
 <20180731050928.GA4557@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b03f09c2-f749-9c80-b4f6-d0b4a9634013@i-love.sakura.ne.jp>
Date: Tue, 31 Jul 2018 19:47:45 +0900
MIME-Version: 1.0
In-Reply-To: <20180731050928.GA4557@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/07/31 14:09, Michal Hocko wrote:
> On Tue 31-07-18 06:01:48, Tetsuo Handa wrote:
>> On 2018/07/31 4:10, Michal Hocko wrote:
>>> Since should_reclaim_retry() should be a natural reschedule point,
>>> let's do the short sleep for PF_WQ_WORKER threads unconditionally in
>>> order to guarantee that other pending work items are started. This will
>>> workaround this problem and it is less fragile than hunting down when
>>> the sleep is missed. E.g. we used to have a sleeping point in the oom
>>> path but this has been removed recently because it caused other issues.
>>> Having a single sleeping point is more robust.
>>
>> linux.git has not removed the sleeping point in the OOM path yet. Since removing the
>> sleeping point in the OOM path can mitigate CVE-2016-10723, please do so immediately.
> 
> is this an {Acked,Reviewed,Tested}-by?

I'm saying that "we used to have a sleeping point in the oom path but this has been
removed recently" is not true. You need to send that patch to linux.git first if you
want to refer that patch in this patch.

> 
> I will send the patch to Andrew if the patch is ok. 

Andrew, can we send the "we used to have a sleeping point in the oom path but this has
been removed recently" patch to linux.git ?

> 
>> (And that change will conflict with Roman's cgroup aware OOM killer patchset. But it
>> should be easy to rebase.)
> 
> That is still a WIP so I would lose sleep over it.
> 

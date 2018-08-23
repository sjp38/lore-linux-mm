Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 202D86B2C10
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 17:01:14 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b124-v6so6394818itb.9
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 14:01:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j69-v6si4004544itb.57.2018.08.23.14.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 14:01:12 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
References: <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
 <20180730191005.GC24267@dhcp22.suse.cz>
 <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp>
 <20180731050928.GA4557@dhcp22.suse.cz>
 <d11c3aa2-0f14-d882-59c5-6634dc56eed1@i-love.sakura.ne.jp>
 <20180803061653.GB27245@dhcp22.suse.cz>
 <804b50cb-0b17-201a-790b-18604396f826@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1808231304080.15798@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <cb2d635c-c14d-c2cc-868a-d4c447364f0d@i-love.sakura.ne.jp>
Date: Fri, 24 Aug 2018 06:00:48 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1808231304080.15798@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/08/24 5:06, David Rientjes wrote:
> For those of us who are tracking CVE-2016-10723 which has peristently been 
> labeled as "disputed" and with no clear indication of what patches address 
> it, I am assuming that commit 9bfe5ded054b ("mm, oom: remove sleep from 
> under oom_lock") and this patch are the intended mitigations?
> 
> A list of SHA1s for merged fixed and links to proposed patches to address 
> this issue would be appreciated.
> 

Commit 9bfe5ded054b ("mm, oom: remove sleep from under oom_lock") is a
mitigation for CVE-2016-10723.

"[PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
should_reclaim_retry()." is independent from CVE-2016-10723.

We haven't made sure that the OOM reaper / exit_mmap() will get enough CPU
resources. For example, under a cluster of concurrently allocating realtime
scheduling priority threads, the OOM reaper takes about 1800 milliseconds
whereas direct OOM reaping takes only a few milliseconds.

Regards.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 947888E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 16:10:23 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id k133so11466758ite.4
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:10:23 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s4si7514630ith.26.2019.01.21.13.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 13:10:22 -0800 (PST)
Subject: Re: [PATCH v2 2/2] mm, oom: remove 'prefer children over parent'
 heuristic
References: <20190121185033.161015-1-shakeelb@google.com>
 <20190121185033.161015-2-shakeelb@google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <323023c0-0bb8-f8c4-4359-61a9550bb1e0@i-love.sakura.ne.jp>
Date: Tue, 22 Jan 2019 06:10:07 +0900
MIME-Version: 1.0
In-Reply-To: <20190121185033.161015-2-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On 2019/01/22 3:50, Shakeel Butt wrote:
>>From the start of the git history of Linux, the kernel after selecting
> the worst process to be oom-killed, prefer to kill its child (if the
> child does not share mm with the parent). Later it was changed to prefer
> to kill a child who is worst. If the parent is still the worst then the
> parent will be killed.
> 
> This heuristic assumes that the children did less work than their parent
> and by killing one of them, the work lost will be less. However this is
> very workload dependent. If there is a workload which can benefit from
> this heuristic, can use oom_score_adj to prefer children to be killed
> before the parent.
> 
> The select_bad_process() has already selected the worst process in the
> system/memcg. There is no need to recheck the badness of its children
> and hoping to find a worse candidate. That's a lot of unneeded racy
> work. Also the heuristic is dangerous because it make fork bomb like
> workloads to recover much later because we constantly pick and kill
> processes which are not memory hogs. So, let's remove this whole
> heuristic.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> 
> ---
> Changelog since v1:
> - Improved commit message based on mhocko's comment.
> - Replaced 'p' with 'victim'.
> - Removed extra pr_err message.

But this version omits printing one of "Out of memory (oom_kill_allocating_task)",
"Out of memory" and "Memory cgroup out of memory" message which is unexpected.
We want to propagate that message to __oom_kill_process() ? ;-)

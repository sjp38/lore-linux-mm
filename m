Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E46128E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:54:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c16-v6so6986605edc.21
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 02:54:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p4-v6si688111edr.292.2018.09.10.02.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 02:54:35 -0700 (PDT)
Date: Mon, 10 Sep 2018 11:54:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180910095433.GE10951@dhcp22.suse.cz>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>

On Sat 08-09-18 13:54:12, Tetsuo Handa wrote:
[...]

I will not comment on the above because I have already done so and you
keep ignoring it so I will not waste my time again. But let me ask about
the following though

> This patch also fixes three possible bugs
> 
>   (1) oom_task_origin() tasks can be selected forever because it did not
>       check for MMF_OOM_SKIP.

Is this a real problem. Could you point to any path that wouldn't bail
out and oom_origin task would keep trying for ever? If such a path
doesn't exist and you believe it is too fragile and point out the older
bugs proving that then I can imagine we should care.

>   (2) sysctl_oom_kill_allocating_task path can be selected forever
>       because it did not check for MMF_OOM_SKIP.

Why is that a problem? sysctl_oom_kill_allocating_task doesn't have any
well defined semantic. It is a gross hack to save long and expensive oom
victim selection. If we were too strict we should even not allow anybody
else but an allocating task to be killed. So selecting it multiple times
doesn't sound harmful to me.

>   (3) CONFIG_MMU=n kernels might livelock because nobody except
>       is_global_init() case in __oom_kill_process() sets MMF_OOM_SKIP.

And now the obligatory question. Is this a real problem?
 
> which prevent proof of "the forward progress guarantee"
> and adds one optimization
> 
>   (4) oom_evaluate_task() was calling oom_unkillable_task() twice because
>       oom_evaluate_task() needs to check for !MMF_OOM_SKIP and
>       oom_task_origin() tasks before calling oom_badness().

ENOPARSE
-- 
Michal Hocko
SUSE Labs

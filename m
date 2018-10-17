Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCBD6B026E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 06:28:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v15-v6so16426925edm.13
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 03:28:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j19-v6si2212121edj.18.2018.10.17.03.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 03:28:22 -0700 (PDT)
Date: Wed, 17 Oct 2018 12:28:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181017102821.GM18839@dhcp22.suse.cz>
References: <1539770782-3343-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1539770782-3343-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On Wed 17-10-18 19:06:22, Tetsuo Handa wrote:
> syzbot is hitting RCU stall at shmem_fault() [1].
> This is because memcg-OOM events with no eligible task (current thread
> is marked as OOM-unkillable) continued calling dump_header() from
> out_of_memory() enabled by commit 3100dab2aa09dc6e ("mm: memcontrol:
> print proper OOM header when no eligible victim left.").
> 
> Michal proposed ratelimiting dump_header() [2]. But I don't think that
> that patch is appropriate because that patch does not ratelimit
> 
>   "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
>   "Out of memory and no killable processes...\n"
> 
> messages which can be printed for every few milliseconds (i.e. effectively
> denial of service for console users) until the OOM situation is solved.
> 
> Let's make sure that next dump_header() waits for at least 60 seconds from
> previous "Out of memory and no killable processes..." message. Michal is
> thinking that any interval is meaningless without knowing the printk()
> throughput. But since printk() is synchronous unless handed over to
> somebody else by commit dbdda842fe96f893 ("printk: Add console owner and
> waiter logic to load balance console writes"), it is likely that all OOM
> messages from this out_of_memory() request is already flushed to consoles
> when pr_warn("Out of memory and no killable processes...\n") returned.
> Thus, we will be able to allow console users to do what they need to do.
> 
> To summarize, this patch allows threads in requested memcg to complete
> memory allocation requests for doing recovery operation, and also allows
> administrators to manually do recovery operation from console if
> OOM-unkillable thread is failing to solve the OOM situation automatically.

Could you explain why this is any better than using a well established
ratelimit approach?
-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19D4A6B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 05:20:48 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c28-v6so9362127pfe.4
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 02:20:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ay8-v6si13079753plb.235.2018.10.16.02.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 02:20:47 -0700 (PDT)
Date: Tue, 16 Oct 2018 11:20:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
Message-ID: <20181016092043.GP18839@dhcp22.suse.cz>
References: <6c0a57b3-bfd4-d832-b0bd-5dd3bcae460e@i-love.sakura.ne.jp>
 <20181015133524.GM18839@dhcp22.suse.cz>
 <201810160055.w9G0t62E045154@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201810160055.w9G0t62E045154@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On Tue 16-10-18 09:55:06, Tetsuo Handa wrote:
> On 2018/10/15 22:35, Michal Hocko wrote:
> >> Nobody can prove that it never kills some machine. This is just one example result of
> >> one example stress tried in my environment. Since I am secure programming man from security
> >> subsystem, I really hate your "Can you trigger it?" resistance. Since this is OOM path
> >> where nobody tests, starting from being prepared for the worst case keeps things simple.
> > 
> > There is simply no way to be generally safe this kind of situation. As
> > soon as your console is so slow that you cannot push the oom report
> > through there is only one single option left and that is to disable the
> > oom report altogether. And that might be a viable option.
> 
> There is a way to be safe this kind of situation. The way is to make sure that printk()
> is called with enough interval. That is, count the interval between the end of previous
> printk() messages and the beginning of next printk() messages.

You are simply wrong. Because any interval is meaningless without
knowing the printk throughput.

[...]

> lines on evey page fault event. A kernel which consumes multiple milliseconds on each page
> fault event (due to printk() messages from the defunctional OOM killer) is stupid.

Not if it represent an unusual situation where there is no eligible
task available. Because this is an exceptional case where the cost of
the printk is simply not relevant.

[...]

I am sorry to skip large part of your message but this discussion, like
many others, doesn't lead anywhere. You simply refuse to understand
some of the core assumptions in this area.

> Anyway, I'm OK if we apply _BOTH_ your patch and my patch. Or I'm OK with simplified
> one shown below (because you don't like per memcg limit).

My patch is adding a rate-limit! I really fail to see why we need yet
another one on top of it. This is just ridiculous. I can see reasons to
tune that rate limit but adding 2 different mechanisms is just wrong.

If your NAK to unify the ratelimit for dump_header for all paths
still holds then I do not care too much to push it forward. But I find
thiis way of the review feedback counter productive.
-- 
Michal Hocko
SUSE Labs

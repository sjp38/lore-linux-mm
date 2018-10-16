Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91E006B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 07:06:23 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id y68-v6so15458365oie.21
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:06:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w205-v6si6248949oif.130.2018.10.16.04.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 04:06:22 -0700 (PDT)
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
References: <6c0a57b3-bfd4-d832-b0bd-5dd3bcae460e@i-love.sakura.ne.jp>
 <20181015133524.GM18839@dhcp22.suse.cz>
 <201810160055.w9G0t62E045154@www262.sakura.ne.jp>
 <20181016092043.GP18839@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <59b9bd23-ff75-0488-fd96-68ee7f049d00@i-love.sakura.ne.jp>
Date: Tue, 16 Oct 2018 20:05:47 +0900
MIME-Version: 1.0
In-Reply-To: <20181016092043.GP18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On 2018/10/16 18:20, Michal Hocko wrote:
>> Anyway, I'm OK if we apply _BOTH_ your patch and my patch. Or I'm OK with simplified
>> one shown below (because you don't like per memcg limit).
> 
> My patch is adding a rate-limit! I really fail to see why we need yet
> another one on top of it. This is just ridiculous. I can see reasons to
> tune that rate limit but adding 2 different mechanisms is just wrong.
> 
> If your NAK to unify the ratelimit for dump_header for all paths
> still holds then I do not care too much to push it forward. But I find
> thiis way of the review feedback counter productive.
> 

Your patch is _NOT_ adding a rate-limit for

  "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
  "Out of memory and no killable processes...\n"

lines!

[   97.519229] Out of memory and no killable processes...
[   97.522060] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.525507] Out of memory and no killable processes...
[   97.528817] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.532345] Out of memory and no killable processes...
[   97.534813] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.538270] Out of memory and no killable processes...
[   97.541449] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.546268] Out of memory and no killable processes...
[   97.548823] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.552399] Out of memory and no killable processes...
[   97.554939] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.558616] Out of memory and no killable processes...
[   97.562257] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.565998] Out of memory and no killable processes...
[   97.568642] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.572169] Out of memory and no killable processes...
[   97.575200] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.579357] Out of memory and no killable processes...
[   97.581912] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.585414] Out of memory and no killable processes...
[   97.589191] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.593586] Out of memory and no killable processes...
[   97.596527] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.600118] Out of memory and no killable processes...
[   97.603237] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.606837] Out of memory and no killable processes...
[   97.611550] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.615244] Out of memory and no killable processes...
[   97.617859] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.621634] Out of memory and no killable processes...
[   97.624884] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.629256] Out of memory and no killable processes...
[   97.631885] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.635367] Out of memory and no killable processes...
[   97.638033] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.641827] Out of memory and no killable processes...
[   97.641993] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.648453] Out of memory and no killable processes...
[   97.651481] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.655082] Out of memory and no killable processes...
[   97.657941] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.663036] Out of memory and no killable processes...
[   97.665890] a.out invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=-1000
[   97.669473] Out of memory and no killable processes...

We don't need to print these lines every few milliseconds. Even if an exceptional case,
this is a DoS for console users. Printing once (or a few times) per a minute will be
enough. Otherwise, users cannot see what they are typing and what are printed.

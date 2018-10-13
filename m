Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9A536B0006
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 07:22:50 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d52-v6so15112186qta.9
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 04:22:50 -0700 (PDT)
Received: from mail-qk1-x742.google.com (mail-qk1-x742.google.com. [2607:f8b0:4864:20::742])
        by mx.google.com with ESMTPS id n12-v6si331334qta.256.2018.10.13.04.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Oct 2018 04:22:46 -0700 (PDT)
Received: by mail-qk1-x742.google.com with SMTP id m8-v6so9204758qka.12
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 04:22:46 -0700 (PDT)
Date: Sat, 13 Oct 2018 07:22:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
Message-ID: <20181013112238.GA762@cmpxchg.org>
References: <000000000000dc48d40577d4a587@google.com>
 <20181010151135.25766-1-mhocko@kernel.org>
 <20181012112008.GA27955@cmpxchg.org>
 <20181012120858.GX5873@dhcp22.suse.cz>
 <9174f087-3f6f-f0ed-6009-509d4436a47a@i-love.sakura.ne.jp>
 <20181012124137.GA29330@cmpxchg.org>
 <0417c888-d74e-b6ae-a8f0-234cbde03d38@i-love.sakura.ne.jp>
 <bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On Sat, Oct 13, 2018 at 08:09:30PM +0900, Tetsuo Handa wrote:
> ---------- Michal's patch ----------
> 
> 73133 lines (5.79MB) of kernel messages per one run
> 
> [root@ccsecurity ~]# time ./a.out
> 
> real    3m44.389s
> user    0m0.000s
> sys     3m42.334s
> 
> [root@ccsecurity ~]# time ./a.out
> 
> real    3m41.767s
> user    0m0.004s
> sys     3m39.779s
> 
> ---------- My v2 patch ----------
> 
> 50 lines (3.40 KB) of kernel messages per one run
> 
> [root@ccsecurity ~]# time ./a.out
> 
> real    0m5.227s
> user    0m0.000s
> sys     0m4.950s
> 
> [root@ccsecurity ~]# time ./a.out
> 
> real    0m5.249s
> user    0m0.000s
> sys     0m4.956s

Your patch is suppressing information that I want to have and my
console can handle, just because your console is slow, even though
there is no need to use that console at that log level.

NAK to your patch. I think you're looking at this from the wrong
angle. A console that takes almost 4 minutes to print 70k lines
shouldn't be the baseline for how verbose KERN_INFO is.

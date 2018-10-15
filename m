Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D99376B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 07:24:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e5-v6so11911929eda.4
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:24:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10-v6si6678520ejx.202.2018.10.15.04.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 04:24:31 -0700 (PDT)
Date: Mon, 15 Oct 2018 13:24:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
Message-ID: <20181015112427.GI18839@dhcp22.suse.cz>
References: <20181012112008.GA27955@cmpxchg.org>
 <20181012120858.GX5873@dhcp22.suse.cz>
 <9174f087-3f6f-f0ed-6009-509d4436a47a@i-love.sakura.ne.jp>
 <20181012124137.GA29330@cmpxchg.org>
 <0417c888-d74e-b6ae-a8f0-234cbde03d38@i-love.sakura.ne.jp>
 <bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp>
 <20181013112238.GA762@cmpxchg.org>
 <b61b2e60-d899-90c6-579a-587815cebff6@i-love.sakura.ne.jp>
 <20181015081934.GD18839@dhcp22.suse.cz>
 <ea637f9a-5dd0-f927-d26d-d0b4fd8ccb6f@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea637f9a-5dd0-f927-d26d-d0b4fd8ccb6f@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On Mon 15-10-18 19:57:35, Tetsuo Handa wrote:
> On 2018/10/15 17:19, Michal Hocko wrote:
> > As so many dozens of times before, I will point you to an incremental
> > nature of changes we really prefer in the mm land. We are also after a
> > simplicity which your proposal lacks in many aspects. You seem to ignore
> > that general approach and I have hard time to consider your NAK as a
> > relevant feedback. Going to an extreme and basing a complex solution on
> > it is not going to fly. No killable process should be a rare event which
> > requires a seriously misconfigured memcg to happen so wildly. If you can
> > trigger it with a normal user privileges then it would be a clear bug to
> > address rather than work around with printk throttling.
> > 
> 
> I can trigger 200+ times / 900+ lines / 69KB+ of needless OOM messages
> with a normal user privileges. This is a lot of needless noise/delay.

I am pretty sure you have understood the part of my message you have
chosen to not quote where I have said that the specific rate limitting
decisions can be changed based on reasonable configurations. There is
absolutely zero reason to NAK a natural decision to unify the throttling
and cook a per-memcg way for a very specific path instead.

> No killable process is not a rare event, even without root privileges.
>
> [root@ccsecurity kumaneko]# time ./a.out
> Killed
> 
> real    0m2.396s
> user    0m0.000s
> sys     0m2.970s
> [root@ccsecurity ~]# dmesg | grep 'no killable' | wc -l
> 202
> [root@ccsecurity ~]# dmesg | wc
>     942    7335   70716

OK, so this is 70kB worth of data pushed throug the console. Is this
really killing any machine?
-- 
Michal Hocko
SUSE Labs

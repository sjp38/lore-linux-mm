Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84ACB6B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 02:55:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a12-v6so17627646eda.8
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 23:55:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e20-v6si5561440edc.260.2018.10.17.23.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 23:55:22 -0700 (PDT)
Date: Thu, 18 Oct 2018 08:55:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181018065519.GV18839@dhcp22.suse.cz>
References: <20181017102821.GM18839@dhcp22.suse.cz>
 <20181017111724.GA459@jagdpanzerIV>
 <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On Thu 18-10-18 11:46:50, Tetsuo Handa wrote:
> Sergey Senozhatsky wrote:
> > On (10/17/18 12:28), Michal Hocko wrote:
> > > > Michal proposed ratelimiting dump_header() [2]. But I don't think that
> > > > that patch is appropriate because that patch does not ratelimit
> > > > 
> > > >   "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
> > > >   "Out of memory and no killable processes...\n"
> > [..]
> > > > Let's make sure that next dump_header() waits for at least 60 seconds from
> > > > previous "Out of memory and no killable processes..." message.
> > > 
> > > Could you explain why this is any better than using a well established
> > > ratelimit approach?
> 
> This is essentially a ratelimit approach, roughly equivalent with:
> 
>   static DEFINE_RATELIMIT_STATE(oom_no_victim_rs, 60 * HZ, 1);
>   oom_no_victim_rs.flags |= RATELIMIT_MSG_ON_RELEASE;
> 
>   if (__ratelimit(&oom_no_victim_rs)) {
>     dump_header(oc, NULL);
>     pr_warn("Out of memory and no killable processes...\n");
>     oom_no_victim_rs.begin = jiffies;
>   }

Then there is no reason to reinvent the wheel. So use the standard
ratelimit approach. Or put it in other words, this place is no special
to any other that needs some sort of printk throttling. We surely do not
want an ad-hoc solutions all over the kernel.

And once you realize that the ratelimit api is the proper one (put aside
any potential improvements in the implementation of this api) then you
quickly learn that we already do throttle oom reports and it would be
nice to unify that and ... we are back to a naked patch. So please stop
being stuborn and try to cooperate finally.
-- 
Michal Hocko
SUSE Labs

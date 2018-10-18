Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 744A66B0266
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 22:47:17 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id 207-v6so4559155itj.6
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 19:47:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 135-v6si2928140itu.21.2018.10.17.19.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 19:47:16 -0700 (PDT)
Message-Id: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no eligible
 task.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 18 Oct 2018 11:46:50 +0900
References: <20181017102821.GM18839@dhcp22.suse.cz> <20181017111724.GA459@jagdpanzerIV>
In-Reply-To: <20181017111724.GA459@jagdpanzerIV>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

Sergey Senozhatsky wrote:
> On (10/17/18 12:28), Michal Hocko wrote:
> > > Michal proposed ratelimiting dump_header() [2]. But I don't think that
> > > that patch is appropriate because that patch does not ratelimit
> > > 
> > >   "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
> > >   "Out of memory and no killable processes...\n"
> [..]
> > > Let's make sure that next dump_header() waits for at least 60 seconds from
> > > previous "Out of memory and no killable processes..." message.
> > 
> > Could you explain why this is any better than using a well established
> > ratelimit approach?

This is essentially a ratelimit approach, roughly equivalent with:

  static DEFINE_RATELIMIT_STATE(oom_no_victim_rs, 60 * HZ, 1);
  oom_no_victim_rs.flags |= RATELIMIT_MSG_ON_RELEASE;

  if (__ratelimit(&oom_no_victim_rs)) {
    dump_header(oc, NULL);
    pr_warn("Out of memory and no killable processes...\n");
    oom_no_victim_rs.begin = jiffies;
  }

> 
> Tetsuo, let's use a well established rate-limit approach both in
> dump_hedaer() and out_of_memory(). I actually was under impression
> that Michal added rate-limiting to both of these functions.

Honestly speaking, I wonder whether rate-limit approach helps.
Using a late-limit is a runaround at best.

The fundamental problem here is that we are doing

  while (!fatal_signal_pending(current) && !(current->flags & PF_EXITING)) {
      pr_warn("Help me! I can't kill somebody...\n");
      cond_resched();
  }

when we are under memcg OOM situation and we can't OOM-kill some process
(i.e. we can make no progress). No matter how we throttle pr_warn(), this
will keep consuming CPU resources until the memcg OOM situation is solved.

We call panic() if this is global OOM situation. But for memcg OOM situation,
we do nothing and just hope that the memcg OOM situation is solved shortly.

Until commit 3100dab2aa09dc6e ("mm: memcontrol: print proper OOM header when
no eligible victim left."), we used WARN(1) to report that we are in a bad
situation. And since syzbot happened to hit this WARN(1) with panic_on_warn == 1,
that commit removed this WARN(1) and instead added dump_header() and pr_warn().
And then since syzbot happened to hit RCU stalls at dump_header() added by
that commit, we are trying to mitigate this problem.

But what happens if threads hitting this path are SCHED_RT priority and deprived
threads not hitting this path (e.g. administrator's console session) of all CPU
resources for doing recovery operation? We might succeed with reducing frequency
of messing up the console screens with printk(), but we might fail to solve this
memcg OOM situation after all...

> 
> The appropriate rate-limit value looks like something that printk()
> should know and be able to tell to the rest of the kernel. I don't
> think that middle ground will ever be found elsewhere.
> 
> 
> printk() knows what consoles are registered, and printk() also knows
> (sometimes) what console="..." options the kernel was provided with.
> If baud rates ware not provided as console= options, then serial
> consoles usually use some default value. We can probably ask consoles.
> 
> So *maybe* we can do something like this
> 
> //
> // WARNING: this is just a sketch. A silly idea.
> //          I don't know if we can make it usable.
> //
> 
> ---
> 
> int printk_ratelimit_interval(void)
> {
>        int ret = DEFAULT_RATELIMIT_INTERVAL;
>        struct tty_driver *driver = NULL;
>        speed_t min_baud = MAX_INT;
> 
>        console_lock();
>        for_each_console(c) {
>                speed_t br;
> 
>                if (!c->device)
>                        continue;
>                if (!(c->flags & CON_ENABLED))
>                        continue;
>                if (!c->write)
>                        continue;
>                driver = c->device(c, index);
>                if (!driver)
>                        continue;
> 
>                br = tty_get_baud_rate(tty_driver to tty_struct [???]);
>                min_baud = min(min_baud, br);
>        }
>        console_unlock();
> 
>        switch (min_baud) {
>        case 115200:
>                return ret;
> 
>        case ...blah blah...:
>                return ret * 2;
> 
>        case 9600:
>                return ret * 4;
>        }
>        return ret;
> }

I don't think that baud rate is relevant. Writing to console messes up
operations by console users. What matters is that we don't mess up consoles
to the level (or frequency) where console users cannot do their operations.
That is, interval between the last moment we wrote to a console and the
first moment we will write to a console for the next time matters. Roughly
speaking, remember the time stamp when we called call_console_drivers() for
the last time, and compare with that stamp before trying to call a sort of
ratelimited printk(). My patch is doing it using per call-site stamp recording.

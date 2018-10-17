Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA2E6B0008
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 07:17:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h9-v6so19512888pgs.11
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:17:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h20-v6sor7629786pgg.78.2018.10.17.04.17.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 04:17:30 -0700 (PDT)
Date: Wed, 17 Oct 2018 20:17:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181017111724.GA459@jagdpanzerIV>
References: <1539770782-3343-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181017102821.GM18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181017102821.GM18839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On (10/17/18 12:28), Michal Hocko wrote:
> > Michal proposed ratelimiting dump_header() [2]. But I don't think that
> > that patch is appropriate because that patch does not ratelimit
> > 
> >   "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
> >   "Out of memory and no killable processes...\n"
[..]
> > Let's make sure that next dump_header() waits for at least 60 seconds from
> > previous "Out of memory and no killable processes..." message.
> 
> Could you explain why this is any better than using a well established
> ratelimit approach?

Tetsuo, let's use a well established rate-limit approach both in
dump_hedaer() and out_of_memory(). I actually was under impression
that Michal added rate-limiting to both of these functions.

The appropriate rate-limit value looks like something that printk()
should know and be able to tell to the rest of the kernel. I don't
think that middle ground will ever be found elsewhere.


printk() knows what consoles are registered, and printk() also knows
(sometimes) what console="..." options the kernel was provided with.
If baud rates ware not provided as console= options, then serial
consoles usually use some default value. We can probably ask consoles.

So *maybe* we can do something like this

//
// WARNING: this is just a sketch. A silly idea.
//          I don't know if we can make it usable.
//

---

int printk_ratelimit_interval(void)
{
       int ret = DEFAULT_RATELIMIT_INTERVAL;
       struct tty_driver *driver = NULL;
       speed_t min_baud = MAX_INT;

       console_lock();
       for_each_console(c) {
               speed_t br;

               if (!c->device)
                       continue;
               if (!(c->flags & CON_ENABLED))
                       continue;
               if (!c->write)
                       continue;
               driver = c->device(c, index);
               if (!driver)
                       continue;

               br = tty_get_baud_rate(tty_driver to tty_struct [???]);
               min_baud = min(min_baud, br);
       }
       console_unlock();

       switch (min_baud) {
       case 115200:
               return ret;

       case ...blah blah...:
               return ret * 2;

       case 9600:
               return ret * 4;
       }
       return ret;
}

---

	-ss

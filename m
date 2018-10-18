Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFBC6B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 00:27:46 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 25-v6so25312603pfs.5
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 21:27:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bd5-v6sor8938350plb.70.2018.10.17.21.27.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 21:27:44 -0700 (PDT)
Date: Thu, 18 Oct 2018 13:27:39 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181018042739.GA650@jagdpanzerIV>
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
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On (10/18/18 11:46), Tetsuo Handa wrote:
> Sergey Senozhatsky wrote:
> > 
> > int printk_ratelimit_interval(void)
> > {
> >        int ret = DEFAULT_RATELIMIT_INTERVAL;
> >        struct tty_driver *driver = NULL;
> >        speed_t min_baud = MAX_INT;
> > 
> >        console_lock();
> >        for_each_console(c) {
> >                speed_t br;
> > 
> >                if (!c->device)
> >                        continue;
> >                if (!(c->flags & CON_ENABLED))
> >                        continue;
> >                if (!c->write)
> >                        continue;
> >                driver = c->device(c, index);
> >                if (!driver)
> >                        continue;
> > 
> >                br = tty_get_baud_rate(tty_driver to tty_struct [???]);
> >                min_baud = min(min_baud, br);
> >        }
> >        console_unlock();
> > 
> >        switch (min_baud) {
> >        case 115200:
> >                return ret;
> > 
> >        case ...blah blah...:
> >                return ret * 2;
> > 
> >        case 9600:
> >                return ret * 4;
> >        }
> >        return ret;
> > }
> 
> I don't think that baud rate is relevant. Writing to console messes up
> operations by console users. What matters is that we don't mess up consoles
> to the level (or frequency) where console users cannot do their operations.
> That is, interval between the last moment we wrote to a console and the
> first moment we will write to a console for the next time matters. Roughly
> speaking, remember the time stamp when we called call_console_drivers() for
> the last time, and compare with that stamp before trying to call a sort of
> ratelimited printk(). My patch is doing it using per call-site stamp recording.

To my personal taste, "baud rate of registered and enabled consoles"
approach is drastically more relevant than hard coded 10 * HZ or
60 * HZ magic numbers... But not in the form of that "min baud rate"
brain fart, which I have posted.

What I'd do:

-- Iterate over all registered and enabled serial consoles
-- Sum up all the baud rates
-- Calculate (*roughly*) how many bytes per second/minute/etc my
   call_console_driver() can push

        -- we actually don't even have to iterate all consoles. Just
	   add a baud rate in register_console() and sub baud rate
	   in unregister_console() of each console individually
	-- and have a static unsigned long in printk.c, which OOM
	   can use in rate-limit interval check

-- Leave all the noise behind: e.g. console_sem can be locked by
   a preempted fbcon, etc. It's out of my control; bad luck, there
   is nothing I can do about it.
-- Then I would, probably, take the most recent, say, 100 OOM
   reports, and calculate the *average* strlen() value
   (including \r and \n at the end of each line)

	(strlen(oom_report1) + ... + strlen(omm_report100)) / 100

   Then I'd try to reach an agreement with MM people that we will
   use this "average" oom_report_strlen() in ratelimit interval
   calculation. Yes, some reports will be longer, some shorter.

	Say, suppose...
	
	I have 2 consoles, and I can write 250 bytes per second.
	And average oom_report is 5000 bytes.
	Then I can print one oom_report every (5000 / 250) seconds
	in the *best* case. That's the optimistic baseline. There
	can be printk()-s from other CPUs, etc. etc. No one can
	predict those things.

	Note, how things change when I have just 1 console enabled.

	I have 1 console, and I can write 500 bytes per second.
	And average oom_report is 5000 bytes.
	Then I can print one oom_report every (5000 / 500) seconds
	in the *best* case.

Just my $0.02. Who knows, may be it's dumb and ugly.
I don't have a dog in this fight.

	-ss

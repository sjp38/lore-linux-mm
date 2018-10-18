Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 839F66B0269
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 10:30:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p89-v6so29468093pfj.12
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 07:30:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1-v6si21287148plq.274.2018.10.18.07.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 07:30:37 -0700 (PDT)
Date: Thu, 18 Oct 2018 16:30:33 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181018143033.z5gck2enrictqja3@pathway.suse.cz>
References: <20181017102821.GM18839@dhcp22.suse.cz>
 <20181017111724.GA459@jagdpanzerIV>
 <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018042739.GA650@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On Thu 2018-10-18 13:27:39, Sergey Senozhatsky wrote:
> On (10/18/18 11:46), Tetsuo Handa wrote:
> > Sergey Senozhatsky wrote:
> > > 
> > > int printk_ratelimit_interval(void)
> > > {
> > >        int ret = DEFAULT_RATELIMIT_INTERVAL;
> > >        struct tty_driver *driver = NULL;
> > >        speed_t min_baud = MAX_INT;
> > > 
> > >        console_lock();
> > >        for_each_console(c) {
> > >                speed_t br;
> > > 
> > >                if (!c->device)
> > >                        continue;
> > >                if (!(c->flags & CON_ENABLED))
> > >                        continue;
> > >                if (!c->write)
> > >                        continue;
> > >                driver = c->device(c, index);
> > >                if (!driver)
> > >                        continue;
> > > 
> > >                br = tty_get_baud_rate(tty_driver to tty_struct [???]);
> > >                min_baud = min(min_baud, br);
> > >        }
> > >        console_unlock();
> > > 
> > >        switch (min_baud) {
> > >        case 115200:
> > >                return ret;
> > > 
> > >        case ...blah blah...:
> > >                return ret * 2;
> > > 
> > >        case 9600:
> > >                return ret * 4;
> > >        }
> > >        return ret;
> > > }
> > 
> > I don't think that baud rate is relevant. Writing to console messes up
> > operations by console users. What matters is that we don't mess up consoles
> > to the level (or frequency) where console users cannot do their operations.
> > That is, interval between the last moment we wrote to a console and the
> > first moment we will write to a console for the next time matters. Roughly
> > speaking, remember the time stamp when we called call_console_drivers() for
> > the last time, and compare with that stamp before trying to call a sort of
> > ratelimited printk(). My patch is doing it using per call-site stamp recording.
> 
> To my personal taste, "baud rate of registered and enabled consoles"
> approach is drastically more relevant than hard coded 10 * HZ or
> 60 * HZ magic numbers... But not in the form of that "min baud rate"
> brain fart, which I have posted.
> 
> What I'd do:
> 
> -- Iterate over all registered and enabled serial consoles
> -- Sum up all the baud rates
> -- Calculate (*roughly*) how many bytes per second/minute/etc my
>    call_console_driver() can push
> 
>         -- we actually don't even have to iterate all consoles. Just
> 	   add a baud rate in register_console() and sub baud rate
> 	   in unregister_console() of each console individually
> 	-- and have a static unsigned long in printk.c, which OOM
> 	   can use in rate-limit interval check
> 
> -- Leave all the noise behind: e.g. console_sem can be locked by
>    a preempted fbcon, etc. It's out of my control; bad luck, there
>    is nothing I can do about it.
> -- Then I would, probably, take the most recent, say, 100 OOM
>    reports, and calculate the *average* strlen() value
>    (including \r and \n at the end of each line)

This looks very complex and I see even more problems:

  + You would need to update the rate limit intervals when
    new console is attached. Note that the ratelimits might
    get initialized early during boot. It might be solvable
    but ...

  + You might need to update the length of the message
    when the text (code) is updated. It might be hard
    to maintain.

  + You would need to take into account also console_level
    and the level of the printed messages

  + This approach does not take into account all other
    messages that might be printed by other subsystems.


I have just talked with Michal in person. He pointed out
that we primary need to know when and if the last printed
message already reached the console.

A solution might be to handle printk and ratelimit together.
For example:

   + store log_next_idx of the printed message into
     the ratelimit structure

   + eventually store pointer of the ratelimit structure
     into printk_log

   + eventually store the timestamp when the message
     reached the console into the ratelimit structure

Then the ratelimited printk might take into acount whether
the previous message already reached console and even when.


Well, this is still rather complex. I am not persuaded that
it is worth it.

I suggest to take a breath, stop looking for a perfect solution
for a bit. The existing ratelimit might be perfectly fine
in practice. You might always create stress test that would
fail but the test might be far from reality. Any complex
solution might bring more problems that solve.

Console full of repeated messages need not be a catastrophe
when it helps to fix the problem and the system is usable
and need a reboot anyway.

Best Regards,
Petr

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A2DF56B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 03:10:49 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e1so14144230pga.5
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 00:10:49 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id 1si857404pli.41.2017.06.05.00.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 00:10:48 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id 83so21186097pfr.0
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 00:10:48 -0700 (PDT)
Date: Mon, 5 Jun 2017 16:10:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170605071053.GA471@jagdpanzerIV.localdomain>
References: <20170601132808.GD9091@dhcp22.suse.cz>
 <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz>
 <20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
 <20170603073221.GB21524@dhcp22.suse.cz>
 <201706031736.DHB82306.QOOHtVFFSJFOLM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706031736.DHB82306.QOOHtVFFSJFOLM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.com, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky@gmail.com, pmladek@suse.com

Hello,

On (06/03/17 17:36), Tetsuo Handa wrote:
[..]
> > Tetsuo is arguing that the locking will throttle warn_alloc callers and
> > that can help other processes to move on. I would call it papering over
> > a real issue which might be somewhere else and that is why I push back so
> > hard. The initial report is far from complete and seeing 30+ seconds
> > stalls without any indication that this is just a repeating stall after
> > 10s and 20s suggests that we got stuck somewhere in the reclaim path.
> 
> That timestamp jump is caused by the fact that log_buf writers are consuming
> more CPU times than log_buf readers can consume. If I leave that situation
> more, printk() just starts printing "** %u printk messages dropped ** " line.

hhmm... sorry, not sure I see how printk() would affect timer ticks. unless
you do printing from timer IRQs, or always in deferred printk() mode, which
runs from timer IRQ... timestamps are assigned at the moment we add a new
message to the logbuf, not when we print it. so slow serial console really
should not affect it. unless I'm missing something.

	vprintk_emit()
	{
		logbuf_lock_irqsave(flags);

		log_output(facility, level, lflags, dict, dictlen, text, text_len);
		{
			log_store()
			{
				msg->ts_nsec = local_clock();
						^^^^^^^^^^^^^
			}
		}

		logbuf_unlock_irqrestore(flags);

		if (console_trylock())
			console_unlock();
	}


I don't think vprintk_emit() was spinning on logbuf_lock_irqsave(),
you would have seen spinlock lockup reports otherwise. in console_unlock()
logbuf lock is acquired only to pick the first pending messages and,
basically, do memcpy() to a static buffer. we don't call "slow console
drivers" with the logbuf lock taken. so other CPUs are free/welcome to
append new messages to the logbuf in the meantime (and read accurate
local_clock()).

so if you see spikes in messages' timestamps it's most likely because
there was something between printk() calls that kept the CPU busy.

/* or you had a ton of printk calls from other CPUs with noisy loglevels
   that were suppressed later in console_unlock(), see later. */

... well, serial consoles can be slow, sure.


> Notice the timestamp jump between [  351.239144] and [  389.308085].

do you have a restrictive console loglevel and a ton of messages that
were simply filtered out by console loglevel check? we still store those
messages to the logbuf (for dmesg, etc.) and process them in console_unlock(),
but don't print to the serial console. so, in other words,

logbuf:

	timestamp T0	message M0		-- visible loglevel
	timestamp T1	message M1  		-- suppressed loglevel
	....
	timestamp T100	message M101		-- suppressed loglevel
	timestamp T101	message M102		-- visible loglevel

on the serial console you'll see

	T0	M0
	T101	M102

which might look like a spike in timestamps (while there weren't any).
just a thought.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

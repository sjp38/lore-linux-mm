Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8906B0009
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 06:32:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k16-v6so15671018wrh.6
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 03:32:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d18si10718026edj.187.2018.04.23.03.32.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 03:32:33 -0700 (PDT)
Date: Mon, 23 Apr 2018 12:32:32 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180423103232.k23yulv2e7fah42r@pathway.suse.cz>
References: <20180416014729.GB1034@jagdpanzerIV>
 <20180416042553.GA555@jagdpanzerIV>
 <20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
 <20180420021511.GB6397@jagdpanzerIV>
 <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
 <20180420080428.622a8e7f@gandalf.local.home>
 <20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
 <20180420101751.6c1c70e8@gandalf.local.home>
 <20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
 <20180420111307.44008fc7@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420111307.44008fc7@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri 2018-04-20 11:13:07, Steven Rostedt wrote:
> On Fri, 20 Apr 2018 16:57:20 +0200
> Petr Mladek <pmladek@suse.com> wrote:
> 
> 
> > No, call_console_drivers() is done with interrupts disabled:
> > 
> > 		console_lock_spinning_enable();
> > 
> > 		stop_critical_timings();	/* don't trace print latency */
> >  ---->		call_console_drivers(ext_text, ext_len, text, len);  
> > 		start_critical_timings();
> > 
> > 		if (console_lock_spinning_disable_and_check()) {
> >  ---->			printk_safe_exit_irqrestore(flags);  
> > 			goto out;
> > 		}
> > 
> >  ---->		printk_safe_exit_irqrestore(flags);  
> > 
> > They were called with interrupts disabled for ages, long before
> > printk_safe. In fact, it was all the time in the git kernel history.
> > 
> > Therefore only NMIs are in the game. And they should be solved
> > by the above change.
> > 
> 
> Really?
> 
> 
>   console_trylock_spinning(); /* console_owner now equals current */

No, console_trylock_spinning() does not modify console_owner. The
handshake is done using console_waiter variable.

console_owner is really set only between:

    console_lock_spinning_enable()
    console_lock_spinning_disable_and_check()

and this entire section is called with interrupts disabled.

Best Regards,
Petr

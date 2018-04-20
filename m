Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8826B005C
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 11:13:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d13so4788995pfn.21
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:13:12 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z23-v6si5965723plo.597.2018.04.20.08.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 08:13:10 -0700 (PDT)
Date: Fri, 20 Apr 2018 11:13:07 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180420111307.44008fc7@gandalf.local.home>
In-Reply-To: <20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
References: <20180413101233.0792ebf0@gandalf.local.home>
	<20180414023516.GA17806@tigerII.localdomain>
	<20180416014729.GB1034@jagdpanzerIV>
	<20180416042553.GA555@jagdpanzerIV>
	<20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
	<20180420021511.GB6397@jagdpanzerIV>
	<20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
	<20180420080428.622a8e7f@gandalf.local.home>
	<20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
	<20180420101751.6c1c70e8@gandalf.local.home>
	<20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, 20 Apr 2018 16:57:20 +0200
Petr Mladek <pmladek@suse.com> wrote:


> No, call_console_drivers() is done with interrupts disabled:
> 
> 		console_lock_spinning_enable();
> 
> 		stop_critical_timings();	/* don't trace print latency */
>  ---->		call_console_drivers(ext_text, ext_len, text, len);  
> 		start_critical_timings();
> 
> 		if (console_lock_spinning_disable_and_check()) {
>  ---->			printk_safe_exit_irqrestore(flags);  
> 			goto out;
> 		}
> 
>  ---->		printk_safe_exit_irqrestore(flags);  
> 
> They were called with interrupts disabled for ages, long before
> printk_safe. In fact, it was all the time in the git kernel history.
> 
> Therefore only NMIs are in the game. And they should be solved
> by the above change.
> 

Really?


  console_trylock_spinning(); /* console_owner now equals current */
  console_unlock() {

---> take interrupt here:

					vprintk() {
					   vprintk_func() {
					      if (console_owner == current && !__ratelimit(&ratelimit_console))

				[ RATE LIMIT HERE!!!! ]


	for (;;) {
		printk_safe_enter_irqsave(flags);

-- Steve

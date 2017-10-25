Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 674256B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 06:47:20 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f187so414966itb.6
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 03:47:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r84si1750905itr.52.2017.10.25.03.47.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 03:47:19 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize out_of_memory() and allocation stall messages.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1508410262-4797-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171019114424.4db2hohyyogpjq5f@dhcp22.suse.cz>
	<201710201920.FCE43223.FQMVJOtOOSFFLH@I-love.SAKURA.ne.jp>
	<201710242023.GHE48971.SQHtFFLFVJOMOO@I-love.SAKURA.ne.jp>
In-Reply-To: <201710242023.GHE48971.SQHtFFLFVJOMOO@I-love.SAKURA.ne.jp>
Message-Id: <201710251947.BIF34353.OFFFStOHQMJLVO@I-love.SAKURA.ne.jp>
Date: Wed, 25 Oct 2017 19:47:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xiyou.wangcong@gmail.com, hannes@cmpxchg.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, yuwang.yuwang@alibaba-inc.com

Tetsuo Handa wrote:
> While warn_alloc() messages are completely unreadable, what we should note are that
> 
>  (a) out_of_memory() => oom_kill_process() => dump_header() => show_mem() => printk()
>      got stuck at console_unlock() despite this is schedulable context.
> 
> ----------
> 2180:   for (;;) {
> 2181:           struct printk_log *msg;
> 2182:           size_t ext_len = 0;
> 2183:           size_t len;
> 2184:
> 2185:           printk_safe_enter_irqsave(flags);
> 2186:           raw_spin_lock(&logbuf_lock);
> (...snipped...)
> 2228:           console_idx = log_next(console_idx);
> 2229:           console_seq++;
> 2230:           raw_spin_unlock(&logbuf_lock);
> 2231:
> 2232:           stop_critical_timings();        /* don't trace print latency */
> 2233:           call_console_drivers(ext_text, ext_len, text, len);
> 2234:           start_critical_timings();
> 2235:           printk_safe_exit_irqrestore(flags); // console_unlock+0x24e/0x4c0 is here.
> 2236:
> 2237:           if (do_cond_resched)
> 2238:                   cond_resched();
> 2239:   }
> ----------

It turned out that cond_resched() was not called due to do_cond_resched == 0 due to
preemptible() == 0 due to CONFIG_PREEMPT_COUNT=n despite CONFIG_PREEMPT_VOLUNTARY=y,
for CONFIG_PREEMPT_VOLUNTARY itself does not select CONFIG_PREEMPT_COUNT. Surprising...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

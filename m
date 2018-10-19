Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C56B6B0007
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 20:18:45 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 91so23065514otr.18
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 17:18:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u7-v6si10478231oie.95.2018.10.18.17.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 17:18:43 -0700 (PDT)
Message-Id: <201810190018.w9J0IGI2019559@www262.sakura.ne.jp>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no eligible
 task.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 19 Oct 2018 09:18:16 +0900
References: <20181018042739.GA650@jagdpanzerIV> <20181018143033.z5gck2enrictqja3@pathway.suse.cz>
In-Reply-To: <20181018143033.z5gck2enrictqja3@pathway.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

Petr Mladek wrote:
> This looks very complex and I see even more problems:
> 
>   + You would need to update the rate limit intervals when
>     new console is attached. Note that the ratelimits might
>     get initialized early during boot. It might be solvable
>     but ...
> 
>   + You might need to update the length of the message
>     when the text (code) is updated. It might be hard
>     to maintain.

I assumed we calculate the average dynamically, for the amount of
messages printed by an OOM event is highly unstable (depends on
hardware configuration such as number of nodes, number of zones,
and how many processes are there as a candidate for OOM victim).

> 
>   + You would need to take into account also console_level
>     and the level of the printed messages

Isn't that counted by call_console_drivers() ?

> 
>   + This approach does not take into account all other
>     messages that might be printed by other subsystems.

Yes. And I wonder whether unlimited printk() alone is the cause of RCU
stalls. I think that printk() is serving as an amplifier for any CPU users.
That is, the average speed might not be safe enough to guarantee that RCU
stalls won't occur. Then, there is no safe average value we can use.

> 
> 
> I have just talked with Michal in person. He pointed out
> that we primary need to know when and if the last printed
> message already reached the console.

I think we can estimate when call_console_drivers() started/completed for
the last time as when and if the last printed message already reached the
console. Sometimes callers might append to the logbuf without waiting for
completion of call_console_drivers(), but the system is already unusable
if majority of ratelimited printk() users hit that race window.

> 
> A solution might be to handle printk and ratelimit together.
> For example:
> 
>    + store log_next_idx of the printed message into
>      the ratelimit structure
> 
>    + eventually store pointer of the ratelimit structure
>      into printk_log
> 
>    + eventually store the timestamp when the message
>      reached the console into the ratelimit structure
> 
> Then the ratelimited printk might take into acount whether
> the previous message already reached console and even when.

If printk() becomes asynchronous (e.g. printk() kernel thread), we would
need to use something like srcu_synchronize() so that the caller waits for
only completion of messages the caller wants to wait.

> 
> 
> Well, this is still rather complex. I am not persuaded that
> it is worth it.
> 
> I suggest to take a breath, stop looking for a perfect solution
> for a bit. The existing ratelimit might be perfectly fine
> in practice. You might always create stress test that would
> fail but the test might be far from reality. Any complex
> solution might bring more problems that solve.
> 
> Console full of repeated messages need not be a catastrophe
> when it helps to fix the problem and the system is usable
> and need a reboot anyway.

I wish that memcg OOM events do not use printk(). Since memcg OOM is not
out of physical memory, we can dynamically allocate physical memory for
holding memcg OOM messages and let the userspace poll it via some interface.

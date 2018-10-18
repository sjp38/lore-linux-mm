Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6934E6B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 07:59:23 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id k9-v6so27561046iob.16
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 04:59:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t87-v6si1426435jad.79.2018.10.18.04.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 04:59:21 -0700 (PDT)
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
 <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
 <20181018061018.GB650@jagdpanzerIV> <20181018075611.GY18839@dhcp22.suse.cz>
 <20181018081352.GA438@jagdpanzerIV>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <2c2b2820-e6f8-76c8-c431-18f60845b3ab@i-love.sakura.ne.jp>
Date: Thu, 18 Oct 2018 20:58:53 +0900
MIME-Version: 1.0
In-Reply-To: <20181018081352.GA438@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On 2018/10/18 17:13, Sergey Senozhatsky wrote:
> On (10/18/18 09:56), Michal Hocko wrote:
>> On Thu 18-10-18 15:10:18, Sergey Senozhatsky wrote:
>> [...]
>>> and let's hear from MM people what they can suggest.
>>>
>>> Michal, Andrew, Johannes, any thoughts?
>>
>> I have already stated my position. Let's not reinvent the wheel and use
>> the standard printk throttling. If there are cases where oom reports
>> cause more harm than good I am open to add a knob to allow disabling it
>> altogether (it can be even fine grained one to control whether to dump
>> show_mem, task_list etc.).

Moderate OOM reports with making progress is good.
But OOM reports without making progress is bad.

> 
> A knob might do.
> As well as /proc/sys/kernel/printk tweaks, probably. One can even add
> echo "a b c d" > /proc/sys/kernel/printk to .bashrc and adjust printk
> console levels on login and rollback to old values in .bash_logout
> May be.

That can work for only single login with root user case.
Not everyone logs into console as root user.

It is pity that we can't send kernel messages to only selected consoles
(e.g. all messages are sent to netconsole, but only critical messages are
sent to local consoles).

> 
>> But please let's stop this dubious one-off approaches.
> 
> OK. Well, I'm not proposing anything actually. I didn't even
> realize until recently that Tetsuo was talking about "user
> interaction" problem; I thought that his problem was stalled
> RCU.

The "stalled RCU" was the trigger for considering this problem.
Nobody has seriously considered what we should do when the memcg OOM killer
cannot make progress. If the OOM killer cannot make progress, we need to
handle situations where the OOM-unkillable process cannot solve the memcg OOM
situation. Then, the poorest recovery method is that the root user enters
commands for recovery (It might be to increase the memory limit. It might be
to move to a different cgroup. It might be to gracefully terminate the
OOM-unkillable process.) from "consoles" where the OOM messages are sent.

If we start from the worst case, it is obvious that we need to make sure that
the OOM messages do not disturb "consoles" so that the root user can enter
commands for recovery. That boils down to a "user interaction" problem.
Not limiting

  "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
  "Out of memory and no killable processes...\n"

is very annoying.

And I really can't understand why Michal thinks "handling this requirement" as
"make the code more complex than necessary and squash different things together".
Satisfying the most difficult error path handling is not a simple thing.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3BD6B0003
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 06:36:25 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id d12-v6so2081711iof.10
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 03:36:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e10-v6si592009iog.67.2018.10.19.03.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 03:36:23 -0700 (PDT)
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
 <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
 <20181018061018.GB650@jagdpanzerIV> <20181018075611.GY18839@dhcp22.suse.cz>
 <20181018081352.GA438@jagdpanzerIV>
 <2c2b2820-e6f8-76c8-c431-18f60845b3ab@i-love.sakura.ne.jp>
 <20181018235427.GA877@jagdpanzerIV>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <5d472476-7852-f97b-9412-63536dffaa0e@i-love.sakura.ne.jp>
Date: Fri, 19 Oct 2018 19:35:53 +0900
MIME-Version: 1.0
In-Reply-To: <20181018235427.GA877@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On 2018/10/19 8:54, Sergey Senozhatsky wrote:
> On (10/18/18 20:58), Tetsuo Handa wrote:
>>>
>>> A knob might do.
>>> As well as /proc/sys/kernel/printk tweaks, probably. One can even add
>>> echo "a b c d" > /proc/sys/kernel/printk to .bashrc and adjust printk
>>> console levels on login and rollback to old values in .bash_logout
>>> May be.
>>
>> That can work for only single login with root user case.
>> Not everyone logs into console as root user.
> 
> Add sudo ;)

That will not work. ;-) As long as the console loglevel setting is
system wide, we can't allow multiple login sessions.

> 
>> It is pity that we can't send kernel messages to only selected consoles
>> (e.g. all messages are sent to netconsole, but only critical messages are
>> sent to local consoles).
> 
> OK, that's a fair point. There was a patch from FB, which would allow us
> to set a log_level on per-console basis. So the noise goes to heav^W net
> console; only critical stuff goes to the serial console (if I recall it
> correctly). I'm not sure what happened to that patch, it was a while ago.
> I'll try to find that out.

Per a console loglevel setting would help for several environments.
But syzbot environment cannot count on netconsole. We can't expect that
unlimited printk() will become safe.

> 
> [..]
>> That boils down to a "user interaction" problem.
>> Not limiting
>>
>>   "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
>>   "Out of memory and no killable processes...\n"
>>
>> is very annoying.
>>
>> And I really can't understand why Michal thinks "handling this requirement" as
>> "make the code more complex than necessary and squash different things together".
> 
> Michal is trying very hard to address the problem in a reasonable way.

OK. But Michal, do we have a reasonable way which can be applied now instead of
my patch or one of below patches? Just enumerating words like "hackish" or "a mess"
without YOU ACTUALLY PROPOSE PATCHES will bounce back to YOU.

> The problem you are talking about is not MM specific. You can have a
> faulty SCSI device, corrupted FS, and so and on.

"a faulty SCSI device, corrupted FS, and so and on" are reporting problems
which will complete a request. They can use (and are using) ratelimit,
aren't they?

"a memcg OOM with no eligible task" is reporting a problem which cannot
complete a request. But it can use ratelimit as well.

But we have an immediately applicable mitigation for a problem that
already OOM-killed threads are triggering "a memcg OOM with no eligible
task" using one of below patches.

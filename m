Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6648D6B026D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:36:51 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id m123-v6so5291060ith.5
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:36:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i14-v6sor6435372iog.98.2018.10.10.05.36.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 05:36:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZfVdeB-WNeLCWJvTHNeCUtR3r1R+3Qjv9XjZXPxaV2WA@mail.gmail.com>
References: <000000000000dc48d40577d4a587@google.com> <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <20181010085945.GC5873@dhcp22.suse.cz> <e72f799e-0634-f958-1af0-291f8577f4e8@i-love.sakura.ne.jp>
 <20181010113500.GH5873@dhcp22.suse.cz> <20181010114833.GB3949@tigerII.localdomain>
 <20181010122539.GI5873@dhcp22.suse.cz> <CACT4Y+ZfVdeB-WNeLCWJvTHNeCUtR3r1R+3Qjv9XjZXPxaV2WA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 10 Oct 2018 14:36:29 +0200
Message-ID: <CACT4Y+bqJeKum7jessccWQF+4BmabnVy48aqHEOypioKwQAMTQ@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in shmem_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Yang Shi <yang.s@alibaba-inc.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>

On Wed, Oct 10, 2018 at 2:29 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Oct 10, 2018 at 2:25 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> On Wed 10-10-18 20:48:33, Sergey Senozhatsky wrote:
>>> On (10/10/18 13:35), Michal Hocko wrote:
>>> > > Just flooding out of memory messages can trigger RCU stall problems.
>>> > > For example, a severe skbuff_head_cache or kmalloc-512 leak bug is causing
>>> >
>>> > [...]
>>> >
>>> > Quite some of them, indeed! I guess we want to rate limit the output.
>>> > What about the following?
>>>
>>> A bit unrelated, but while we are at it:
>>>
>>>   I like it when we rate-limit printk-s that lookup the system.
>>> But it seems that default rate-limit values are not always good enough,
>>> DEFAULT_RATELIMIT_INTERVAL / DEFAULT_RATELIMIT_BURST can still be too
>>> verbose. For instance, when we have a very slow IPMI emulated serial
>>> console -- e.g. baud rate at 57600. DEFAULT_RATELIMIT_INTERVAL and
>>> DEFAULT_RATELIMIT_BURST can add new OOM headers and backtraces faster
>>> than we evict them.
>>>
>>> Does it sound reasonable enough to use larger than default rate-limits
>>> for printk-s in OOM print-outs? OOM reports tend to be somewhat large
>>> and the reported numbers are not always *very* unique.
>>>
>>> What do you think?
>>
>> I do not really care about the current inerval/burst values. This change
>> should be done seprately and ideally with some numbers.
>
> I think Sergey meant that this place may need to use
> larger-than-default values because it prints lots of output per
> instance (whereas the default limit is more tuned for cases that print
> just 1 line).
>
> I've found at least 1 place that uses DEFAULT_RATELIMIT_INTERVAL*10:
> https://elixir.bootlin.com/linux/latest/source/fs/btrfs/extent-tree.c#L8365
> Probably we need something similar here.


In parallel with the kernel changes I've also made a change to
syzkaller that (1) makes it not use oom_score_adj=-1000, this hard
killing limit looks like quite risky thing, (2) increase memcg size
beyond expected KASAN quarantine size:
https://github.com/google/syzkaller/commit/adedaf77a18f3d03d695723c86fc083c3551ff5b
If this will stop the flow of hang/stall reports, then we can just
close all old reports as invalid.

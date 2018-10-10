Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D67F6B0010
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:17:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o18-v6so3713292pgv.14
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:17:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h21-v6sor19297728pgb.10.2018.10.10.08.17.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 08:17:42 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Thu, 11 Oct 2018 00:17:29 +0900
Subject: Re: INFO: rcu detected stall in shmem_fault
Message-ID: <20181010151729.GC3949@tigerII.localdomain>
References: <000000000000dc48d40577d4a587@google.com>
 <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <20181010085945.GC5873@dhcp22.suse.cz>
 <e72f799e-0634-f958-1af0-291f8577f4e8@i-love.sakura.ne.jp>
 <20181010113500.GH5873@dhcp22.suse.cz>
 <20181010114833.GB3949@tigerII.localdomain>
 <20181010122539.GI5873@dhcp22.suse.cz>
 <CACT4Y+ZfVdeB-WNeLCWJvTHNeCUtR3r1R+3Qjv9XjZXPxaV2WA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZfVdeB-WNeLCWJvTHNeCUtR3r1R+3Qjv9XjZXPxaV2WA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Yang Shi <yang.s@alibaba-inc.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>

On (10/10/18 14:29), Dmitry Vyukov wrote:
> >> A bit unrelated, but while we are at it:
> >>
> >>   I like it when we rate-limit printk-s that lookup the system.
> >> But it seems that default rate-limit values are not always good enough,
> >> DEFAULT_RATELIMIT_INTERVAL / DEFAULT_RATELIMIT_BURST can still be too
> >> verbose. For instance, when we have a very slow IPMI emulated serial
> >> console -- e.g. baud rate at 57600. DEFAULT_RATELIMIT_INTERVAL and
> >> DEFAULT_RATELIMIT_BURST can add new OOM headers and backtraces faster
> >> than we evict them.
> >>
> >> Does it sound reasonable enough to use larger than default rate-limits
> >> for printk-s in OOM print-outs? OOM reports tend to be somewhat large
> >> and the reported numbers are not always *very* unique.
> >>
> >> What do you think?
> >
> > I do not really care about the current inerval/burst values. This change
> > should be done seprately and ideally with some numbers.
> 
> I think Sergey meant that this place may need to use
> larger-than-default values because it prints lots of output per
> instance (whereas the default limit is more tuned for cases that print
> just 1 line).
> 
> I've found at least 1 place that uses DEFAULT_RATELIMIT_INTERVAL*10:
> https://elixir.bootlin.com/linux/latest/source/fs/btrfs/extent-tree.c#L8365
> Probably we need something similar here.

Yes, Dmitry, that's what I meant - to use something like
DEFAULT_RATELIMIT_INTERVAL * 10 in OOM. I didn't mean to change
the default values system wide.

---

We are not rate-limiting a single annoying printk() in OOM, but
functions that do a whole bunch of printks - OOM header, backtraces, etc.
Thus OOM report can be, I don't know, 50 or 70 or 100 lines (who knows).
So that's why rate-limit in OOM is more permissive in terms of number of
printed lines. When we rate-limit a single printk() we let 10 prinks()
/*10 lines*/ max every 5 seconds. While in OOM this transforms into
10 dump_header() + 10 oom_kill_process() every 5 seconds. Still can be
too many printk()-s, enough to lockup the system.

	-ss

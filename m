Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 52EAA6B04A6
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 14:07:23 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k192so144803951ith.0
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:07:23 -0700 (PDT)
Received: from mail-it0-x230.google.com (mail-it0-x230.google.com. [2607:f8b0:4001:c0b::230])
        by mx.google.com with ESMTPS id k101si11396707ioi.140.2017.07.10.11.07.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 11:07:22 -0700 (PDT)
Received: by mail-it0-x230.google.com with SMTP id v202so41164179itb.0
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:07:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170710125935.GL23069@pathway.suse.cz>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp>
 <20170707023601.GA7478@jagdpanzerIV.localdomain> <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
 <20170710125935.GL23069@pathway.suse.cz>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Mon, 10 Jul 2017 20:07:21 +0200
Message-ID: <CAKMK7uGQ9NgS3rTieqqop-2o7sWUv8QuG_DNkJn42iPyBkEeiw@mail.gmail.com>
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM
 memory allocations?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko <mhocko@kernel.org>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Andreas Mohr <andi@lisas.de>, Jan Kara <jack@suse.cz>, dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>

On Mon, Jul 10, 2017 at 2:59 PM, Petr Mladek <pmladek@suse.com> wrote:
> On Sat 2017-07-08 22:30:47, Tetsuo Handa wrote:
>> What I want to mention here is that messages which were sent to printk()
>> were not printed to not only /dev/tty0 but also /dev/ttyS0 (I'm passing
>> "console=ttyS0,115200n8 console=tty0" to kernel command line.) I don't care
>> if output to /dev/tty0 is delayed, but I expect that output to /dev/ttyS0
>> is not delayed, for I'm anayzing things using printk() output sent to serial
>> console (serial.log in my VMware configuration). Hitting this problem when we
>> cannot allocate memory results in failing to save printk() output. Oops, it
>> is sad.
>
> Would it be acceptable to remove "console=tty0" parameter and push
> the messages only to the serial console?
>
> Also there is the patchset from Peter Zijlstra that allows to
> use early console all the time, see
> https://lkml.kernel.org/r/20161018170830.405990950@infradead.org
>
>
> The current code flushes each line to all enabled consoles one
> by one. If there is a deadlock in one console, everything
> gets blocked.
>
> We are trying to make printk() more robust. But it is much more
> complicated than we anticipated. Many changes open another can
> of worms. It seems to be a job for years.
>
>
>> Hmm... should we consider addressing console_sem problem before
>> introducing printing kernel thread and offloading to that kernel thread?
>
> As Sergey said, the console rework seems to be much bigger task
> than introducing the kthread.
>
> Also if we would want to handle each console separately (as a
> fallback) it would be helpful to have separate kthread for each
> enabled console or for the less reliable consoles at least.

Since the console-loggin-in-kthread comes up routinely, and equally
often people say "but I dont want to make my serial console delayed":
Should we make kthread-based printk a per-console opt-in? fbcon and
other horror shows with deep nesting of entire subsystems and their
locking hierarchy would do that. Truly simple console drivers like
serial or maybe logging to some firmware/platform service for recovery
after rebooting would not.

Of course we'd also need one kthread per console, and we'd need to
have at least some per-console locking (plus an overall console lock
on top for both registering/unregistering consoles and all the legacy
users like fbdev that need much more work to untangle). We could even
restrict the per-console locking (i.e. those which can go ahead while
someone else is holding the main or other console_locks) just for
those console drivers which do not use a kthread, to cut down the
audit burden to something manageable.

Just my 2 cents, thrown in from the sideline.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 163CB6B04A5
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 08:59:39 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l34so23982153wrc.12
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 05:59:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y64si8015323wrc.160.2017.07.10.05.59.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 05:59:37 -0700 (PDT)
Date: Mon, 10 Jul 2017 14:59:35 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM
 memory allocations?
Message-ID: <20170710125935.GL23069@pathway.suse.cz>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp>
 <20170707023601.GA7478@jagdpanzerIV.localdomain>
 <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky.work@gmail.com, sergey.senozhatsky@gmail.com, mhocko@kernel.org, pavel@ucw.cz, rostedt@goodmis.org, andi@lisas.de, jack@suse.cz, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, daniel.vetter@ffwll.ch

On Sat 2017-07-08 22:30:47, Tetsuo Handa wrote:
> What I want to mention here is that messages which were sent to printk()
> were not printed to not only /dev/tty0 but also /dev/ttyS0 (I'm passing
> "console=ttyS0,115200n8 console=tty0" to kernel command line.) I don't care
> if output to /dev/tty0 is delayed, but I expect that output to /dev/ttyS0
> is not delayed, for I'm anayzing things using printk() output sent to serial
> console (serial.log in my VMware configuration). Hitting this problem when we
> cannot allocate memory results in failing to save printk() output. Oops, it
> is sad.

Would it be acceptable to remove "console=tty0" parameter and push
the messages only to the serial console?

Also there is the patchset from Peter Zijlstra that allows to
use early console all the time, see
https://lkml.kernel.org/r/20161018170830.405990950@infradead.org


The current code flushes each line to all enabled consoles one
by one. If there is a deadlock in one console, everything
gets blocked.

We are trying to make printk() more robust. But it is much more
complicated than we anticipated. Many changes open another can
of worms. It seems to be a job for years.


> Hmm... should we consider addressing console_sem problem before
> introducing printing kernel thread and offloading to that kernel thread?

As Sergey said, the console rework seems to be much bigger task
than introducing the kthread.

Also if we would want to handle each console separately (as a
fallback) it would be helpful to have separate kthread for each
enabled console or for the less reliable consoles at least.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

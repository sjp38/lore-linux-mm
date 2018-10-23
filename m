Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4C3C6B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 20:47:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b7-v6so30800593pgt.10
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 17:47:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b66-v6sor18256907pfm.43.2018.10.22.17.47.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 17:47:31 -0700 (PDT)
Date: Tue, 23 Oct 2018 09:47:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181023004726.GA4612@jagdpanzerIV>
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
 <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
 <20181018061018.GB650@jagdpanzerIV>
 <20181018075611.GY18839@dhcp22.suse.cz>
 <20181018081352.GA438@jagdpanzerIV>
 <2c2b2820-e6f8-76c8-c431-18f60845b3ab@i-love.sakura.ne.jp>
 <20181018235427.GA877@jagdpanzerIV>
 <5d472476-7852-f97b-9412-63536dffaa0e@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5d472476-7852-f97b-9412-63536dffaa0e@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, Calvin Owens <calvinowens@fb.com>

On (10/19/18 19:35), Tetsuo Handa wrote:
> > 
> > OK, that's a fair point. There was a patch from FB, which would allow us
> > to set a log_level on per-console basis. So the noise goes to heav^W net
> > console; only critical stuff goes to the serial console (if I recall it
> > correctly). I'm not sure what happened to that patch, it was a while ago.
> > I'll try to find that out.
> 
> Per a console loglevel setting would help for several environments.
> But syzbot environment cannot count on netconsole. We can't expect that
> unlimited printk() will become safe.

This target is moving too fast :) RCU stall -> user interaction -> syzbot

I talked to Calvin Owens (who's working on the per-console loglevel
patch set; CC-ed) and Calvin said that "It's in-progress". So we probably
will have this functionality one day. That's all we can do from printk
side wrt user-interaction problem.

> > The problem you are talking about is not MM specific. You can have a
> > faulty SCSI device, corrupted FS, and so and on.
> 
> "a faulty SCSI device, corrupted FS, and so and on" are reporting problems
> which will complete a request. They can use (and are using) ratelimit,
> aren't they?

Looking at scsi_request_fn(), the answer is probably "sure they can;
but no, they aren't". In majority of cases the reason we replace printk
with printk_ratelimit is because someone reports a stall or a lockup.
Otherwise, people use printk(), which is absolutely fine.

	-ss

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C66FF6B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 11:29:08 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id p4so11195775wrf.4
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 08:29:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 132si11399600wmj.259.2018.01.10.08.29.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 08:29:07 -0800 (PST)
Date: Wed, 10 Jan 2018 17:29:00 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110162900.GA21753@linux.suse>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed 2018-01-10 06:05:47, Tejun Heo wrote:
> On Wed, Jan 10, 2018 at 02:24:16PM +0100, Petr Mladek wrote:
> > This is the last version of Steven's console owner/waiter logic.
> > Plus my proposal to hide it into 3 helper functions. It is supposed
> > to keep the code maintenable.
> > 
> > The handshake really works. It happens about 10-times even during
> > boot of a simple system in qemu with a fast console here. It is
> > definitely able to avoid some softlockups. Let's see if it is
> > enough in practice.
> > 
> > From my point of view, it is ready to go into linux-next so that
> > it can get some more test coverage.
> > 
> > Steven's patch is the v4, see
> > https://lkml.kernel.org/r/20171108102723.602216b1@gandalf.local.home
> 
> At least for now,
> 
>  Nacked-by: Tejun Heo <tj@kernel.org>
> 
> Maybe this can be a part of solution but it's really worrying how the
> whole discussion around this subject is proceeding.  You guys are
> trying to railroad actual problems.  Please address actual technical
> problems.

I wonder how long you follow the discussions about solving this
problem. I was able to find one old solution from Jan Kara that
was sent on January 15, 2013. You might google it by
"[PATCH] printk: Avoid softlockups in console_unlock()". For example,
it is archived at
http://linux-kernel.2935.n7.nabble.com/PATCH-printk-Avoid-softlockups-in-console-unlock-td581957.html

The historic Jan Kara's solution is actually very similar to your proposal at
https://lkml.kernel.org/r/20171102135258.GO3252168@devbig577.frc2.facebook.com

Why Jan Kara's Solution was not accepted?
Was it because he was not trying enough?

No, Jan provided several variants (based on workqueues, irqwork,
kthread), for example
https://lkml.kernel.org/r/1395770101-24534-1-git-send-email-jack@suse.cz
Also he discussed this on conferences, etc.

Later Jan handed over the fight to Sergey Senozhatsky, see
https://lkml.kernel.org/r/1457175338-1665-1-git-send-email-sergey.senozhatsky@gmail.com

Also Sergey was very active. He was addressing many issues, discussed
this on Kernel Summit twice.

Why is it not upstream?

All attempts up to v12 were blocked by someone (Andrew, Linus,
Pavel Machek, few others) because they did not guarantee enough
that the kthread would wake up and they would be able to see
the messages!

Sergey tried to address this by forcing synchronous mode in
some situations (panic, suspend, kexec, ...). But people
still complained.

One important milestone was v12, see
https://lkml.kernel.org/r/20160513131848.2087-1-sergey.senozhatsky@gmail.com
It was the last version where we did the offload immediately from
vprintk_emit().

The next versions used lazy offload from console_unlock() when
the thread spent there too much time. IMHO, this is one
very promising solution. It guarantees that softlockup
would never happen. But it tries hard to get the messages
out immediately.

Unfortunately, it is very complicated. We have troubles to understand
the concerns, for example see the long discussion about v3 at
https://lkml.kernel.org/r/20170509082859.854-1-sergey.senozhatsky@gmail.com
I admit that I did not have enough time to review this.


Anyway, in October, 2017, Steven came up with a completely
different approach (console owner/waiter transfer). It does
not guarantee that the softlockup will not happen. But it
does not suffer from the problem that blocked the obvious
solution for years. It moves the owner at runtime, so
it is guaranteed that the new owner would continue
printing.



Finally, no solution is perfect! There are contradicting requirements
on printk:

	get the messages out ASAP
               vs.
	do not block the system

The harder you try to get the messages out the more you could block
the entire system.

Where is the acceptable compromise? I am not sure. So far, the most
forceful people (Linus) did not see softlockups as a big problem.
They rather wanted to see the messages.


What could we do?

   + offload  -> not acceptable so far
   + lazy offload -> might be acceptable if done more easily or gets
		review

   + try to transfer console owner (Steven) -> helps in several
         situations, so far only hand made stress code failed

   + reduce amount of messages
         + does it make sense to print the same warning 1000-times?
         + could one long warning cause softlockup with the console
	   owner transfer?

   + throttle thread producing too many messages
         + IMHO, very good solution but nobody investigated it


This patchset really helps in many situations. I believe that it
does not make things worse. You might block it and spend another
long time discussing other solutions.

Will we need a better solution? Maybe, probably.

Is it possible to provide an acceptable solution using offload?
Probably using lazy offload. In a reasonable time frame with
a comparably low risk? Me not.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

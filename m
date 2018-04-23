Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B26C46B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 01:21:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b16so9607658pfi.5
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 22:21:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j193sor2653913pgc.62.2018.04.22.22.21.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 22:21:39 -0700 (PDT)
Date: Mon, 23 Apr 2018 14:21:33 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180423052133.GA3643@jagdpanzerIV>
References: <20180413124704.19335-1-pmladek@suse.com>
 <20180413101233.0792ebf0@gandalf.local.home>
 <20180414023516.GA17806@tigerII.localdomain>
 <20180416014729.GB1034@jagdpanzerIV>
 <20180416042553.GA555@jagdpanzerIV>
 <20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
 <20180420021511.GB6397@jagdpanzerIV>
 <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (04/20/18 11:12), Petr Mladek wrote:
[..]
> Will 1000 lines within 1 hour be enough for you, please?

I'm afraid it won't.

> I am lost. In the mail
[..]
> My understanding of the older mail is that you called
> console_drivers() in printk_safe() context only because it was
> easier to disable printk_safe context later together with
> enabling irqs.

Correct.

> My understanding of today's mail is that it is important
> to call console drivers in printk_safe() context.

No, I don't think that it is what I said.

> It is a contradiction. Could you please explain?

Let me try again.

call_console_drivers() is super complex, unbelievable complex. In fact,
it's so complex that we never know where we will end up, because it can
pass the control to almost every core kernel mechanism or subsystem:
kobjects, spin locks, tty, sdp, uart, vt, fbdev, dri, kms, timers,
timekeeping, networking, mm, scheduler, you name it. Thousands and
thousands lines of code, which are not executed exclusively by the
console drivers. That core kernel code that we are dealing with has its
own fault/error reporting mechanisms, some of which comes in forms of
WARN_ON()-s or printk()-s, or dump_stack()-s, or BUG_ON()-s and so on.

Now, for many, many years printk()-s from console_unlock()->call_console_driver()
were absolutely legal and fine. And it was useful, and helpful mechanism,
and that's why people used it (and continue to do so). A very quick
googling:
	https://bugzilla.altlinux.org/attachment.cgi?id=5811
or
	https://access.redhat.com/solutions/702533
or
	https://bugzilla.redhat.com/attachment.cgi?id=561164
or
	https://lists.gt.net/linux/kernel/2341113
or
	https://www.systutorials.com/linux-kernels/56987/ib-mlx4-reduce-sriov-multicast-cleanup-warning-message-to-debug-level-linux-4-10-17/
or
	https://github.com/raspberrypi/linux/issues/663
or
	https://bugs.openvz.org/browse/VZWEB-36
or
  any other bug report which involves console_unlock()->call_console_drivers(),
there are *tons* of them. And the reason why those printk()-s were, and
they still are, legal was [and is] because those printk()-s were [and are]
harmless - they didn't [don't] deadlock the system. [not to mention VT, console
drivers, etc. debugging]. Throttling down that error mechanism to 100 lines
per hour, or 1000 lines per hour is unlikely will be welcomed.

When we introduced printk_safe() we had a completely different goal.
printk_safe() did not make call_console_drivers() any safer. Because
printk_safe() has *nothing* to do with console drivers or the underlying
code. The only thing that has changed on the console_drivers side with
the introduction of printk_safe() was that we enabled lockdep, and thus
RCU sanity checks, in printk() and console_drivers. So we just opened up
one more error reporting channel - a small, but very important, addition
to already existing numerous error reporting printk()-s, dump_stack()-s
which call_console_drivers()->foo() can trigger. And that additional
console_drivers error reporting channel works really well for us:
	http://lkml.kernel.org/r/20170928120405.18273-1-sergey.senozhatsky@gmail.com
or
	http://lkml.kernel.org/r/20170217015932.11898-1-sergey.senozhatsky@gmail.com
or
	lkml.kernel.org/r/alpine.LFD.2.20.1703201736070.1753@schleppi
or
	so on. We have a number of those "additional" reports.

When it comes to call_console_drivers() neither lockdep nor RCU need
printk_safe(). Because console_unlock()->call_console_drivers()->printk()
is totally normal, legal, fine, and has been around for years. We need
printk_safe() because of the way vprintk_emit() works - we protect logbuf
spin_lock and console_sem spin_lock with print_safe, -- not because of the
console_drivers [which don't deal with logbuf or console_sem to begin
with]. In other words, printk_safe() is *irrelevant* when it comes to
console drivers.

If we continue calling console_drivers under printk_safe(), and I don't
think that we should do so [I said it several times], then it is *absolutely*
important to keep it as permissive as possible [I also said it several times].
But let me be crystal clear - we better stop calling console_drivers under
printk_safe, it is pointless, useless and introduces unneeded IRQ->work->flush
dependency. It is also my believe that printk()-s from call_console_drivers()
must stay "un-throttled", exactly the way there were [and they are] for years.
Otherwise, we simply will "secretly" and "suprisingly" turn a HUGE number of
printk()-s, dump_stack(), WARN_ON()-s, etc. in sched, net, mm, tty, fbdev, vt,
you name it, into rate-limited printk() for no reason. We will shut up quite a
number of valid, useful and important error reporting channels. This does look
and smell like a massive, massive regression.

Basically, from the vt, tty, timekeeping, sched, net, mm, you name it,
prospective, what we do is:

---

 kernel/printk/printk.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 247808333ba4..8df861e6e0a3 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1828,6 +1828,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 			    const char *dict, size_t dictlen,
 			    const char *fmt, va_list args)
 {
+	static DEFINE_RATELIMIT_STATE(ratelimit_console, 60 * 60 * HZ, 100);
 	static char textbuf[LOG_LINE_MAX];
 	char *text = textbuf;
 	size_t text_len;
@@ -1836,6 +1837,9 @@ asmlinkage int vprintk_emit(int facility, int level,
 	int printed_len;
 	bool in_sched = false;
 
+	if (!__ratelimit(&ratelimit_console))
+		return 0;
+
 	if (level == LOGLEVEL_SCHED) {
 		level = LOGLEVEL_DEFAULT;
 		in_sched = true;

---

It is really so.

What part of this plan works for us?

Among all the patches and proposal that we saw so far, one stands out - it's
the original Tejun's patch [offloading to work queue]. Because it has zero
interference with the existing call_console_drivers()->printk() channels.
Whatever comes from any of the underlying subsystems [networking, vt, mm,
you name it] comes for a reason, we should not blindly and boldly discard
those messages. And I really love that part of Tejun's patch.

But let's think about it - we haven't even looked at the messages that are
supposedly killing Tejun's boxes. We can't be serious now. We don't even
know what we are dealing with, we don't even know what [and why] the kernel
was reporting to us. We should have looked at the logs in the first place,
and probably consider some rate-limiting in the misbehaving code, like we
always do.

What is so special about this case that we decided to screw up printk()
instead?

So I'm going to volunteer and I'm willing to take a look at the logs
(hopefully Tejun can send some).

I think that we need to apply the patch below.
That call_console_drivers()->printk->IRQ_work->irq->flush appears to be
pointless.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 kernel/printk/printk.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 247808333ba4..484c456c095a 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -2385,9 +2385,11 @@ void console_unlock(void)
 		 */
 		console_lock_spinning_enable();
 
+		__printk_safe_exit();
 		stop_critical_timings();	/* don't trace print latency */
 		call_console_drivers(ext_text, ext_len, text, len);
 		start_critical_timings();
+		__printk_safe_enter();
 
 		if (console_lock_spinning_disable_and_check()) {
 			printk_safe_exit_irqrestore(flags);
-- 
2.17.0

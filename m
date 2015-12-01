Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 119476B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 08:04:10 -0500 (EST)
Received: by wmvv187 with SMTP id v187so205570877wmv.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 05:04:09 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id pc1si73556148wjb.243.2015.12.01.05.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 05:04:08 -0800 (PST)
Date: Tue, 1 Dec 2015 14:04:04 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [BISECTED] rcu_sched self-detected stall since 3.17
Message-ID: <20151201130404.GL3816@twins.programming.kicks-ass.net>
References: <564F3DCA.1080907@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564F3DCA.1080907@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: linux-kernel@vger.kernel.org, neilb@suse.de, oleg@redhat.com, mark.rutland@arm.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Sorry for the delay and thanks for the reminder!

On Fri, Nov 20, 2015 at 03:35:38PM +0000, Vladimir Murzin wrote:
> commit 743162013d40ca612b4cb53d3a200dff2d9ab26e
> Author: NeilBrown <neilb@suse.de>
> Date:   Mon Jul 7 15:16:04 2014 +1000
> 
>     sched: Remove proliferation of wait_on_bit() action functions
> 
> The only change I noticed is from (mm/filemap.c)
> 
> 	io_schedule();
> 	fatal_signal_pending(current)
> 
> to (kernel/sched/wait.c)
> 
> 	signal_pending_state(current->state, current)
> 	io_schedule();
> 
> and if I apply following diff I don't see stalls anymore.
> 
> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index a104879..2d68cdb 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -514,9 +514,10 @@ EXPORT_SYMBOL(bit_wait);
> 
>  __sched int bit_wait_io(void *word)
>  {
> +       io_schedule();
> +
>         if (signal_pending_state(current->state, current))
>                 return 1;
> -       io_schedule();
>         return 0;
>  }
>  EXPORT_SYMBOL(bit_wait_io);
> 
> Any ideas why it might happen and why diff above helps?

Yes, the code as presented is simply wrong. And in fact most of the code
it replaced was of the right form (with a few exceptions which would
indeed have been subject to the same problem you've observed.

Note how the late:

  - cifs_sb_tcon_pending_wait
  - fscache_wait_bit_interruptible
  - sleep_on_page_killable
  - wait_inquiry
  - key_wait_bit_intr

All check the signal state _after_ calling schedule().

As opposed to:

  - gfs2_journalid_wait

which follows the broken pattern.

Further notice that most expect a return of -EINTR, which also seems
correct given that this is a signal, those that do not return -EINTR
only check for a !0 return value so would work equally well with -EINTR.

The reason this is broken is that schedule() will no-op when there is a
pending signal, while raising a signal will also issue a wakeup.

Thus the right thing to do is check for the signal state after, that way
you handle both cases:

 - calling schedule() with a signal pending
 - receiving a signal while sleeping

As such, I would propose the below patch. Oleg, do you concur?

---
Subject: sched,wait: Fix signal handling in bit wait helpers

Vladimir reported getting RCU stall warnings and bisected it back to
commit 743162013d40. That commit inadvertently reversed the calls to
schedule() and signal_pending(), thereby not handling the case where the
signal receives while we sleep.

Fixes: 743162013d40 ("sched: Remove proliferation of wait_on_bit() action functions")
Fixes: cbbce8220949 ("SCHED: add some "wait..on_bit...timeout()" interfaces.")
Reported-by: Vladimir Murzin <vladimir.murzin@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 kernel/sched/wait.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 052e02672d12..f10bd873e684 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -583,18 +583,18 @@ EXPORT_SYMBOL(wake_up_atomic_t);
 
 __sched int bit_wait(struct wait_bit_key *word)
 {
-	if (signal_pending_state(current->state, current))
-		return 1;
 	schedule();
+	if (signal_pending(current))
+		return -EINTR;
 	return 0;
 }
 EXPORT_SYMBOL(bit_wait);
 
 __sched int bit_wait_io(struct wait_bit_key *word)
 {
-	if (signal_pending_state(current->state, current))
-		return 1;
 	io_schedule();
+	if (signal_pending(current))
+		return -EINTR;
 	return 0;
 }
 EXPORT_SYMBOL(bit_wait_io);
@@ -602,11 +602,11 @@ EXPORT_SYMBOL(bit_wait_io);
 __sched int bit_wait_timeout(struct wait_bit_key *word)
 {
 	unsigned long now = READ_ONCE(jiffies);
-	if (signal_pending_state(current->state, current))
-		return 1;
 	if (time_after_eq(now, word->timeout))
 		return -EAGAIN;
 	schedule_timeout(word->timeout - now);
+	if (signal_pending(current))
+		return -EINTR;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(bit_wait_timeout);
@@ -614,11 +614,11 @@ EXPORT_SYMBOL_GPL(bit_wait_timeout);
 __sched int bit_wait_io_timeout(struct wait_bit_key *word)
 {
 	unsigned long now = READ_ONCE(jiffies);
-	if (signal_pending_state(current->state, current))
-		return 1;
 	if (time_after_eq(now, word->timeout))
 		return -EAGAIN;
 	io_schedule_timeout(word->timeout - now);
+	if (signal_pending(current))
+		return -EINTR;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(bit_wait_io_timeout);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

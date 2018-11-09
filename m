Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46D4E6B06C6
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 04:56:02 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 30so778554ota.15
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 01:56:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r7-v6si3203723oib.5.2018.11.09.01.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 01:56:00 -0800 (PST)
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
 <20181109061204.GC599@jagdpanzerIV>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
Date: Fri, 9 Nov 2018 18:55:26 +0900
MIME-Version: 1.0
In-Reply-To: <20181109061204.GC599@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/09 15:12, Sergey Senozhatsky wrote:
> On (11/08/18 20:37), Tetsuo Handa wrote:
> > On 2018/11/08 13:45, Sergey Senozhatsky wrote:
> > > So, can we just do the following? /* a sketch */
> > > 
> > > lockdep.c
> > > 	printk_safe_enter_irqsave(flags);
> > > 	lockdep_report();
> > > 	printk_safe_exit_irqrestore(flags);
> > 
> > If buffer size were large enough to hold messages from out_of_memory(),
> > I would like to use it for out_of_memory() because delaying SIGKILL
> > due to waiting for printk() to complete is not good. Surely we can't
> > hold all messages because amount from dump_tasks() is unpredictable.
> > Maybe we can hold all messages from dump_header() except dump_tasks().
> > 
> > But isn't it essentially same with
> > http://lkml.kernel.org/r/1493560477-3016-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> > which Linus does not want?
> 
> Dunno. I guess we still haven't heard from Linus because he did quite a good
> job setting up his 'email filters' ;)
> 
> Converting the existing users to buffered printk is not so simple.

Yes. We will need to ask for huge modifications for rare events.

> Apparently there are different paths; some can afford buffered printk, some
> cannot. Some of 'cont' users tend to get advantage of transparent 'cont'
> context: start 'cont' output in function A: A()->pr_cont(), continue it in
> B: A()->B()->pr_cont(), and then in C: A()->B()->C()->pr_cont(), and
> finally flush in A: A()->pr_cont(\n).

Yes, both OOM reporting and lockdep reporting have such dependency.

Linus said

  It might actually be a good idea to help those things, by making
  helper functions available that do the marshalling.

  So not calling "printk()" directly, but having a set of simple
  "buffer_print()" functions where each user has its own buffer, and
  then the "buffer_print()" functions will help people do nicely output
  data.

in https://lore.kernel.org/lkml/CA+55aFyzR4LKhJKLFgvvd9OTsos2_g4-9fova782BX4kyA3bLA@mail.gmail.com/ .

But since scattering "struct printk_buffer *" around as a function argument
is not realistic, scattering "a data structure which Linus suggested (i.e.
no printk() from helper functions)" around as a function argument will not be
realistic as well. We will need to calculate appropriate buffer size which
traverses many functions, in addition to passing that data structure as
a function argument.

>                                       And then some paths have the
> early_printk requirement. We can break the 'transparent cont' by passing
> buffer pointers around [it can get a bit hairy; looking at lockdep patch],
> but early_printk requirement is a different beast.

How early_printk requirement affects line buffered printk() API?

I don't think it is impossible to convert from

     printk("Testing feature XYZ..");
     this_may_blow_up_because_of_hw_bugs();
     printk(KERN_CONT " ... ok\n");

to

     printk("Testing feature XYZ:\n");
     this_may_blow_up_because_of_hw_bugs();
     printk("Testing feature XYZ.. ... ok\n");

in https://lore.kernel.org/lkml/CA+55aFwmwdY_mMqdEyFPpRhCKRyeqj=+aCqe5nN108v8ELFvPw@mail.gmail.com/ .

> 
> So in my email I was not advertising printk_safe as a "buffered printk for
> everyone", I was just talking about lockdep. It's a bit doubtful that Peter
> will ACK lockdep transition to buffered printk.

What Linus is suggesting is "helper functions with no printk()", which is
more difficult than my "helper functions with printk()" because we need to
calculate enough buffer size (which may traverse many functions) because
we can't printk() from helper functions when buffer size is too small.

I'm wondering if Linus still insists scattering "a data structure which
Linus suggested" around. Rather, I'd like to propose below one. This is not
perfect but modification is much smaller.

 kernel/printk/printk.c | 166 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 166 insertions(+)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 1b2a029..c339594 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1950,6 +1950,168 @@ asmlinkage int printk_emit(int facility, int level,
 }
 EXPORT_SYMBOL(printk_emit);
 
+static void buffered_printk_emit(const char *fmt, ...)
+{
+	va_list args;
+
+	va_start(args, fmt);
+	vprintk_emit(0, LOGLEVEL_DEFAULT, NULL, 0, fmt, args);
+	va_end(args);
+}
+
+static int get_completed_lines(char *buf, int pos)
+{
+	while (pos > 0) {
+		if (buf[--pos] != '\n')
+			continue;
+		buf[pos++] = '\0';
+		return pos;
+	}
+	return 0;
+}
+
+/* A structure for line-buffered printk() output. */
+struct printk_buffer {
+	/*
+	 * State of this line buffer.
+	 *
+	 * 0: Nobody has reserved, and is not using now.
+	 *
+	 * 1 to NR_CPUS: An interrupt context reserved, but is not using now.
+	 * NR_CPUS+1 to ULONG_MAX-1: Some task context reserved, but is not
+	 *                           using now.
+	 *
+	 * ULONG_MAX: Somebody has reserved, and is using now.
+	 *            This value is used as a lock.
+	 */
+	unsigned long context;
+	/* Valid bytes in buf[]. */
+	unsigned short int len;
+	char buf[LOG_LINE_MAX];
+	/* Last accessed jiffies. */
+	unsigned long stamp;
+} __aligned(1024);
+
+/* Number of line buffers. */
+#define NUM_LINE_BUFFERS 16
+
+/*
+ * Line buffered printk() tries to assign a buffer when printk() from a new
+ * context identifier comes in. And it automatically releases that buffer when
+ * one of three conditions listed below became true.
+ *
+ *   (1) printk() from that context identifier emitted '\n' as the last
+ *       character of output.
+ *   (2) printk() from that context identifier tried to print a too long line
+ *       which cannot be stored into a buffer.
+ *   (3) printk() from a new context identifier noticed that some context
+ *       identifier is reserving a buffer for more than 10 seconds without
+ *       emitting '\n'.
+ *
+ * Since (3) is based on a heuristic that somebody forgot to emit '\n' as the
+ * last character of output(), pr_cont()/KERN_CONT users are expected to emit
+ * '\n' within 10 seconds even if they reserved a buffer.
+ *
+ * There is a limitation that a buffer cannot be released if an oops occurred
+ * while that buffer is locked (context == ULONG_MAX).
+ *
+ * The granularity of context is a bit sparse. If printk() was called from task
+ * context, the address of current thread is used as context identifier. If
+ * printk() was called from non-task context, current processor ID is used as
+ * context identifier.
+ */
+static int try_buffered_printk(const char *fmt, va_list args)
+{
+	static struct printk_buffer printk_buffers[NUM_LINE_BUFFERS];
+	va_list tmp_args;
+	int pos;
+	int r;
+	const unsigned long context = in_task() ?
+		(unsigned long) current : raw_smp_processor_id() + 1;
+	struct printk_buffer *ptr;
+	const unsigned long now = jiffies;
+
+	/* Check if this context can lock a reserved buffer. */
+	for (pos = 0; pos < NUM_LINE_BUFFERS; pos++) {
+		ptr = &printk_buffers[pos];
+		if (context == ptr->context && context ==
+		    cmpxchg_acquire(&ptr->context, context, ULONG_MAX))
+			goto found;
+	}
+	/* Check if somebody is reserving a buffer for too long. */
+	for (pos = 0; pos < NUM_LINE_BUFFERS; pos++) {
+		unsigned long tmp;
+
+		ptr = &printk_buffers[pos];
+		if (likely(!ptr->len ||
+			   !time_after(now, ptr->stamp + 10 * HZ)))
+			continue;
+		tmp = ptr->context;
+		if (tmp == 0 || tmp == ULONG_MAX ||
+		    cmpxchg_acquire(&ptr->context, tmp, ULONG_MAX) != tmp)
+			continue;
+		if (ptr->len && time_after(now, ptr->stamp + 10 * HZ)) {
+			ptr->buf[ptr->len] = '\0';
+			buffered_printk_emit("%s\n", ptr->buf);
+			ptr->len = 0;
+		}
+		xchg_release(&ptr->context, 0);
+	}
+	/* Check if this context can reserve and lock a buffer. */
+	for (pos = 0; pos < NUM_LINE_BUFFERS; pos++) {
+		ptr = &printk_buffers[pos];
+		if (ptr->context == 0 &&
+		    cmpxchg_acquire(&ptr->context, 0, ULONG_MAX) == 0)
+			goto found;
+	}
+	/* All buffers are reserved. Fallback to normal printk(). */
+	return -1;
+ found:
+	ptr->stamp = now;
+	while (true) {
+		pos = ptr->len && (printk_get_level(fmt) == 'c') ? 2 : 0;
+		va_copy(tmp_args, args);
+		r = vsnprintf(ptr->buf + ptr->len, sizeof(ptr->buf) - ptr->len,
+			      fmt + pos, tmp_args);
+		va_end(tmp_args);
+		if (likely(r + ptr->len < sizeof(ptr->buf)))
+			break;
+		/* Oops. Line was too long to store into this buffer. */
+		if (!ptr->len) {
+			/*
+			 * We can do nothing. Fallback to normal printk(). But
+			 * be prepared for this printk() being the last call
+			 * from this context.
+			 */
+			r = -1;
+			goto out;
+		}
+		/* Retry after flushing incomplete line in this buffer. */
+		ptr->buf[ptr->len] = '\0';
+		buffered_printk_emit("%s", ptr->buf);
+		ptr->len = 0;
+	}
+	ptr->len += r;
+	/* Flush already completed lines. */
+	pos = get_completed_lines(ptr->buf, ptr->len);
+	if (pos) {
+		buffered_printk_emit("%s\n", ptr->buf);
+		ptr->len -= pos;
+		memmove(ptr->buf, ptr->buf + pos, ptr->len);
+	}
+ out:
+	/*
+	 * Release this buffer if this buffer became empty because this
+	 * printk() might be the last call from this context. Otherwise, keep
+	 * this buffer for future printk() calls from this context.
+	 */
+	if (!ptr->len)
+		xchg_release(&ptr->context, 0);
+	else
+		xchg_release(&ptr->context, context);
+	return r;
+}
+
 int vprintk_default(const char *fmt, va_list args)
 {
 	int r;
@@ -1961,6 +2123,10 @@ int vprintk_default(const char *fmt, va_list args)
 		return r;
 	}
 #endif
+	r = try_buffered_printk(fmt, args);
+	if (r >= 0)
+		return r;
+
 	r = vprintk_emit(0, LOGLEVEL_DEFAULT, NULL, 0, fmt, args);
 
 	return r;
-- 
1.8.3.1

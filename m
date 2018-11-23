Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA6A6B30DA
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:13:20 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id l12so11135819iop.5
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:13:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r1si19680350jaj.65.2018.11.23.05.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:13:18 -0800 (PST)
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
 <20181109061204.GC599@jagdpanzerIV>
 <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
 <20181109154326.apqkbsojmbg26o3b@pathway.suse.cz>
 <deb8d78b-0593-2b8e-1c7a-9203aa77005f@i-love.sakura.ne.jp>
 <20181123124647.jmewvgrqdpra7wbm@pathway.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <4ce501ef-92f5-7662-8105-49bfe06e109c@i-love.sakura.ne.jp>
Date: Fri, 23 Nov 2018 22:12:26 +0900
MIME-Version: 1.0
In-Reply-To: <20181123124647.jmewvgrqdpra7wbm@pathway.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/23 21:46, Petr Mladek wrote:
> I am more and more wondering if the buffered printk is worth
> the effort. The more buffers we use the more we risk that nobody
> would see some important message. Even a part of the line
> might be crucial in some situations.
> 
> Steven told me on Plumbers conference that even few initial
> characters saved him a day few times.

Yes, few initial characters of one line might sometimes help.
But emitting one line at a time also helps sometimes; especially
when we need to interpret multiple lines and group these lines from
concurrent printk() callers.

> 
> 
>> But updating printk() users to always end with '\n' will be preferable.
> 
> This sounds like a whack a mole game. If I get it correctly, you write
> that it is "an impossible task for anybody" just few lines above.

Yes, updating printk() users is almost impossible. I think that something
like diff shown below is what we can afford at best. If you believe that
line buffering is wrong, I can tolerate with switching via kernel config
option like CONFIG_DEBUG_AID_FOR_SYZBOT=y.

 kernel/printk/printk.c | 263 +++++++++++++++++++++++++++++++++----------------
 1 file changed, 176 insertions(+), 87 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 315718b..2276c99 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -584,6 +584,15 @@ static int log_store(int facility, int level,
 	struct printk_log *msg;
 	u32 size, pad_len;
 	u16 trunc_msg_len = 0;
+	static char id[32];
+	u16 id_len;
+
+	if (in_task())
+		id_len = scnprintf(id, sizeof(id), "[T%u] ", current->pid);
+	else
+		id_len = scnprintf(id, sizeof(id), "[C%u] ",
+				   raw_smp_processor_id());
+	text_len += id_len;
 
 	/* number of '\0' padding bytes to next message */
 	size = msg_used_size(text_len, dict_len, &pad_len);
@@ -607,12 +616,16 @@ static int log_store(int facility, int level,
 		log_next_idx = 0;
 	}
 
+	text_len -= id_len;
+
 	/* fill message */
 	msg = (struct printk_log *)(log_buf + log_next_idx);
-	memcpy(log_text(msg), text, text_len);
-	msg->text_len = text_len;
+	memcpy(log_text(msg), id, id_len);
+	memcpy(log_text(msg) + id_len, text, text_len);
+	msg->text_len = text_len + id_len;
 	if (trunc_msg_len) {
-		memcpy(log_text(msg) + text_len, trunc_msg, trunc_msg_len);
+		memcpy(log_text(msg) + id_len + text_len, trunc_msg,
+		       trunc_msg_len);
 		msg->text_len += trunc_msg_len;
 	}
 	memcpy(log_dict(msg), dict, dict_len);
@@ -620,10 +633,7 @@ static int log_store(int facility, int level,
 	msg->facility = facility;
 	msg->level = level & 7;
 	msg->flags = flags & 0x1f;
-	if (ts_nsec > 0)
-		msg->ts_nsec = ts_nsec;
-	else
-		msg->ts_nsec = local_clock();
+	msg->ts_nsec = ts_nsec;
 	memset(log_dict(msg) + dict_len, 0, pad_len);
 	msg->len = size;
 
@@ -1758,87 +1768,154 @@ static inline void printk_delay(void)
 }
 
 /*
- * Continuation lines are buffered, and not committed to the record buffer
- * until the line is complete, or a race forces it. The line fragments
- * though, are printed immediately to the consoles to ensure everything has
- * reached the console in case of a kernel crash.
+ * Continuation lines are buffered based on type of context, and not committed
+ * to the record buffer until the line is complete, or a race forces it.
+ *
+ * While this context calculation is not perfect, asking printk() callers to
+ * explicitly pass "struct printk_buffer" (except "context" field) as their
+ * function arguments will require too large tree-wide changes. Therefore,
+ * let's tolerate failing to separate "up to one line of messages", and avoid
+ * bloating kernel code size for addressing infrequently happening races.
  */
-static struct cont {
-	char buf[LOG_LINE_MAX];
-	size_t len;			/* length == 0 means unused buffer */
-	struct task_struct *owner;	/* task of first print*/
-	u64 ts_nsec;			/* time of first print */
-	u8 level;			/* log level of first message */
-	u8 facility;			/* log facility of first message */
-	enum log_flags flags;		/* prefix, newline flags */
-} cont;
-
-static void cont_flush(void)
+static inline unsigned long printk_context(void)
 {
-	if (cont.len == 0)
-		return;
-
-	log_store(cont.facility, cont.level, cont.flags, cont.ts_nsec,
-		  NULL, 0, cont.buf, cont.len);
-	cont.len = 0;
-}
+	unsigned long base;
 
-static bool cont_add(int facility, int level, enum log_flags flags, const char *text, size_t len)
-{
-	/* If the line gets too long, split it up in separate records. */
-	if (cont.len + len > sizeof(cont.buf)) {
-		cont_flush();
-		return false;
-	}
-
-	if (!cont.len) {
-		cont.facility = facility;
-		cont.level = level;
-		cont.owner = current;
-		cont.ts_nsec = local_clock();
-		cont.flags = flags;
-	}
-
-	memcpy(cont.buf + cont.len, text, len);
-	cont.len += len;
-
-	// The original flags come from the first line,
-	// but later continuations can add a newline.
-	if (flags & LOG_NEWLINE) {
-		cont.flags |= LOG_NEWLINE;
-		cont_flush();
-	}
-
-	return true;
+	if (in_task())
+		return (unsigned long) current;
+	if (in_nmi())
+		base = NR_CPUS * 2;
+	else if (in_irq())
+		base = NR_CPUS;
+	else
+		base = 0;
+	return base + raw_smp_processor_id();
 }
 
-static size_t log_output(int facility, int level, enum log_flags lflags, const char *dict, size_t dictlen, char *text, size_t text_len)
-{
+struct printk_buffer {
+	char buf[LOG_LINE_MAX];
+	/* valid bytes in buf[] */
+	size_t len;
 	/*
-	 * If an earlier line was buffered, and we're a continuation
-	 * write from the same process, try to add it to the buffer.
+	 * owner context of this buffer if len != 0
+	 *
+	 * 0 to NR_CPUS - 1: A soft IRQ context reserved.
+	 * NR_CPUS to NR_CPUS * 2 - 1: A hard IRQ context reserved.
+	 * NR_CPUS * 2 to NR_CPUS * 3 - 1: An NMI context reserved.
+	 * NR_CPUS * 3 to ULONG_MAX: Some task context reserved.
 	 */
-	if (cont.len) {
-		if (cont.owner == current && (lflags & LOG_CONT)) {
-			if (cont_add(facility, level, lflags, text, text_len))
-				return text_len;
+	unsigned long context;
+	/* last accessed jiffies */
+	unsigned long last_used;
+	/* time of first print */
+	u64 ts_nsec;
+	/* log flags of first message */
+	enum log_flags lflags;
+	/* log level of first message */
+	u8 level;
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
+ */
+static void log_output(const int facility, const int level,
+		       const enum log_flags lflags,
+		       const char *text, const size_t text_len)
+{
+	static struct printk_buffer printk_buffers[NUM_LINE_BUFFERS];
+	static struct printk_buffer static_buffer;
+	struct printk_buffer *ptr;
+	int i;
+	const unsigned long context = printk_context();
+	const unsigned long now = jiffies;
+
+	/* Only kernel-generated messages are subjected to buffering. */
+	if (facility) {
+		ptr = &static_buffer;
+		goto found;
+	}
+	/* Check if this context already reserved a buffer. */
+	for (i = 0; i < NUM_LINE_BUFFERS; i++) {
+		ptr = &printk_buffers[i];
+		if (ptr->len && context == ptr->context)
+			goto found;
+	}
+	/* Check if somebody is reserving a buffer for too long. */
+	for (i = 0; i < NUM_LINE_BUFFERS; i++) {
+		ptr = &printk_buffers[i];
+		if (!ptr->len || !time_after(now, ptr->last_used + 10 * HZ))
+			continue;
+		/* Forced flush due to timeout. */
+		log_store(facility, ptr->level, ptr->lflags, ptr->ts_nsec,
+			  NULL, 0, ptr->buf, ptr->len);
+		ptr->len = 0;
+	}
+	/* Check if this context can reserve a buffer. */
+	for (i = 0; i < NUM_LINE_BUFFERS; i++) {
+		ptr = &printk_buffers[i];
+		if (ptr->len == 0) {
+			ptr->context = context;
+			goto found;
 		}
-		/* Otherwise, make sure it's flushed */
-		cont_flush();
 	}
+	/* Forced assign due to out of buffers. */
+	ptr = &static_buffer;
+ found:
+	/* Forced flush due to log prefix or out of space. */
+	if (((ptr->len && (lflags & LOG_PREFIX)) ||
+	     text_len + ptr->len > sizeof(ptr->buf))) {
+		log_store(facility, ptr->level, ptr->lflags, ptr->ts_nsec,
+			  NULL, 0, ptr->buf, ptr->len);
+		ptr->len = 0;
+	}
+	if (ptr->len == 0) {
+		ptr->lflags = lflags;
+		ptr->level = level;
+		ptr->ts_nsec = local_clock();
+	}
+	/* 0 <= text_len <= LOG_LINE_MAX due to vscnprintf(). */
+	memmove(ptr->buf + ptr->len, text, text_len);
+	ptr->len += text_len;
+	/*
+	 * Flush already completed lines. By splitting at '\n', we can inject
+	 * caller id information to each line of text information.
+	 */
+	while (true) {
+		size_t len;
+		char *cp = memchr(ptr->buf, '\n', ptr->len);
 
-	/* Skip empty continuation lines that couldn't be added - they just flush */
-	if (!text_len && (lflags & LOG_CONT))
-		return 0;
-
-	/* If it doesn't end in a newline, try to buffer the current line */
-	if (!(lflags & LOG_NEWLINE)) {
-		if (cont_add(facility, level, lflags, text, text_len))
-			return text_len;
+		if (!cp)
+			break;
+		len = ++cp - ptr->buf;
+		log_store(facility, ptr->level, ptr->lflags, ptr->ts_nsec,
+			  NULL, 0, ptr->buf, len - 1);
+		ptr->len -= len;
+		memmove(ptr->buf, cp, ptr->len);
 	}
-
-	/* Store it in the record log */
-	return log_store(facility, level, lflags, 0, dict, dictlen, text, text_len);
+	/* Forced flush due to out of buffers. */
+	if (ptr == &static_buffer && ptr->len) {
+		log_store(facility, ptr->level, ptr->lflags, ptr->ts_nsec,
+			  NULL, 0, ptr->buf, ptr->len);
+		ptr->len = 0;
+	}
+	ptr->last_used = now;
 }
 
 /* Must be called under logbuf_lock. */
@@ -1857,12 +1934,6 @@ int vprintk_store(int facility, int level,
 	 */
 	text_len = vscnprintf(text, sizeof(textbuf), fmt, args);
 
-	/* mark and strip a trailing newline */
-	if (text_len && text[text_len-1] == '\n') {
-		text_len--;
-		lflags |= LOG_NEWLINE;
-	}
-
 	/* strip kernel syslog prefix and extract log level or control flags */
 	if (facility == 0) {
 		int kern_level;
@@ -1888,11 +1959,29 @@ int vprintk_store(int facility, int level,
 	if (level == LOGLEVEL_DEFAULT)
 		level = default_message_loglevel;
 
-	if (dict)
-		lflags |= LOG_PREFIX|LOG_NEWLINE;
+	if (dict) {
+		char *cp;
 
-	return log_output(facility, level, lflags,
-			  dict, dictlen, text, text_len);
+		/* Remove the trailing newline. */
+		if (text_len && text[text_len-1] == '\n')
+			text_len--;
+		/*
+		 * Remove any newline because we don't want to duplicate dict
+		 * information while we want to prefix caller id information to
+		 * each line of text information.
+		 */
+		while ((cp = memchr(text, '\n', text_len)) != NULL)
+			*cp = ' ';
+		log_store(facility, level, lflags | LOG_PREFIX | LOG_NEWLINE,
+			  local_clock(), dict, dictlen, text, text_len);
+		return text_len;
+	}
+
+	/* Add '\n' via line buffering for kernel-generated messages. */
+	if (!facility)
+		lflags |= LOG_NEWLINE;
+	log_output(facility, level, lflags, text, text_len);
+	return text_len;
 }
 
 asmlinkage int vprintk_emit(int facility, int level,
-- 
1.8.3.1

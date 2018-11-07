Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E9B5A6B0508
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 08:41:51 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z7-v6so9644826edh.19
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 05:41:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2-v6si477157edl.276.2018.11.07.05.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 05:41:50 -0800 (PST)
Date: Wed, 7 Nov 2018 14:41:47 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181107134147.xcohoqzpdpo6wnd6@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Fri 2018-11-02 22:31:55, Tetsuo Handa wrote:
> Sometimes we want to print a whole line without being disturbed by
> concurrent printk() from interrupts and/or other threads, for printk()
> which does not end with '\n' can be disturbed.
> 
> Since mixed printk() output makes it hard to interpret, this patch
> introduces API for line-buffered printk() output (so that we can make
> sure that printk() ends with '\n').
> 
> Since functions introduced by this patch are merely wrapping
> printk()/vprintk() calls in order to minimize possibility of using
> "struct cont", it is safe to replace printk()/vprintk() with this API.
> Since we want to remove "struct cont" eventually, we will try to remove
> both "implicit printk() users who are expecting KERN_CONT behavior" and
> "explicit pr_cont()/printk(KERN_CONT) users". Therefore, converting to
> this API is recommended.

[...]

> diff --git a/include/linux/printk.h b/include/linux/printk.h
> index cf3eccf..92af345 100644
> --- a/include/linux/printk.h
> +++ b/include/linux/printk.h
> @@ -173,6 +174,20 @@ int printk_emit(int facility, int level,
>  
>  asmlinkage __printf(1, 2) __cold
>  int printk(const char *fmt, ...);
> +struct printk_buffer *get_printk_buffer(void);
> +bool flush_printk_buffer(struct printk_buffer *ptr);
> +__printf(2, 3)
> +int printk_buffered(struct printk_buffer *ptr, const char *fmt, ...);
> +__printf(2, 0)
> +int vprintk_buffered(struct printk_buffer *ptr, const char *fmt, va_list args);
> +/*
> + * In order to avoid accidentally reusing "ptr" after put_printk_buffer("ptr"),
> + * put_printk_buffer() is defined as a macro which explicitly resets "ptr" to
> + * NULL.
> + */
> +void __put_printk_buffer(struct printk_buffer *ptr);
> +#define put_printk_buffer(ptr)					\
> +	do { __put_printk_buffer(ptr); ptr = NULL; } while (0)

I have mixed feelings about this. It is clever but it complicates the
code. I wonder why we need to be more paranoid than kfree() and
friends. Especially that the reuse of printk buffer is much less
dangerous than reusing freed pointers.

Please, remove it unless it gets more supporters.


> --- /dev/null
> +++ b/kernel/printk/printk_buffered.c
> +int vprintk_buffered(struct printk_buffer *ptr, const char *fmt, va_list args)
> +{
> +	va_list tmp_args;
> +	int r;
> +	int pos;
> +
> +	if (!ptr)
> +		return vprintk(fmt, args);
> +	/*
> +	 * Skip KERN_CONT here based on an assumption that KERN_CONT will be
> +	 * given via "fmt" argument when KERN_CONT is given.
> +	 */
> +	pos = (printk_get_level(fmt) == 'c') ? 2 : 0;
> +	while (true) {
> +		va_copy(tmp_args, args);
> +		r = vsnprintf(ptr->buf + ptr->len, sizeof(ptr->buf) - ptr->len,
> +			      fmt + pos, tmp_args);
> +		va_end(tmp_args);
> +		if (likely(r + ptr->len < sizeof(ptr->buf)))
> +			break;
> +		if (!flush_printk_buffer(ptr))
> +			return vprintk(fmt, args);
> +	}
> +	ptr->len += r;
> +	/* Flush already completed lines if any. */
> +	for (pos = ptr->len - 1; pos >= 0; pos--) {
> +		if (ptr->buf[pos] != '\n')
> +			continue;
> +		ptr->buf[pos++] = '\0';
> +		printk("%s\n", ptr->buf);
> +		ptr->len -= pos;
> +		memmove(ptr->buf, ptr->buf + pos, ptr->len);
> +		/* This '\0' will be overwritten by next vsnprintf() above. */
> +		ptr->buf[ptr->len] = '\0';

I am not against explicitly adding '\0' this way. Just note that there
is always the trailing '\0' in the original string, see below.

I mean that we could get the same result with memmove(,, ptr->len+1);


> +		break;
> +	}
> +	return r;
> +}
> +
> +/**
> + * flush_printk_buffer - Flush incomplete line in printk_buffer.
> + *
> + * @ptr: Pointer to "struct printk_buffer". It can be NULL.
> + *
> + * Returns true if flushed something, false otherwise.
> + *
> + * Flush if @ptr contains partial data. But usually there is no need to call
> + * this function because @ptr is flushed by put_printk_buffer().
> + */
> +bool flush_printk_buffer(struct printk_buffer *ptr)
> +{
> +	if (!ptr || !ptr->len)
> +		return false;
> +	/*
> +	 * vprintk_buffered() keeps 0 <= ptr->len < sizeof(ptr->buf) true.
> +	 * But ptr->buf[ptr->len] != '\0' if this function is called due to
> +	 * vsnprintf() + ptr->len >= sizeof(ptr->buf).
> +	 */
> +	ptr->buf[ptr->len] = '\0';

This is not necessary. Note that vsnprintf() always adds the trailing
'\0' even when the string is shrunken.


> +	printk("%s", ptr->buf);
> +	ptr->len = 0;
> +	return true;
> +}
> +EXPORT_SYMBOL(flush_printk_buffer);
> +
> +/**
> + * __put_printk_buffer - Release printk_buffer.
> + *
> + * @ptr: Pointer to "struct printk_buffer". It can be NULL.
> + *
> + * Returns nothing.
> + *
> + * Flush and release @ptr.
> + * Please use put_printk_buffer() in order to catch use-after-free bugs.
> + */
> +void __put_printk_buffer(struct printk_buffer *ptr)
> +{
> +	long i = (unsigned long) ptr - (unsigned long) printk_buffers;
> +
> +	if (!ptr)
> +		return;
> +	if (WARN_ON_ONCE(i % sizeof(struct printk_buffer)))
> +		return;
> +	i /= sizeof(struct printk_buffer);
> +	if (WARN_ON_ONCE(i < 0 || i >= NUM_LINE_BUFFERS))
> +		return;
> +	if (ptr->len)

Nit: This check is superfluous.

> +		flush_printk_buffer(ptr);
> +	clear_bit_unlock(i, printk_buffers_in_use);
> +}
> +EXPORT_SYMBOL(__put_printk_buffer);

Otherwise, it looks good to me.


Best Regards,
Petr

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 228616B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:42:11 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id gy3so75418647igb.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 00:42:11 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id aw4si14444774igc.47.2016.04.11.00.42.09
        for <linux-mm@kvack.org>;
        Mon, 11 Apr 2016 00:42:10 -0700 (PDT)
Date: Mon, 11 Apr 2016 16:44:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v7 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
Message-ID: <20160411074452.GC26116@js1304-P5Q-DELUXE>
References: <cover.1457949315.git.glider@google.com>
 <4f6880ee0c1545b3ae9c25cfe86a879d724c4e7b.1457949315.git.glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4f6880ee0c1545b3ae9c25cfe86a879d724c4e7b.1457949315.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, kcc@google.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 14, 2016 at 11:43:43AM +0100, Alexander Potapenko wrote:
> +depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
> +				    gfp_t alloc_flags)
> +{
> +	u32 hash;
> +	depot_stack_handle_t retval = 0;
> +	struct stack_record *found = NULL, **bucket;
> +	unsigned long flags;
> +	struct page *page = NULL;
> +	void *prealloc = NULL;
> +	bool *rec;
> +
> +	if (unlikely(trace->nr_entries == 0))
> +		goto fast_exit;
> +
> +	rec = this_cpu_ptr(&depot_recursion);
> +	/* Don't store the stack if we've been called recursively. */
> +	if (unlikely(*rec))
> +		goto fast_exit;
> +	*rec = true;
> +
> +	hash = hash_stack(trace->entries, trace->nr_entries);
> +	/* Bad luck, we won't store this stack. */
> +	if (hash == 0)
> +		goto exit;

Hello,

why is hash == 0 skipped?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

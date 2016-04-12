Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 997886B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:48:28 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id n1so6168859pfn.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:48:28 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id gi2si7882128pac.105.2016.04.11.21.48.27
        for <linux-mm@kvack.org>;
        Mon, 11 Apr 2016 21:48:27 -0700 (PDT)
Date: Tue, 12 Apr 2016 13:51:13 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v7 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
Message-ID: <20160412045113.GB29018@js1304-P5Q-DELUXE>
References: <cover.1457949315.git.glider@google.com>
 <4f6880ee0c1545b3ae9c25cfe86a879d724c4e7b.1457949315.git.glider@google.com>
 <20160411074452.GC26116@js1304-P5Q-DELUXE>
 <CAG_fn=W_zM0u_NjSzJNi9KiNRY=rtQSYWTVfOQ2nGedApWMBdg@mail.gmail.com>
 <CAG_fn=XQ1jvUXG2xWM9rEgqBEB-DBrA-G6wWOZ9t_SvfrKjdsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=XQ1jvUXG2xWM9rEgqBEB-DBrA-G6wWOZ9t_SvfrKjdsg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Apr 11, 2016 at 04:51:47PM +0200, Alexander Potapenko wrote:
> On Mon, Apr 11, 2016 at 4:39 PM, Alexander Potapenko <glider@google.com> wrote:
> > On Mon, Apr 11, 2016 at 9:44 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >> On Mon, Mar 14, 2016 at 11:43:43AM +0100, Alexander Potapenko wrote:
> >>> +depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
> >>> +                                 gfp_t alloc_flags)
> >>> +{
> >>> +     u32 hash;
> >>> +     depot_stack_handle_t retval = 0;
> >>> +     struct stack_record *found = NULL, **bucket;
> >>> +     unsigned long flags;
> >>> +     struct page *page = NULL;
> >>> +     void *prealloc = NULL;
> >>> +     bool *rec;
> >>> +
> >>> +     if (unlikely(trace->nr_entries == 0))
> >>> +             goto fast_exit;
> >>> +
> >>> +     rec = this_cpu_ptr(&depot_recursion);
> >>> +     /* Don't store the stack if we've been called recursively. */
> >>> +     if (unlikely(*rec))
> >>> +             goto fast_exit;
> >>> +     *rec = true;
> >>> +
> >>> +     hash = hash_stack(trace->entries, trace->nr_entries);
> >>> +     /* Bad luck, we won't store this stack. */
> >>> +     if (hash == 0)
> >>> +             goto exit;
> >>
> >> Hello,
> >>
> >> why is hash == 0 skipped?
> >>
> >> Thanks.
> > We have to keep a special value to distinguish allocations for which
> > we don't have the stack trace for some reason.
> > Making 0 such a value seems natural.
> Well, the above statement is false.
> Because we only compare the hash to the records that are already in
> the depot, there's no point in reserving this value.

So, could you make a patch for it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

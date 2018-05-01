Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B54586B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 20:36:40 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 6-v6so9056579itl.6
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 17:36:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f1-v6sor3440496ita.67.2018.04.30.17.36.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 17:36:39 -0700 (PDT)
Date: Mon, 30 Apr 2018 19:36:34 -0500
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [PATCH v2] KASAN: prohibit KASAN+STRUCTLEAK combination
Message-ID: <20180501003634.GA1135@big-sky.local>
References: <20180419172451.104700-1-dvyukov@google.com>
 <CAGXu5jK_C-xgNOFxtCi3Wt63_ProP0jw2YSiE0fbVhu=J0pNFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jK_C-xgNOFxtCi3Wt63_ProP0jw2YSiE0fbVhu=J0pNFA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

Hi Kees,

On Mon, Apr 30, 2018 at 04:41:24PM -0700, Kees Cook wrote:
> I prefer this change over moving the plugin earlier since that ends up
> creating redundant initializers...

To be clear, what I was proposing was to move the plugin to execute
later rather than earlier. It currently runs before the
early_optimizations pass, while *all_optimizations is after inlining.
Apologizes for this being a half baked idea due to my limited
understanding.

I am hoping someone could chime in and help me understand how gcc
handles inlining. My assumption is that at the beginning, inlined
defined functions will be processed by the pass as any other function.
If the function can be inlined, it is inlined and no longer needs to be
kept around. If it cannot be inlined, it is kept around. An assumption
that I'm not sure is correct is that a function is either always inlined
or not inlined in a translation unit.

The current plugin puts an initializer in both the inlined function and
the locations that it will be inlined as both functions are around,
hence duplicate initializers. Below is a snippet of pass output from
earlier reproducing code of the issue.

My understanding is initializer 1 is created due to inlining moving
variable declarations to the encompassing functions scope. Then the
structleak_plugin performs the pass not finding an initializer and
creates one. Initializer 2 is created for the inlined function and is
propagated. So I guess this problem is also order dependent in which the
functions are processed.

An important difference in running in a later pass, which may be a deal
breaker, is that objects will only be initialized once. So if a function
gets inlined inside a for loop, the initializer will only be a part of
the encompassing function rather than also in each iteration. In the
example below, initializer 2 would not be there as the inlined function
wouldn't be around and processed by the structleak_plugin.

Thanks for taking the time to humor me, this is the extent of my
understanding of the problem and gcc.

Thanks,
Dennis

------

union
{
struct list_head * __val;
char __c[1];
} __u;

<bb 2> [0.00%]:
__u = {};    <---- initializer 1
p_8 = malloc (160);
i_9 = 0;
goto <bb 10>; [0.00%]

<bb 3> [0.00%]:
_1 = (long unsigned int) i_4;
_2 = _1 * 16;
_3 = p_8 + _2;
list_14 = _3;
__u = {};    <---- initializer 2
ASAN_MARK (UNPOISON, &__u, 8);

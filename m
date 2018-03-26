Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5026B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:14:49 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g22so9416564pgv.16
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 05:14:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b3-v6sor370405plc.5.2018.03.26.05.14.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 05:14:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1522058304-35934-1-git-send-email-maninder1.s@samsung.com>
References: <CGME20180326100020epcas5p2b50b7541e66dccf4e49db634e5fe6b41@epcas5p2.samsung.com>
 <1522058304-35934-1-git-send-email-maninder1.s@samsung.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 26 Mar 2018 14:14:26 +0200
Message-ID: <CACT4Y+Yfx+fTHyQ=d3T68bwfgQQsmqd+e72V67kaAHajo536JA@mail.gmail.com>
Subject: Re: [PATCH v2] mm/page_owner: ignore everything below the IRQ entry point
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maninder Singh <maninder1.s@samsung.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, vinmenon@codeaurora.org, gomonovych@gmail.com, ayush.m@samsung.com, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>, Vaneet narang <v.narang@samsung.com>

On Mon, Mar 26, 2018 at 11:58 AM, Maninder Singh
<maninder1.s@samsung.com> wrote:
> Check whether the allocation happens in an IRQ handler.
> This lets us strip everything below the IRQ entry point to reduce the
> number of unique stack traces needed to be stored.
>
> so moved code of KASAN in generic file so that page_owner can also
> do same filteration.
>
> Initial KASAN commit
> id=be7635e7287e0e8013af3c89a6354a9e0182594c
>
> original:-
> __alloc_pages_nodemask+0xfc/0x220
>  page_frag_alloc+0x84/0x140
>  __napi_alloc_skb+0x83/0xe0
>  rtl8169_poll+0x1e5/0x670
>  net_rx_action+0x132/0x3a0
>  __do_softirq+0xce/0x298
>  irq_exit+0xa3/0xb0
>  do_IRQ+0x72/0xc0
>  ret_from_intr+0x0/0x18
>  cpuidle_enter_state+0x96/0x290
>  do_idle+0x163/0x1a0
>
> After patch:-
>  __alloc_pages_nodemask+0xfc/0x220
>  page_frag_alloc+0x84/0x140
>  __napi_alloc_skb+0x83/0xe0
>  rtl8169_poll+0x1e5/0x670
>  net_rx_action+0x132/0x3a0
>  __do_softirq+0xce/0x298
>
> Signed-off-by: Vaneet Narang <v.narang@samsung.com>
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> ---
> v1->v2: fix build break for tile and blackfin
> (https://lkml.org/lkml/2017/12/3/287, verified for blackfin)
>
>  include/linux/stacktrace.h | 26 ++++++++++++++++++++++++++
>  mm/kasan/kasan.c           | 22 ----------------------
>  mm/page_owner.c            |  1 +
>  3 files changed, 27 insertions(+), 22 deletions(-)
>
> diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
> index ba29a06..3d3e49d 100644
> --- a/include/linux/stacktrace.h
> +++ b/include/linux/stacktrace.h
> @@ -4,6 +4,8 @@
>
>  #include <linux/types.h>
>
> +extern char __irqentry_text_start[], __irqentry_text_end[];
> +extern char __softirqentry_text_start[], __softirqentry_text_end[];
>  struct task_struct;
>  struct pt_regs;
>
> @@ -26,6 +28,28 @@ extern int save_stack_trace_tsk_reliable(struct task_struct *tsk,
>  extern int snprint_stack_trace(char *buf, size_t size,
>                         struct stack_trace *trace, int spaces);
>
> +static inline int in_irqentry_text(unsigned long ptr)
> +{
> +       return (ptr >= (unsigned long)&__irqentry_text_start &&
> +               ptr < (unsigned long)&__irqentry_text_end) ||
> +               (ptr >= (unsigned long)&__softirqentry_text_start &&
> +                ptr < (unsigned long)&__softirqentry_text_end);
> +}
> +
> +static inline void filter_irq_stacks(struct stack_trace *trace)
> +{
> +       int i;
> +
> +       if (!trace->nr_entries)
> +               return;
> +       for (i = 0; i < trace->nr_entries; i++)
> +               if (in_irqentry_text(trace->entries[i])) {
> +                       /* Include the irqentry function into the stack. */
> +                       trace->nr_entries = i + 1;
> +                       break;
> +               }
> +}
> +
>  #ifdef CONFIG_USER_STACKTRACE_SUPPORT
>  extern void save_stack_trace_user(struct stack_trace *trace);
>  #else
> @@ -38,6 +62,8 @@ extern int snprint_stack_trace(char *buf, size_t size,
>  # define save_stack_trace_user(trace)                  do { } while (0)
>  # define print_stack_trace(trace, spaces)              do { } while (0)
>  # define snprint_stack_trace(buf, size, trace, spaces) do { } while (0)
> +# define filter_irq_stacks(trace)                      do { } while (0)
> +# define in_irqentry_text(ptr)                         do { } while (0)

Hi,

Every user of stack_depot should filter out irq frames, without that
stack_depot will run out of memory sooner or later. so this is a
change in the right direction.

Do we need to define empty version of in_irqentry_text? Shouldn't only
filter_irq_stacks be used by kernel code?


>  # define save_stack_trace_tsk_reliable(tsk, trace)     ({ -ENOSYS; })
>  #endif /* CONFIG_STACKTRACE */
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 405bba4..129e7b8 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -412,28 +412,6 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
>                         KASAN_KMALLOC_REDZONE);
>  }
>
> -static inline int in_irqentry_text(unsigned long ptr)
> -{
> -       return (ptr >= (unsigned long)&__irqentry_text_start &&
> -               ptr < (unsigned long)&__irqentry_text_end) ||
> -               (ptr >= (unsigned long)&__softirqentry_text_start &&
> -                ptr < (unsigned long)&__softirqentry_text_end);
> -}
> -
> -static inline void filter_irq_stacks(struct stack_trace *trace)
> -{
> -       int i;
> -
> -       if (!trace->nr_entries)
> -               return;
> -       for (i = 0; i < trace->nr_entries; i++)
> -               if (in_irqentry_text(trace->entries[i])) {
> -                       /* Include the irqentry function into the stack. */
> -                       trace->nr_entries = i + 1;
> -                       break;
> -               }
> -}
> -
>  static inline depot_stack_handle_t save_stack(gfp_t flags)
>  {
>         unsigned long entries[KASAN_STACK_DEPTH];
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 8602fb4..30e9cb2 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -148,6 +148,7 @@ static noinline depot_stack_handle_t save_stack(gfp_t flags)
>         depot_stack_handle_t handle;
>
>         save_stack_trace(&trace);
> +       filter_irq_stacks(&trace);
>         if (trace.nr_entries != 0 &&
>             trace.entries[trace.nr_entries-1] == ULONG_MAX)
>                 trace.nr_entries--;
> --
> 1.9.1
>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 466F36B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 09:40:30 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id w136so240325vkd.14
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 06:40:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34sor124795uav.86.2017.12.05.06.40.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 06:40:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1512362600-40838-1-git-send-email-maninder1.s@samsung.com>
References: <CGME20171204044702epcas5p3a8d82d304038fe197ab324a4e0267e55@epcas5p3.samsung.com>
 <1512362600-40838-1-git-send-email-maninder1.s@samsung.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 5 Dec 2017 15:40:27 +0100
Message-ID: <CAG_fn=Vjh_+11vSdjAv=0d6KYv7uc0JNYLSU8iTmTtbkxx5YTA@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/page_owner: ignore everything below the IRQ entry point
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maninder Singh <maninder1.s@samsung.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, mbenes@suse.cz, Thomas Gleixner <tglx@linutronix.de>, pombredanne@nexb.com, Ingo Molnar <mingo@kernel.org>, gregkh@linuxfoundation.org, Josh Poimboeuf <jpoimboe@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.com, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, a.sahrawat@samsung.com, pankaj.m@samsung.com, Vaneet Narang <v.narang@samsung.com>, Dmitriy Vyukov <dvyukov@google.com>

On Mon, Dec 4, 2017 at 5:43 AM, Maninder Singh <maninder1.s@samsung.com> wr=
ote:
> Check whether the allocation happens in an IRQ handler.
> This lets us strip everything below the IRQ entry point to reduce the
> number of unique stack traces needed to be stored.
>
> so moved code of KASAN in generic file so that page_owner can also
> do same filteration.
>
> Initial KASAN commit
> id=3Dbe7635e7287e0e8013af3c89a6354a9e0182594c
>
> Signed-off-by: Vaneet Narang <v.narang@samsung.com>
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Reviewed-by: Alexander Potapenko <glider@google.com>
> ---
>  include/linux/stacktrace.h | 25 +++++++++++++++++++++++++
>  mm/kasan/kasan.c           | 22 ----------------------
>  mm/page_owner.c            |  1 +
>  3 files changed, 26 insertions(+), 22 deletions(-)
>
> diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
> index ba29a06..2c1a562 100644
> --- a/include/linux/stacktrace.h
> +++ b/include/linux/stacktrace.h
> @@ -3,6 +3,7 @@
>  #define __LINUX_STACKTRACE_H
>
>  #include <linux/types.h>
> +#include <asm-generic/sections.h>
>
>  struct task_struct;
>  struct pt_regs;
> @@ -26,6 +27,28 @@ extern int save_stack_trace_tsk_reliable(struct task_s=
truct *tsk,
>  extern int snprint_stack_trace(char *buf, size_t size,
>                         struct stack_trace *trace, int spaces);
>
> +static inline int in_irqentry_text(unsigned long ptr)
> +{
> +       return (ptr >=3D (unsigned long)&__irqentry_text_start &&
> +               ptr < (unsigned long)&__irqentry_text_end) ||
> +               (ptr >=3D (unsigned long)&__softirqentry_text_start &&
> +                ptr < (unsigned long)&__softirqentry_text_end);
> +}
> +
> +static inline void filter_irq_stacks(struct stack_trace *trace)
> +{
> +       int i;
> +
> +       if (!trace->nr_entries)
> +               return;
> +       for (i =3D 0; i < trace->nr_entries; i++)
> +               if (in_irqentry_text(trace->entries[i])) {
> +                       /* Include the irqentry function into the stack. =
*/
> +                       trace->nr_entries =3D i + 1;
> +                       break;
> +               }
> +}
> +
>  #ifdef CONFIG_USER_STACKTRACE_SUPPORT
>  extern void save_stack_trace_user(struct stack_trace *trace);
>  #else
> @@ -38,6 +61,8 @@ extern int snprint_stack_trace(char *buf, size_t size,
>  # define save_stack_trace_user(trace)                  do { } while (0)
>  # define print_stack_trace(trace, spaces)              do { } while (0)
>  # define snprint_stack_trace(buf, size, trace, spaces) do { } while (0)
> +# define filter_irq_stacks(trace)                      do { } while (0)
> +# define in_irqentry_text(ptr)                         do { } while (0)
>  # define save_stack_trace_tsk_reliable(tsk, trace)     ({ -ENOSYS; })
>  #endif /* CONFIG_STACKTRACE */
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 405bba4..129e7b8 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -412,28 +412,6 @@ void kasan_poison_object_data(struct kmem_cache *cac=
he, void *object)
>                         KASAN_KMALLOC_REDZONE);
>  }
>
> -static inline int in_irqentry_text(unsigned long ptr)
> -{
> -       return (ptr >=3D (unsigned long)&__irqentry_text_start &&
> -               ptr < (unsigned long)&__irqentry_text_end) ||
> -               (ptr >=3D (unsigned long)&__softirqentry_text_start &&
> -                ptr < (unsigned long)&__softirqentry_text_end);
> -}
> -
> -static inline void filter_irq_stacks(struct stack_trace *trace)
> -{
> -       int i;
> -
> -       if (!trace->nr_entries)
> -               return;
> -       for (i =3D 0; i < trace->nr_entries; i++)
> -               if (in_irqentry_text(trace->entries[i])) {
> -                       /* Include the irqentry function into the stack. =
*/
> -                       trace->nr_entries =3D i + 1;
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
> @@ -148,6 +148,7 @@ static noinline depot_stack_handle_t save_stack(gfp_t=
 flags)
>         depot_stack_handle_t handle;
>
>         save_stack_trace(&trace);
> +       filter_irq_stacks(&trace);
>         if (trace.nr_entries !=3D 0 &&
>             trace.entries[trace.nr_entries-1] =3D=3D ULONG_MAX)
>                 trace.nr_entries--;
> --
> 1.9.1
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

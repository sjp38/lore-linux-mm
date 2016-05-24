Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F31AA6B0266
	for <linux-mm@kvack.org>; Tue, 24 May 2016 13:32:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so14830191wma.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 10:32:18 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id qn6si5466287wjc.143.2016.05.24.10.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 10:32:17 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id n129so142288115wmn.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 10:32:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160524001529.0e69232eff0b1b5bc566a763@gmail.com>
References: <20160524001405.3e6abd1d5a63a871cc366cff@gmail.com> <20160524001529.0e69232eff0b1b5bc566a763@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 May 2016 10:32:15 -0700
Message-ID: <CAGXu5jJHenHARDZt=51m1XbSStTxpG90Dv=Fpkn79A6pZYtGOw@mail.gmail.com>
Subject: Re: [PATCH v1 1/3] Add the latent_entropy gcc plugin
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Mon, May 23, 2016 at 3:15 PM, Emese Revfy <re.emese@gmail.com> wrote:
> This plugin mitigates the problem of the kernel having too little entropy during
> and after boot for generating crypto keys.
>
> It creates a local variable in every marked function. The value of this variable is
> modified by randomly chosen operations (add, xor and rol) and
> random values (gcc generates them at compile time and the stack pointer at runtime).
> It depends on the control flow (e.g., loops, conditions).
>
> Before the function returns the plugin writes this local variable
> into the latent_entropy global variable. The value of this global variable is
> added to the kernel entropy pool in do_one_initcall() and _do_fork().

I'm excited to see this! This looks like it'll help a lot with early
entropy, which is something that'll be a problem for some
architectures that are trying to do early randomish things (e.g. the
heap layout randomization, various canaries, etc).

Do you have any good examples of a before/after case of early
randomness being fixed by this?

> Based on work created by the PaX Team.
>
> Signed-off-by: Emese Revfy <re.emese@gmail.com>
> ---
>  arch/Kconfig                                |  17 ++
>  arch/powerpc/kernel/Makefile                |   8 +-
>  include/linux/random.h                      |   8 +
>  init/main.c                                 |   1 +
>  kernel/fork.c                               |   1 +
>  mm/page_alloc.c                             |   5 +
>  scripts/Makefile.gcc-plugins                |  10 +-
>  scripts/gcc-plugins/Makefile                |   1 +
>  scripts/gcc-plugins/latent_entropy_plugin.c | 446 ++++++++++++++++++++++++++++
>  9 files changed, 491 insertions(+), 6 deletions(-)
>  create mode 100644 scripts/gcc-plugins/latent_entropy_plugin.c
>
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 5feadad..74489df 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -393,6 +393,23 @@ config GCC_PLUGIN_SANCOV
>           gcc-4.5 on). It is based on the commit "Add fuzzing coverage support"
>           by Dmitry Vyukov <dvyukov@google.com>.
>
> +config GCC_PLUGIN_LATENT_ENTROPY
> +       bool "latent entropy"
> +       depends on GCC_PLUGINS
> +       help
> +         By saying Y here the kernel will instrument some kernel code to
> +         extract some entropy from both original and artificially created
> +         program state.  This will help especially embedded systems where
> +         there is little 'natural' source of entropy normally.  The cost
> +         is some slowdown of the boot process and fork and irq processing.

Can "some" be more well quantified?

> +
> +         Note that entropy extracted this way is not known to be cryptographically
> +         secure!

maybe add ", but should be good enough for canaries and other secrets." ?

> +
> +         This plugin was ported from grsecurity/PaX. More information at:
> +          * https://grsecurity.net/
> +          * https://pax.grsecurity.net/
> +
>  config HAVE_CC_STACKPROTECTOR
>         bool
>         help
> diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
> index 2da380f..6c7e448 100644
> --- a/arch/powerpc/kernel/Makefile
> +++ b/arch/powerpc/kernel/Makefile
> @@ -16,10 +16,10 @@ endif
>
>  ifdef CONFIG_FUNCTION_TRACER
>  # Do not trace early boot code
> -CFLAGS_REMOVE_cputable.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
> -CFLAGS_REMOVE_prom_init.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
> -CFLAGS_REMOVE_btext.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
> -CFLAGS_REMOVE_prom.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
> +CFLAGS_REMOVE_cputable.o = -mno-sched-epilog $(CC_FLAGS_FTRACE) $(DISABLE_LATENT_ENTROPY_PLUGIN)
> +CFLAGS_REMOVE_prom_init.o = -mno-sched-epilog $(CC_FLAGS_FTRACE) $(DISABLE_LATENT_ENTROPY_PLUGIN)
> +CFLAGS_REMOVE_btext.o = -mno-sched-epilog $(CC_FLAGS_FTRACE) $(DISABLE_LATENT_ENTROPY_PLUGIN)
> +CFLAGS_REMOVE_prom.o = -mno-sched-epilog $(CC_FLAGS_FTRACE) $(DISABLE_LATENT_ENTROPY_PLUGIN)
>  # do not trace tracer code
>  CFLAGS_REMOVE_ftrace.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
>  # timers used by tracing
> diff --git a/include/linux/random.h b/include/linux/random.h
> index e47e533..379f4bc 100644
> --- a/include/linux/random.h
> +++ b/include/linux/random.h
> @@ -18,6 +18,14 @@ struct random_ready_callback {
>  };
>
>  extern void add_device_randomness(const void *, unsigned int);
> +
> +static inline void add_latent_entropy(void)
> +{
> +#ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
> +       add_device_randomness((const void *)&latent_entropy, sizeof(latent_entropy));
> +#endif
> +}
> +

Traditionally the code style of #ifdef arrangement in header files
uses an "#else" since there's usually other code to wrap in it, and it
results in small future diffs:

#ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
static inline void add_latent_entropy(void)
{
       add_device_randomness((const void *)&latent_entropy,
sizeof(latent_entropy));
}
#else
static inline void add_latent_entropy(void) { }
#endif

Also, does this matter that it's non-atomic? It seems like the u64
below is being written to by multiple threads and even read by
multiple threads. Am I misunderstanding something?

> [...]
> new file mode 100644
> index 0000000..7295c39
> --- /dev/null
> +++ b/scripts/gcc-plugins/latent_entropy_plugin.c

I feel like most of the functions in this plugin could use some more
comments about what each one does.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

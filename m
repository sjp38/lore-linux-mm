Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8F096B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 01:42:41 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id g6-v6so3779067ybc.5
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 22:42:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y14-v6sor773830ybq.108.2018.07.03.22.42.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 22:42:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1530646988-25546-1-git-send-email-crecklin@redhat.com>
References: <1530646988-25546-1-git-send-email-crecklin@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 3 Jul 2018 22:42:38 -0700
Message-ID: <CAGXu5jL9wZ=04h+iRkJLUkqhT70yv+tLPNqPNobaZXNB2Y8T9w@mail.gmail.com>
Subject: Re: [PATCH v7] add param that allows bootline control of hardened usercopy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris von Recklinghausen <crecklin@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, Paolo Abeni <pabeni@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Al Viro <viro@zeniv.linux.org.uk>

On Tue, Jul 3, 2018 at 12:43 PM, Chris von Recklinghausen
<crecklin@redhat.com> wrote:
> Enabling HARDENED_USERCOPY causes measurable regressions in
>  networking performance, up to 8% under UDP flood.
>
> I'm running an a small packet UDP flood using pktgen vs. a host b2b
> connected. On the receiver side the UDP packets are processed by a
> simple user space process that just reads and drops them:
>
> https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c
>
> Not very useful from a functional PoV, but it helps to pin-point
> bottlenecks in the networking stack.
>
> When running a kernel with CONFIG_HARDENED_USERCOPY=y, I see a 5-8%
> regression in the receive tput, compared to the same kernel without
> this option enabled.
>
> With CONFIG_HARDENED_USERCOPY=y, perf shows ~6% of CPU time spent
> cumulatively in __check_object_size (~4%) and __virt_addr_valid (~2%).
>
> The call-chain is:
>
> __GI___libc_recvfrom
> entry_SYSCALL_64_after_hwframe
> do_syscall_64
> __x64_sys_recvfrom
> __sys_recvfrom
> inet_recvmsg
> udp_recvmsg
> __check_object_size
>
> udp_recvmsg() actually calls copy_to_iter() (inlined) and the latters
> calls check_copy_size() (again, inlined).
>
> A generic distro may want to enable HARDENED_USERCOPY in their default
> kernel config, but at the same time, such distro may want to be able to
> avoid the performance penalties in with the default configuration and
> disable the stricter check on a per-boot basis.
>
> This change adds a boot parameter that conditionally disables
> HARDENED_USERCOPY at boot time.
>
> v6->v7:
>         remove EXPORT_SYMBOL(bypass_usercopy_checks);
>         remove mention of CONFIG_JUMP_LABEL from commit comments
> v5->v6:
>         no need to key off of anything - build errors were when jump label
>                 code was in include/linux/thread_info.h.
> v4->v5:
>         key off of CONFIG_JUMP_LABEL, not CONFIG_SMP_BROKEN.
>
> v3->v4:
>         fix a couple of nits in commit comments
>         declaration of bypass_usercopy_checks moved inside mm/usercopy.c and
>                 made static
>         add blurb to commit comments about not enabling this functionality on
>                 platforms with CONFIG_BROKEN_ON_SMP set.
> v2->v3:
>         add benchmark details to commit comments
>         Don't add new item to Documentation/admin-guide/kernel-parameters.rst
>         rename boot param to "hardened_usercopy="
>         update description in Documentation/admin-guide/kernel-parameters.txt
>         static_branch_likely -> static_branch_unlikely
>         add __ro_after_init versions of DEFINE_STATIC_KEY_FALSE,
>                 DEFINE_STATIC_KEY_TRUE
>         disable_huc_atboot -> enable_checks (strtobool "on" == true)
>
> v1->v2:
>         remove CONFIG_HUC_DEFAULT_OFF
>         default is now enabled, boot param disables
>         move check to __check_object_size so as to not break optimization of
>                 __builtin_constant_p()
>         include linux/atomic.h before linux/jump_label.h
>
> Signed-off-by: Chris von Recklinghausen <crecklin@redhat.com>

Thanks, this looks good! I'll get this added to the usercopy tree.

(FYI, the version->version changes normally go under the "---" line.
I'll remove them when I apply this patch, so no need to resend.)

-Kees

> ---
>  .../admin-guide/kernel-parameters.txt         | 11 ++++++++
>  include/linux/jump_label.h                    |  6 +++++
>  mm/usercopy.c                                 | 25 +++++++++++++++++++
>  3 files changed, 42 insertions(+)
>
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index efc7aa7a0670..560d4dc66f02 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -816,6 +816,17 @@
>         disable=        [IPV6]
>                         See Documentation/networking/ipv6.txt.
>
> +       hardened_usercopy=
> +                        [KNL] Under CONFIG_HARDENED_USERCOPY, whether
> +                        hardening is enabled for this boot. Hardened
> +                        usercopy checking is used to protect the kernel
> +                        from reading or writing beyond known memory
> +                        allocation boundaries as a proactive defense
> +                        against bounds-checking flaws in the kernel's
> +                        copy_to_user()/copy_from_user() interface.
> +                on      Perform hardened usercopy checks (default).
> +                off     Disable hardened usercopy checks.
> +
>         disable_radix   [PPC]
>                         Disable RADIX MMU mode on POWER9
>
> diff --git a/include/linux/jump_label.h b/include/linux/jump_label.h
> index b46b541c67c4..1a0b6f17a5d6 100644
> --- a/include/linux/jump_label.h
> +++ b/include/linux/jump_label.h
> @@ -299,12 +299,18 @@ struct static_key_false {
>  #define DEFINE_STATIC_KEY_TRUE(name)   \
>         struct static_key_true name = STATIC_KEY_TRUE_INIT
>
> +#define DEFINE_STATIC_KEY_TRUE_RO(name)        \
> +       struct static_key_true name __ro_after_init = STATIC_KEY_TRUE_INIT
> +
>  #define DECLARE_STATIC_KEY_TRUE(name)  \
>         extern struct static_key_true name
>
>  #define DEFINE_STATIC_KEY_FALSE(name)  \
>         struct static_key_false name = STATIC_KEY_FALSE_INIT
>
> +#define DEFINE_STATIC_KEY_FALSE_RO(name)       \
> +       struct static_key_false name __ro_after_init = STATIC_KEY_FALSE_INIT
> +
>  #define DECLARE_STATIC_KEY_FALSE(name) \
>         extern struct static_key_false name
>
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index e9e9325f7638..852eb4e53f06 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -20,6 +20,8 @@
>  #include <linux/sched/task.h>
>  #include <linux/sched/task_stack.h>
>  #include <linux/thread_info.h>
> +#include <linux/atomic.h>
> +#include <linux/jump_label.h>
>  #include <asm/sections.h>
>
>  /*
> @@ -240,6 +242,8 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
>         }
>  }
>
> +static DEFINE_STATIC_KEY_FALSE_RO(bypass_usercopy_checks);
> +
>  /*
>   * Validates that the given object is:
>   * - not bogus address
> @@ -248,6 +252,9 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
>   */
>  void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>  {
> +       if (static_branch_unlikely(&bypass_usercopy_checks))
> +               return;
> +
>         /* Skip all tests if size is zero. */
>         if (!n)
>                 return;
> @@ -279,3 +286,21 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>         check_kernel_text_object((const unsigned long)ptr, n, to_user);
>  }
>  EXPORT_SYMBOL(__check_object_size);
> +
> +static bool enable_checks __initdata = true;
> +
> +static int __init parse_hardened_usercopy(char *str)
> +{
> +       return strtobool(str, &enable_checks);
> +}
> +
> +__setup("hardened_usercopy=", parse_hardened_usercopy);
> +
> +static int __init set_hardened_usercopy(void)
> +{
> +       if (enable_checks == false)
> +               static_branch_enable(&bypass_usercopy_checks);
> +       return 1;
> +}
> +
> +late_initcall(set_hardened_usercopy);
> --
> 2.17.0
>



-- 
Kees Cook
Pixel Security

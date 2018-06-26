Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 391AB6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 08:53:38 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 5-v6so3651659qta.1
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 05:53:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r23-v6si1449134qtj.405.2018.06.26.05.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 05:53:37 -0700 (PDT)
Subject: Re: [v2 PATCH] add param that allows bootline control of hardened
 usercopy
From: Christoph von Recklinghausen <crecklin@redhat.com>
References: <1530017430-5394-1-git-send-email-crecklin@redhat.com>
Message-ID: <06bde22f-3e28-e6f3-dab0-9bc8bd5973b8@redhat.com>
Date: Tue, 26 Jun 2018 08:53:36 -0400
MIME-Version: 1.0
In-Reply-To: <1530017430-5394-1-git-send-email-crecklin@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, labbott@redhat.com, pabeni@redhat.com, "linux-mm@kvack.org >> Linux-MM" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 06/26/2018 08:50 AM, Chris von Recklinghausen wrote:
> Enabling HARDENED_USER_COPY causes measurable regressions in the
> networking performances, up to 8% under UDP flood.
>
> A generic distro may want to enable HARDENED_USER_COPY in their default
> kernel config, but at the same time, such distro may want to be able to
> avoid the performance penalties in with the default configuration and
> disable the stricter check on a per-boot basis.
>
> This change adds a boot parameter that to conditionally disable
> HARDENED_USERCOPY at boot time.
>
> v1->v2:
> 	remove CONFIG_HUC_DEFAULT_OFF
> 	default is now enabled, boot param disables
> 	move check to __check_object_size so as to not break optimization of
> 		__builtin_constant_p()
> 	include linux/atomic.h before linux/jump_label.h
>
> Signed-off-by: Chris von Recklinghausen <crecklin@redhat.com>
> ---
>  .../admin-guide/kernel-parameters.rst         |  1 +
>  .../admin-guide/kernel-parameters.txt         |  3 +++
>  include/linux/thread_info.h                   |  5 ++++
>  mm/usercopy.c                                 | 27 +++++++++++++++++++
>  4 files changed, 36 insertions(+)
>
> diff --git a/Documentation/admin-guide/kernel-parameters.rst b/Documentation/admin-guide/kernel-parameters.rst
> index b8d0bc07ed0a..87a1200a1db6 100644
> --- a/Documentation/admin-guide/kernel-parameters.rst
> +++ b/Documentation/admin-guide/kernel-parameters.rst
> @@ -100,6 +100,7 @@ parameter is applicable::
>  	FB	The frame buffer device is enabled.
>  	FTRACE	Function tracing enabled.
>  	GCOV	GCOV profiling is enabled.
> +	HUC	Hardened usercopy is enabled
>  	HW	Appropriate hardware is enabled.
>  	IA-64	IA-64 architecture is enabled.
>  	IMA     Integrity measurement architecture is enabled.
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index efc7aa7a0670..d14be0038aed 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -816,6 +816,9 @@
>  	disable=	[IPV6]
>  			See Documentation/networking/ipv6.txt.
>  
> +	disable_hardened_usercopy [HUC]
> +			Disable hardened usercopy checks
> +
>  	disable_radix	[PPC]
>  			Disable RADIX MMU mode on POWER9
>  
> diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
> index 8d8821b3689a..ab24fe2d3f87 100644
> --- a/include/linux/thread_info.h
> +++ b/include/linux/thread_info.h
> @@ -109,6 +109,11 @@ static inline int arch_within_stack_frames(const void * const stack,
>  #endif
>  
>  #ifdef CONFIG_HARDENED_USERCOPY
> +#include <linux/atomic.h>
> +#include <linux/jump_label.h>
> +
> +DECLARE_STATIC_KEY_FALSE(bypass_usercopy_checks);
> +
>  extern void __check_object_size(const void *ptr, unsigned long n,
>  					bool to_user);
>  
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index e9e9325f7638..6a1265e1a54e 100644
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
> @@ -248,6 +250,9 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
>   */
>  void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>  {
> +	if (static_branch_likely(&bypass_usercopy_checks))
> +		return;
> +
>  	/* Skip all tests if size is zero. */
>  	if (!n)
>  		return;
> @@ -279,3 +284,25 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>  	check_kernel_text_object((const unsigned long)ptr, n, to_user);
>  }
>  EXPORT_SYMBOL(__check_object_size);
> +
> +DEFINE_STATIC_KEY_FALSE(bypass_usercopy_checks);
> +EXPORT_SYMBOL(bypass_usercopy_checks);
> +
> +static bool disable_huc_atboot = false;
> +
> +static int __init parse_disable_usercopy(char *str)
> +{
> +	disable_huc_atboot = true;
> +	return 1;
> +}
> +
> +static int __init set_disable_usercopy(void)
> +{
> +	if (disable_huc_atboot == true)
> +		static_branch_enable(&bypass_usercopy_checks);
> +	return 1;
> +}
> +
> +__setup("disable_hardened_usercopy", parse_disable_usercopy);
> +
> +late_initcall(set_disable_usercopy);

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D40C66B0003
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 18:29:13 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 99-v6so5267861qkr.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 15:29:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 22-v6si85155qtx.31.2018.06.25.15.29.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 15:29:12 -0700 (PDT)
Reply-To: crecklin@redhat.com
Subject: Re: [PATCH] add param that allows bootline control of hardened
 usercopy
References: <1529939300-27461-1-git-send-email-crecklin@redhat.com>
 <d110c9af-cb68-5a3c-bc70-0c7650edb0d4@redhat.com>
 <cfd52ae6-6fea-1a5a-b2dd-4dfdd65acd15@redhat.com>
From: Christoph von Recklinghausen <crecklin@redhat.com>
Message-ID: <2e4d9686-835c-f4be-2647-2344899e3cd4@redhat.com>
Date: Mon, 25 Jun 2018 18:29:09 -0400
MIME-Version: 1.0
In-Reply-To: <cfd52ae6-6fea-1a5a-b2dd-4dfdd65acd15@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/25/2018 03:44 PM, Laura Abbott wrote:
> On 06/25/2018 08:22 AM, Christoph von Recklinghausen wrote:
>> Add correct address for linux-mm
>>
>> On 06/25/2018 11:08 AM, Chris von Recklinghausen wrote:
>>> Enabling HARDENED_USER_COPY causes measurable regressions in the
>>> networking performances, up to 8% under UDP flood.
>>>
>>> A generic distro may want to enable HARDENED_USER_COPY in their default
>>> kernel config, but at the same time, such distro may want to be able to
>>> avoid the performance penalties in with the default configuration and
>>> enable the stricter check on a per-boot basis.
>>>
>>> This change adds a config variable and a boot parameter to
>>> conditionally
>>> enable HARDENED_USER_COPY at boot time, and switch HUC to off if
>>> HUC_DEFAULT_OFF is set.
>>>
>>> Signed-off-by: Chris von Recklinghausen <crecklin@redhat.com>
>>> ---
>>> A  .../admin-guide/kernel-parameters.rstA A A A A A A A  |A  2 ++
>>> A  .../admin-guide/kernel-parameters.txtA A A A A A A A  |A  3 ++
>>> A  include/linux/thread_info.hA A A A A A A A A A A A A A A A A A  |A  7 +++++
>>> A  mm/usercopy.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  | 28
>>> +++++++++++++++++++
>>> A  security/KconfigA A A A A A A A A A A A A A A A A A A A A A A A A A A A A  | 10 +++++++
>>> A  5 files changed, 50 insertions(+)
>>>
>>> diff --git a/Documentation/admin-guide/kernel-parameters.rst
>>> b/Documentation/admin-guide/kernel-parameters.rst
>>> index b8d0bc07ed0a..c3035038e3ae 100644
>>> --- a/Documentation/admin-guide/kernel-parameters.rst
>>> +++ b/Documentation/admin-guide/kernel-parameters.rst
>>> @@ -100,6 +100,8 @@ parameter is applicable::
>>> A A A A A  FBA A A  The frame buffer device is enabled.
>>> A A A A A  FTRACEA A A  Function tracing enabled.
>>> A A A A A  GCOVA A A  GCOV profiling is enabled.
>>> +A A A  HUCA A A  Hardened usercopy is enabled
>>> +A A A  HUCFA A A  Hardened usercopy disabled at boot
>>> A A A A A  HWA A A  Appropriate hardware is enabled.
>>> A A A A A  IA-64A A A  IA-64 architecture is enabled.
>>> A A A A A  IMAA A A A  Integrity measurement architecture is enabled.
>>> diff --git a/Documentation/admin-guide/kernel-parameters.txt
>>> b/Documentation/admin-guide/kernel-parameters.txt
>>> index efc7aa7a0670..cd3354bc14d3 100644
>>> --- a/Documentation/admin-guide/kernel-parameters.txt
>>> +++ b/Documentation/admin-guide/kernel-parameters.txt
>>> @@ -816,6 +816,9 @@
>>> A A A A A  disable=A A A  [IPV6]
>>> A A A A A A A A A A A A A  See Documentation/networking/ipv6.txt.
>>> A  +A A A  enable_hardened_usercopy [HUC,HUCF]
>>> +A A A A A A A A A A A  Enable hardened usercopy checks
>>> +
>>> A A A A A  disable_radixA A A  [PPC]
>>> A A A A A A A A A A A A A  Disable RADIX MMU mode on POWER9
>>> A  diff --git a/include/linux/thread_info.h
>>> b/include/linux/thread_info.h
>>> index 8d8821b3689a..140a36cc1c2c 100644
>>> --- a/include/linux/thread_info.h
>>> +++ b/include/linux/thread_info.h
>>> @@ -109,12 +109,19 @@ static inline int
>>> arch_within_stack_frames(const void * const stack,
>>> A  #endif
>>> A  A  #ifdef CONFIG_HARDENED_USERCOPY
>>> +#include <linux/jump_label.h>
>>> +
>>> +DECLARE_STATIC_KEY_FALSE(bypass_usercopy_checks);
>>> +
>>> A  extern void __check_object_size(const void *ptr, unsigned long n,
>>> A A A A A A A A A A A A A A A A A A A A A  bool to_user);
>>> A  A  static __always_inline void check_object_size(const void *ptr,
>>> unsigned long n,
>>> A A A A A A A A A A A A A A A A A A A A A A A A A A A  bool to_user)
>>> A  {
>>> +A A A  if (static_branch_likely(&bypass_usercopy_checks))
>>> +A A A A A A A  return;
>>> +
>>> A A A A A  if (!__builtin_constant_p(n))
>>> A A A A A A A A A  __check_object_size(ptr, n, to_user);
>>> A  }
>>> diff --git a/mm/usercopy.c b/mm/usercopy.c
>>> index e9e9325f7638..ce3996da1b2e 100644
>>> --- a/mm/usercopy.c
>>> +++ b/mm/usercopy.c
>>> @@ -279,3 +279,31 @@ void __check_object_size(const void *ptr,
>>> unsigned long n, bool to_user)
>>> A A A A A  check_kernel_text_object((const unsigned long)ptr, n, to_user);
>>> A  }
>>> A  EXPORT_SYMBOL(__check_object_size);
>>> +
>>> +DEFINE_STATIC_KEY_FALSE(bypass_usercopy_checks);
>>> +EXPORT_SYMBOL(bypass_usercopy_checks);
>>> +
>>> +#ifdef CONFIG_HUC_DEFAULT_OFF
>>> +#define HUC_DEFAULT false
>>> +#else
>>> +#define HUC_DEFAULT true
>>> +#endif
>>> +
>>> +static bool enable_huc_atboot = HUC_DEFAULT;
>>> +
>>> +static int __init parse_enable_usercopy(char *str)
>>> +{
>>> +A A A  enable_huc_atboot = true;
>>> +A A A  return 1;
>>> +}
>>> +
>>> +static int __init set_enable_usercopy(void)
>>> +{
>>> +A A A  if (enable_huc_atboot == false)
>>> +A A A A A A A  static_branch_enable(&bypass_usercopy_checks);
>>> +A A A  return 1;
>>> +}
>>> +
>>> +__setup("enable_hardened_usercopy", parse_enable_usercopy);
>>> +
>>> +late_initcall(set_enable_usercopy);
>>> diff --git a/security/Kconfig b/security/Kconfig
>>> index c4302067a3ad..a6173897b85c 100644
>>> --- a/security/Kconfig
>>> +++ b/security/Kconfig
>>> @@ -189,6 +189,16 @@ config HARDENED_USERCOPY_PAGESPAN
>>> A A A A A A A  been removed. This config is intended to be used only while
>>> A A A A A A A  trying to find such users.
>>> A  +config HUC_DEFAULT_OFF
>>> +A A A  bool "allow CONFIG_HARDENED_USERCOPY to be configured but
>>> disabled"
>>> +A A A  depends on HARDENED_USERCOPY
>>> +A A A  help
>>> +A A A A A  When CONFIG_HARDENED_USERCOPY is enabled, disable its
>>> +A A A A A  functionality unless it is enabled via at boot time
>>> +A A A A A  via the "enable_hardened_usercopy" boot parameter. This allows
>>> +A A A A A  the functionality of hardened usercopy to be present but not
>>> +A A A A A  impact performance unless it is needed.
>>> +
>>> A  config FORTIFY_SOURCE
>>> A A A A A  bool "Harden common str/mem functions against buffer overflows"
>>> A A A A A  depends on ARCH_HAS_FORTIFY_SOURCE
>>
>>
>
> This seems a bit backwards, I'd much rather see hardened user copy
> default to on with the basic config option and then just have a command
> line option to turn it off.
>
> Thanks,
> Laura

I have a small set of customers that want CONFIG_HARDENED_USERCOPY
enabled, and a large number of customers who would be impacted by its
default behavior (before my change).A  The desire was to have the smaller
number of users need to change their boot lines to get the behavior they
wanted. Adding CONFIG_HUC_DEFAULT_OFF was an attempt to preserve the
default behavior of existing users of CONFIG_HARDENED_USERCOPY (default
enabled) and allowing that to coexist with the desires of the greater
number of my customers (default disabled).

If folks think that it's better to have it enabled by default and the
command line option to turn it off I can do that (it is simpler). Does
anyone else have opinions one way or the other?

Thanks,

Chris

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D55B6B0003
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 15:44:27 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w189-v6so5654640oiw.13
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 12:44:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g28-v6sor3066823oti.126.2018.06.25.12.44.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 12:44:26 -0700 (PDT)
Subject: Re: [PATCH] add param that allows bootline control of hardened
 usercopy
References: <1529939300-27461-1-git-send-email-crecklin@redhat.com>
 <d110c9af-cb68-5a3c-bc70-0c7650edb0d4@redhat.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <cfd52ae6-6fea-1a5a-b2dd-4dfdd65acd15@redhat.com>
Date: Mon, 25 Jun 2018 12:44:22 -0700
MIME-Version: 1.0
In-Reply-To: <d110c9af-cb68-5a3c-bc70-0c7650edb0d4@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph von Recklinghausen <crecklin@redhat.com>, keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/25/2018 08:22 AM, Christoph von Recklinghausen wrote:
> Add correct address for linux-mm
> 
> On 06/25/2018 11:08 AM, Chris von Recklinghausen wrote:
>> Enabling HARDENED_USER_COPY causes measurable regressions in the
>> networking performances, up to 8% under UDP flood.
>>
>> A generic distro may want to enable HARDENED_USER_COPY in their default
>> kernel config, but at the same time, such distro may want to be able to
>> avoid the performance penalties in with the default configuration and
>> enable the stricter check on a per-boot basis.
>>
>> This change adds a config variable and a boot parameter to conditionally
>> enable HARDENED_USER_COPY at boot time, and switch HUC to off if
>> HUC_DEFAULT_OFF is set.
>>
>> Signed-off-by: Chris von Recklinghausen <crecklin@redhat.com>
>> ---
>>   .../admin-guide/kernel-parameters.rst         |  2 ++
>>   .../admin-guide/kernel-parameters.txt         |  3 ++
>>   include/linux/thread_info.h                   |  7 +++++
>>   mm/usercopy.c                                 | 28 +++++++++++++++++++
>>   security/Kconfig                              | 10 +++++++
>>   5 files changed, 50 insertions(+)
>>
>> diff --git a/Documentation/admin-guide/kernel-parameters.rst b/Documentation/admin-guide/kernel-parameters.rst
>> index b8d0bc07ed0a..c3035038e3ae 100644
>> --- a/Documentation/admin-guide/kernel-parameters.rst
>> +++ b/Documentation/admin-guide/kernel-parameters.rst
>> @@ -100,6 +100,8 @@ parameter is applicable::
>>   	FB	The frame buffer device is enabled.
>>   	FTRACE	Function tracing enabled.
>>   	GCOV	GCOV profiling is enabled.
>> +	HUC	Hardened usercopy is enabled
>> +	HUCF	Hardened usercopy disabled at boot
>>   	HW	Appropriate hardware is enabled.
>>   	IA-64	IA-64 architecture is enabled.
>>   	IMA     Integrity measurement architecture is enabled.
>> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
>> index efc7aa7a0670..cd3354bc14d3 100644
>> --- a/Documentation/admin-guide/kernel-parameters.txt
>> +++ b/Documentation/admin-guide/kernel-parameters.txt
>> @@ -816,6 +816,9 @@
>>   	disable=	[IPV6]
>>   			See Documentation/networking/ipv6.txt.
>>   
>> +	enable_hardened_usercopy [HUC,HUCF]
>> +			Enable hardened usercopy checks
>> +
>>   	disable_radix	[PPC]
>>   			Disable RADIX MMU mode on POWER9
>>   
>> diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
>> index 8d8821b3689a..140a36cc1c2c 100644
>> --- a/include/linux/thread_info.h
>> +++ b/include/linux/thread_info.h
>> @@ -109,12 +109,19 @@ static inline int arch_within_stack_frames(const void * const stack,
>>   #endif
>>   
>>   #ifdef CONFIG_HARDENED_USERCOPY
>> +#include <linux/jump_label.h>
>> +
>> +DECLARE_STATIC_KEY_FALSE(bypass_usercopy_checks);
>> +
>>   extern void __check_object_size(const void *ptr, unsigned long n,
>>   					bool to_user);
>>   
>>   static __always_inline void check_object_size(const void *ptr, unsigned long n,
>>   					      bool to_user)
>>   {
>> +	if (static_branch_likely(&bypass_usercopy_checks))
>> +		return;
>> +
>>   	if (!__builtin_constant_p(n))
>>   		__check_object_size(ptr, n, to_user);
>>   }
>> diff --git a/mm/usercopy.c b/mm/usercopy.c
>> index e9e9325f7638..ce3996da1b2e 100644
>> --- a/mm/usercopy.c
>> +++ b/mm/usercopy.c
>> @@ -279,3 +279,31 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>>   	check_kernel_text_object((const unsigned long)ptr, n, to_user);
>>   }
>>   EXPORT_SYMBOL(__check_object_size);
>> +
>> +DEFINE_STATIC_KEY_FALSE(bypass_usercopy_checks);
>> +EXPORT_SYMBOL(bypass_usercopy_checks);
>> +
>> +#ifdef CONFIG_HUC_DEFAULT_OFF
>> +#define HUC_DEFAULT false
>> +#else
>> +#define HUC_DEFAULT true
>> +#endif
>> +
>> +static bool enable_huc_atboot = HUC_DEFAULT;
>> +
>> +static int __init parse_enable_usercopy(char *str)
>> +{
>> +	enable_huc_atboot = true;
>> +	return 1;
>> +}
>> +
>> +static int __init set_enable_usercopy(void)
>> +{
>> +	if (enable_huc_atboot == false)
>> +		static_branch_enable(&bypass_usercopy_checks);
>> +	return 1;
>> +}
>> +
>> +__setup("enable_hardened_usercopy", parse_enable_usercopy);
>> +
>> +late_initcall(set_enable_usercopy);
>> diff --git a/security/Kconfig b/security/Kconfig
>> index c4302067a3ad..a6173897b85c 100644
>> --- a/security/Kconfig
>> +++ b/security/Kconfig
>> @@ -189,6 +189,16 @@ config HARDENED_USERCOPY_PAGESPAN
>>   	  been removed. This config is intended to be used only while
>>   	  trying to find such users.
>>   
>> +config HUC_DEFAULT_OFF
>> +	bool "allow CONFIG_HARDENED_USERCOPY to be configured but disabled"
>> +	depends on HARDENED_USERCOPY
>> +	help
>> +	  When CONFIG_HARDENED_USERCOPY is enabled, disable its
>> +	  functionality unless it is enabled via at boot time
>> +	  via the "enable_hardened_usercopy" boot parameter. This allows
>> +	  the functionality of hardened usercopy to be present but not
>> +	  impact performance unless it is needed.
>> +
>>   config FORTIFY_SOURCE
>>   	bool "Harden common str/mem functions against buffer overflows"
>>   	depends on ARCH_HAS_FORTIFY_SOURCE
> 
> 

This seems a bit backwards, I'd much rather see hardened user copy
default to on with the basic config option and then just have a command
line option to turn it off.

Thanks,
Laura

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B77946B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 14:06:58 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so16215881pac.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:06:58 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id gt3si6855779pac.72.2015.12.08.11.06.57
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 11:06:57 -0800 (PST)
Subject: Re: [PATCH 28/34] x86: wire up mprotect_key() system call
References: <20151204011424.8A36E365@viggo.jf.intel.com>
 <20151204011503.2A095839@viggo.jf.intel.com>
 <alpine.DEB.2.11.1512081943270.3595@nanos>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56672A50.4010801@sr71.net>
Date: Tue, 8 Dec 2015 11:06:56 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1512081943270.3595@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, linux-api@vger.kernel.org

On 12/08/2015 10:44 AM, Thomas Gleixner wrote:
> On Thu, 3 Dec 2015, Dave Hansen wrote:
>>  #include <asm-generic/mman.h>
>> diff -puN mm/Kconfig~pkeys-16-x86-mprotect_key mm/Kconfig
>> --- a/mm/Kconfig~pkeys-16-x86-mprotect_key	2015-12-03 16:21:31.114920208 -0800
>> +++ b/mm/Kconfig	2015-12-03 16:21:31.119920435 -0800
>> @@ -679,4 +679,5 @@ config NR_PROTECTION_KEYS
>>  	# Everything supports a _single_ key, so allow folks to
>>  	# at least call APIs that take keys, but require that the
>>  	# key be 0.
>> +	default 16 if X86_INTEL_MEMORY_PROTECTION_KEYS
>>  	default 1
> 
> What happens if I set that to 42?
> 
> I think we want to make this a runtime evaluated thingy. If pkeys are
> compiled in, but the machine does not support it then we don't support
> 16 keys, or do we?

We do have runtime evaluation:

#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ?      \
                             CONFIG_NR_PROTECTION_KEYS : 1)

The config option really just sets the architectural limit for how many
are supported.  So it probably needs a better name at least.  Let me
take a look at getting rid of this config option entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

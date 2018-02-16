Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC8216B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 14:06:32 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id t2so2759324plr.15
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 11:06:32 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 91-v6si6260379ply.413.2018.02.16.11.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 11:06:31 -0800 (PST)
Subject: Re: [PATCH 2/3] x86/mm: introduce __PAGE_KERNEL_GLOBAL
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
 <20180215132055.F341C31E@viggo.jf.intel.com>
 <E0AB2852-C4E0-43D3-ABA7-34117A5516C1@gmail.com>
 <a3dd1676-a2dc-aa02-77ad-51cd3b7a78d5@linux.intel.com>
 <DF43D1DD-42EE-4545-9F54-4BC2395D66EA@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <0f8abc68-1092-1bae-d244-1adbbee455f9@linux.intel.com>
Date: Fri, 16 Feb 2018 11:06:30 -0800
MIME-Version: 1.0
In-Reply-To: <DF43D1DD-42EE-4545-9F54-4BC2395D66EA@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org

On 02/16/2018 10:25 AM, Nadav Amit wrote:
>> +#ifdef CONFIG_PAGE_TABLE_ISOLATION
>> +#define __PAGE_KERNEL_GLOBAL		0
>> +#else
>> +#define __PAGE_KERNEL_GLOBAL		_PAGE_GLOBAL
>> +#endif
> ...
>> --- a/arch/x86/mm/pageattr.c~kpti-no-global-for-kernel-mappings	2018-02-13 15:17:56.148210060 -0800
>> +++ b/arch/x86/mm/pageattr.c	2018-02-13 15:17:56.153210060 -0800
>> @@ -593,7 +593,8 @@ try_preserve_large_page(pte_t *kpte, uns
>> 	 * different bit positions in the two formats.
>> 	 */
>> 	req_prot = pgprot_4k_2_large(req_prot);
>> -	req_prot = pgprot_set_on_present(req_prot, _PAGE_GLOBAL | _PAGE_PSE);
>> +	req_prot = pgprot_set_on_present(req_prot,
>> +			__PAGE_KERNEL_GLOBAL | _PAGE_PSE);
>> 	req_prot = canon_pgprot(req_prot);
> From these chunks, it seems to me as req_prot will not have the global bit
> on when a??noptia?? parameter is provided. What am I missing?

That's a good point.  The current patch does not allow the use of
_PAGE_GLOBAL via _PAGE_KERNEL_GLOBAL when CONFIG_PAGE_TABLE_ISOLATION=y,
but booted with nopti.  It's a simple enough fix.  Logically:

#ifdef CONFIG_PAGE_TABLE_ISOLATION
#define __PAGE_KERNEL_GLOBAL	static_cpu_has(X86_FEATURE_PTI) ?
					0 : _PAGE_GLOBAL
#else
#define __PAGE_KERNEL_GLOBAL	_PAGE_GLOBAL
#endif

But I don't really want to hide that gunk in a macro like that.  It
might make more sense as a static inline.  I'll give that a shot and resent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

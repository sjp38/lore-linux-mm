Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73BFC6B0266
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:12:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v2so3305322pfa.10
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:12:08 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 72si610460pld.794.2017.11.01.15.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 15:12:07 -0700 (PDT)
Subject: Re: [PATCH 03/23] x86, kaiser: disable global pages
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223152.B5D241B2@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012213370.1942@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <dad84c59-dea1-2ad6-b0be-14809426db01@linux.intel.com>
Date: Wed, 1 Nov 2017 15:12:02 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711012213370.1942@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/01/2017 02:18 PM, Thomas Gleixner wrote:
> On Tue, 31 Oct 2017, Dave Hansen wrote:
>> --- a/arch/x86/include/asm/pgtable_types.h~kaiser-prep-disable-global-pages	2017-10-31 15:03:49.314064402 -0700
>> +++ b/arch/x86/include/asm/pgtable_types.h	2017-10-31 15:03:49.323064827 -0700
>> @@ -47,7 +47,12 @@
>>  #define _PAGE_ACCESSED	(_AT(pteval_t, 1) << _PAGE_BIT_ACCESSED)
>>  #define _PAGE_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY)
>>  #define _PAGE_PSE	(_AT(pteval_t, 1) << _PAGE_BIT_PSE)
>> +#ifdef CONFIG_X86_GLOBAL_PAGES
>>  #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
>> +#else
>> +/* We must ensure that kernel TLBs are unusable while in userspace */
>> +#define _PAGE_GLOBAL	(_AT(pteval_t, 0))
>> +#endif
> 
> What you really want to do here is to clear PAGE_GLOBAL in the
> supported_pte_mask. probe_page_size_mask() is the proper place for that.

How does something like this look?  I just remove _PAGE_GLOBAL from the
default __PAGE_KERNEL permissions.

> https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/commit/?h=kaiser-dynamic-414rc6-20171101&id=c9f7109207f87c168a6674a4826a701bd0c7333f

I was a bit worried that if we pull _PAGE_GLOBAL out of
__supported_pte_mask itself, we might not be able to use it for the
shadow entries that map the entry/exit code like Linus suggested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

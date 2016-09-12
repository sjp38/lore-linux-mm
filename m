Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3C356B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 11:41:39 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l64so271250839oif.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 08:41:39 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0059.outbound.protection.outlook.com. [104.47.42.59])
        by mx.google.com with ESMTPS id a127si3558378oii.256.2016.09.12.08.41.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 08:41:38 -0700 (PDT)
Subject: Re: [RFC PATCH v2 12/20] x86: Add support for changing memory
 encryption attribute
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223749.29880.10183.stgit@tlendack-t1.amdoffice.net>
 <20160909172314.ifcteua7nr52mzgs@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <4e423d15-7fe2-450a-05dd-1674bd281124@amd.com>
Date: Mon, 12 Sep 2016 10:41:29 -0500
MIME-Version: 1.0
In-Reply-To: <20160909172314.ifcteua7nr52mzgs@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/09/2016 12:23 PM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:37:49PM -0500, Tom Lendacky wrote:
>> This patch adds support to be change the memory encryption attribute for
>> one or more memory pages.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/cacheflush.h  |    3 +
>>  arch/x86/include/asm/mem_encrypt.h |   13 ++++++
>>  arch/x86/mm/mem_encrypt.c          |   43 +++++++++++++++++++++
>>  arch/x86/mm/pageattr.c             |   75 ++++++++++++++++++++++++++++++++++++
>>  4 files changed, 134 insertions(+)
> 
> ...
> 
>> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
>> index 72c292d..0ba9382 100644
>> --- a/arch/x86/mm/pageattr.c
>> +++ b/arch/x86/mm/pageattr.c
>> @@ -1728,6 +1728,81 @@ int set_memory_4k(unsigned long addr, int numpages)
>>  					__pgprot(0), 1, 0, NULL);
>>  }
>>  
>> +static int __set_memory_enc_dec(struct cpa_data *cpa)
>> +{
>> +	unsigned long addr;
>> +	int numpages;
>> +	int ret;
>> +
>> +	if (*cpa->vaddr & ~PAGE_MASK) {
>> +		*cpa->vaddr &= PAGE_MASK;
>> +
>> +		/* People should not be passing in unaligned addresses */
>> +		WARN_ON_ONCE(1);
> 
> Let's make this more user-friendly:
> 
> 	if (WARN_ONCE(*cpa->vaddr & ~PAGE_MASK, "Misaligned address: 0x%lx\n", *cpa->vaddr))
> 		*cpa->vaddr &= PAGE_MASK;

Will do.

> 
>> +	}
>> +
>> +	addr = *cpa->vaddr;
>> +	numpages = cpa->numpages;
>> +
>> +	/* Must avoid aliasing mappings in the highmem code */
>> +	kmap_flush_unused();
>> +	vm_unmap_aliases();
>> +
>> +	ret = __change_page_attr_set_clr(cpa, 1);
>> +
>> +	/* Check whether we really changed something */
>> +	if (!(cpa->flags & CPA_FLUSHTLB))
>> +		goto out;
>> +
>> +	/*
>> +	 * On success we use CLFLUSH, when the CPU supports it to
>> +	 * avoid the WBINVD.
>> +	 */
>> +	if (!ret && static_cpu_has(X86_FEATURE_CLFLUSH))
>> +		cpa_flush_range(addr, numpages, 1);
>> +	else
>> +		cpa_flush_all(1);
> 
> So if we fail (ret != 0) we do WBINVD unconditionally even if we don't
> have to?

Looking at __change_page_attr_set_clr() isn't it possible for some of
the pages to be changed before an error is encountered since it is
looping?  If so, we may still need to flush. The CPA_FLUSHTLB flag
should take care of a failing case where no attributes have actually
been changed.

Thanks,
Tom

> 
> Don't you want this instead:
> 
>         ret = __change_page_attr_set_clr(cpa, 1);
>         if (ret)
>                 goto out;
> 
>         /* Check whether we really changed something */
>         if (!(cpa->flags & CPA_FLUSHTLB))
>                 goto out;
> 
>         /*
>          * On success we use CLFLUSH, when the CPU supports it to
>          * avoid the WBINVD.
>          */
>         if (static_cpu_has(X86_FEATURE_CLFLUSH))
>                 cpa_flush_range(addr, numpages, 1);
>         else
>                 cpa_flush_all(1);
> 
> out:
>         return ret;
> }
> 
> ?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 901656B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 09:45:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v67so30051929pfv.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 06:45:56 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0048.outbound.protection.outlook.com. [104.47.40.48])
        by mx.google.com with ESMTPS id 1si4834924pam.178.2016.09.14.06.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 06:45:55 -0700 (PDT)
Subject: Re: [RFC PATCH v2 15/20] iommu/amd: AMD IOMMU support for memory
 encryption
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223820.29880.17752.stgit@tlendack-t1.amdoffice.net>
 <20160912114550.nwhtpmncwp22l7vy@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <27bc5c87-3a74-a1ee-55b1-7f19ec9cd6cc@amd.com>
Date: Wed, 14 Sep 2016 08:45:44 -0500
MIME-Version: 1.0
In-Reply-To: <20160912114550.nwhtpmncwp22l7vy@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/12/2016 06:45 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:38:20PM -0500, Tom Lendacky wrote:
>> Add support to the AMD IOMMU driver to set the memory encryption mask if
>> memory encryption is enabled.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/mem_encrypt.h |    2 ++
>>  arch/x86/mm/mem_encrypt.c          |    5 +++++
>>  drivers/iommu/amd_iommu.c          |   10 ++++++++++
>>  3 files changed, 17 insertions(+)
>>
>> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
>> index 384fdfb..e395729 100644
>> --- a/arch/x86/include/asm/mem_encrypt.h
>> +++ b/arch/x86/include/asm/mem_encrypt.h
>> @@ -36,6 +36,8 @@ void __init sme_early_init(void);
>>  /* Architecture __weak replacement functions */
>>  void __init mem_encrypt_init(void);
>>  
>> +unsigned long amd_iommu_get_me_mask(void);
>> +
>>  unsigned long swiotlb_get_me_mask(void);
>>  void swiotlb_set_mem_dec(void *vaddr, unsigned long size);
>>  
>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>> index 6b2e8bf..2f28d87 100644
>> --- a/arch/x86/mm/mem_encrypt.c
>> +++ b/arch/x86/mm/mem_encrypt.c
>> @@ -185,6 +185,11 @@ void __init mem_encrypt_init(void)
>>  	swiotlb_clear_encryption();
>>  }
>>  
>> +unsigned long amd_iommu_get_me_mask(void)
>> +{
>> +	return sme_me_mask;
>> +}
>> +
>>  unsigned long swiotlb_get_me_mask(void)
>>  {
>>  	return sme_me_mask;
>> diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
>> index 96de97a..63995e3 100644
>> --- a/drivers/iommu/amd_iommu.c
>> +++ b/drivers/iommu/amd_iommu.c
>> @@ -166,6 +166,15 @@ struct dma_ops_domain {
>>  static struct iova_domain reserved_iova_ranges;
>>  static struct lock_class_key reserved_rbtree_key;
>>  
>> +/*
>> + * Support for memory encryption. If memory encryption is supported, then an
>> + * override to this function will be provided.
>> + */
>> +unsigned long __weak amd_iommu_get_me_mask(void)
>> +{
>> +	return 0;
>> +}
> 
> So instead of adding a function each time which returns sme_me_mask
> for each user it has, why don't you add a single function which
> returns sme_me_mask in mem_encrypt.c and add an inline in the header
> mem_encrypt.h which returns 0 for the !CONFIG_AMD_MEM_ENCRYPT case.

Currently, mem_encrypt.h only lives in the arch/x86 directory so it
wouldn't be able to be included here without breaking other archs.

> 
> This all is still funny because we access sme_me_mask directly for the
> different KERNEL_* masks but then you're adding an accessor function.

Because this lives outside of the arch/x86 I need to use the weak
function.

> 
> So what you should do instead, IMHO, is either hide sme_me_mask
> altogether and use the accessor functions only (not sure if that would
> work in all cases) or expose sme_me_mask unconditionally and have it be
> 0 if CONFIG_AMD_MEM_ENCRYPT is not enabled so that it just works.
> 
> Or is there a third, more graceful variant?

Is there a better way to do this given the support is only in x86?

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

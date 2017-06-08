Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 58D646B02C3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 09:43:09 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a133so12247436itd.9
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 06:43:09 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0065.outbound.protection.outlook.com. [104.47.32.65])
        by mx.google.com with ESMTPS id m128si5441732iof.91.2017.06.08.06.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 06:43:08 -0700 (PDT)
Subject: Re: [PATCH v6 10/34] x86, x86/mm, x86/xen, olpc: Use __va() against
 just the physical address in cr3
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
 <b15e8924-4069-b5fa-adb2-86c164b1dd36@oracle.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <4a7376fb-abfc-8edd-42b7-38de461ac65e@amd.com>
Date: Thu, 8 Jun 2017 08:42:51 -0500
MIME-Version: 1.0
In-Reply-To: <b15e8924-4069-b5fa-adb2-86c164b1dd36@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, xen-devel <xen-devel@lists.xen.org>

On 6/7/2017 5:06 PM, Boris Ostrovsky wrote:
> On 06/07/2017 03:14 PM, Tom Lendacky wrote:
>> The cr3 register entry can contain the SME encryption bit that indicates
>> the PGD is encrypted.  The encryption bit should not be used when creating
>> a virtual address for the PGD table.
>>
>> Create a new function, read_cr3_pa(), that will extract the physical
>> address from the cr3 register. This function is then used where a virtual
>> address of the PGD needs to be created/used from the cr3 register.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/include/asm/special_insns.h |    9 +++++++++
>>   arch/x86/kernel/head64.c             |    2 +-
>>   arch/x86/mm/fault.c                  |   10 +++++-----
>>   arch/x86/mm/ioremap.c                |    2 +-
>>   arch/x86/platform/olpc/olpc-xo1-pm.c |    2 +-
>>   arch/x86/power/hibernate_64.c        |    2 +-
>>   arch/x86/xen/mmu_pv.c                |    6 +++---
>>   7 files changed, 21 insertions(+), 12 deletions(-)
>>

...

>> diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
>> index 1f386d7..2dc5243 100644
>> --- a/arch/x86/xen/mmu_pv.c
>> +++ b/arch/x86/xen/mmu_pv.c
>> @@ -2022,7 +2022,7 @@ static phys_addr_t __init xen_early_virt_to_phys(unsigned long vaddr)
>>   	pmd_t pmd;
>>   	pte_t pte;
>>   
>> -	pa = read_cr3();
>> +	pa = read_cr3_pa();
>>   	pgd = native_make_pgd(xen_read_phys_ulong(pa + pgd_index(vaddr) *
>>   						       sizeof(pgd)));
>>   	if (!pgd_present(pgd))
>> @@ -2102,7 +2102,7 @@ void __init xen_relocate_p2m(void)
>>   	pt_phys = pmd_phys + PFN_PHYS(n_pmd);
>>   	p2m_pfn = PFN_DOWN(pt_phys) + n_pt;
>>   
>> -	pgd = __va(read_cr3());
>> +	pgd = __va(read_cr3_pa());
>>   	new_p2m = (unsigned long *)(2 * PGDIR_SIZE);
>>   	idx_p4d = 0;
>>   	save_pud = n_pud;
>> @@ -2209,7 +2209,7 @@ static void __init xen_write_cr3_init(unsigned long cr3)
>>   {
>>   	unsigned long pfn = PFN_DOWN(__pa(swapper_pg_dir));
>>   
>> -	BUG_ON(read_cr3() != __pa(initial_page_table));
>> +	BUG_ON(read_cr3_pa() != __pa(initial_page_table));
>>   	BUG_ON(cr3 != __pa(swapper_pg_dir));
>>   
>>   	/*
> 
> 
> (Please copy Xen maintainers when modifying xen-related files.)

Sorry about that, missed adding the Xen maintainers when I added this
change.

> 
> Given that page tables for Xen PV guests are controlled by the
> hypervisor I don't think this change (although harmless) is necessary.

I can back this change out if the Xen maintainers think that's best.

> What may be needed is making sure X86_FEATURE_SME is not set for PV guests.

And that may be something that Xen will need to control through either
CPUID or MSR support for the PV guests.

Thanks,
Tom

> 
> -boris
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

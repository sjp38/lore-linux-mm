Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2965E6B0517
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:02:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y62so2036440pfa.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:02:19 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0053.outbound.protection.outlook.com. [104.47.34.53])
        by mx.google.com with ESMTPS id v80si106622pgb.578.2017.07.11.08.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 08:02:17 -0700 (PDT)
Subject: Re: [PATCH v9 07/38] x86/mm: Remove phys_to_virt() usage in ioremap()
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
 <20170707133925.29711.39301.stgit@tlendack-t1.amdoffice.net>
 <CAMzpN2h=AAF6OVfeGJnf5va2Msmd_BPU5BrVENvs0zGQtRMdzQ@mail.gmail.com>
 <ca43df91-163e-82ce-1d40-c17cfc90e957@amd.com>
 <CAMzpN2gq0TZbgy-3PUixwvL+6ECX5bOdE0XZsLtGFXA+-Embeg@mail.gmail.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <81fbf5db-c42f-cfe6-5d31-d60adbd18f26@amd.com>
Date: Tue, 11 Jul 2017 10:02:05 -0500
MIME-Version: 1.0
In-Reply-To: <CAMzpN2gq0TZbgy-3PUixwvL+6ECX5bOdE0XZsLtGFXA+-Embeg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, the arch/x86 maintainers <x86@kernel.org>, kexec@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, Linux-MM <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On 7/10/2017 11:58 PM, Brian Gerst wrote:
> On Mon, Jul 10, 2017 at 3:50 PM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
>> On 7/8/2017 7:57 AM, Brian Gerst wrote:
>>>
>>> On Fri, Jul 7, 2017 at 9:39 AM, Tom Lendacky <thomas.lendacky@amd.com>
>>> wrote:
>>>>
>>>> Currently there is a check if the address being mapped is in the ISA
>>>> range (is_ISA_range()), and if it is, then phys_to_virt() is used to
>>>> perform the mapping. When SME is active, the default is to add pagetable
>>>> mappings with the encryption bit set unless specifically overridden. The
>>>> resulting pagetable mapping from phys_to_virt() will result in a mapping
>>>> that has the encryption bit set. With SME, the use of ioremap() is
>>>> intended to generate pagetable mappings that do not have the encryption
>>>> bit set through the use of the PAGE_KERNEL_IO protection value.
>>>>
>>>> Rather than special case the SME scenario, remove the ISA range check and
>>>> usage of phys_to_virt() and have ISA range mappings continue through the
>>>> remaining ioremap() path.
>>>>
>>>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>>>> ---
>>>>    arch/x86/mm/ioremap.c |    7 +------
>>>>    1 file changed, 1 insertion(+), 6 deletions(-)
>>>>
>>>> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
>>>> index 4c1b5fd..bfc3e2d 100644
>>>> --- a/arch/x86/mm/ioremap.c
>>>> +++ b/arch/x86/mm/ioremap.c
>>>> @@ -13,6 +13,7 @@
>>>>    #include <linux/slab.h>
>>>>    #include <linux/vmalloc.h>
>>>>    #include <linux/mmiotrace.h>
>>>> +#include <linux/mem_encrypt.h>
>>>>
>>>>    #include <asm/set_memory.h>
>>>>    #include <asm/e820/api.h>
>>>> @@ -106,12 +107,6 @@ static void __iomem
>>>> *__ioremap_caller(resource_size_t phys_addr,
>>>>           }
>>>>
>>>>           /*
>>>> -        * Don't remap the low PCI/ISA area, it's always mapped..
>>>> -        */
>>>> -       if (is_ISA_range(phys_addr, last_addr))
>>>> -               return (__force void __iomem *)phys_to_virt(phys_addr);
>>>> -
>>>> -       /*
>>>>            * Don't allow anybody to remap normal RAM that we're using..
>>>>            */
>>>>           pfn      = phys_addr >> PAGE_SHIFT;
>>>>
>>>
>>> Removing this also affects 32-bit, which is more likely to access
>>> legacy devices in this range.  Put in a check for SME instead
>>
>>
>> I originally had a check for SME here in a previous version of the
>> patch.  Thomas Gleixner recommended removing the check so that the code
>> path was always exercised regardless of the state of SME in order to
>> better detect issues:
>>
>> http://marc.info/?l=linux-kernel&m=149803067811436&w=2
>>
>> Thanks,
>> Tom
> 
> Looking a bit closer, this shortcut doesn't set the caching
> attributes.  So it's probably best to get rid of it anyways.  Also
> note, there is a corresponding check in iounmap().

Good catch.  I'll update the patch to include the removal of the ISA
checks in the iounmap() path as well.

Thanks,
Tom

> 
> --
> Brian Gerst
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A1DCF6B0038
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 14:37:51 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m15so14110794qtg.23
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 11:37:51 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0059.outbound.protection.outlook.com. [104.47.42.59])
        by mx.google.com with ESMTPS id c3si2130393qkh.56.2017.04.06.11.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 11:37:50 -0700 (PDT)
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
 <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
 <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
 <20170317101737.icdois7sdmtutt6b@pd.tnic>
 <f46ff1e1-1cc7-1907-74a0-e2709fa1e5fb@amd.com>
 <20170406172520.iyjjtz56u3jlnjhq@pd.tnic>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <ba739600-d468-1f1b-aff6-89c79fd6030b@amd.com>
Date: Thu, 6 Apr 2017 13:37:41 -0500
MIME-Version: 1.0
In-Reply-To: <20170406172520.iyjjtz56u3jlnjhq@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: brijesh.singh@amd.com, Paolo Bonzini <pbonzini@redhat.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedo.suse.de



On 04/06/2017 12:25 PM, Borislav Petkov wrote:
> Hi Brijesh,
>
> On Thu, Apr 06, 2017 at 09:05:03AM -0500, Brijesh Singh wrote:
>> I looked into arch/x86/mm/init_{32,64}.c and as you pointed the file contains
>> routines to do basic page splitting. I think it sufficient for our usage.
>
> Good :)
>
>> I should be able to drop the memblock patch from the series and update the
>> Patch 15 [1] to use the kernel_physical_mapping_init().
>>
>> The kernel_physical_mapping_init() creates the page table mapping using
>> default KERNEL_PAGE attributes, I tried to extend the function by passing
>> 'bool enc' flags to hint whether to clr or set _PAGE_ENC when splitting the
>> pages. The code did not looked clean hence I dropped that idea.
>
> Or, you could have a
>
> __kernel_physical_mapping_init_prot(..., prot)
>
> helper which gets a protection argument and hands it down. The lower
> levels already hand down prot which is good.
>

I did thought about prot idea but ran into another corner case which may require
us changing the signature of phys_pud_init and phys_pmd_init. The paddr_start
and paddr_end args into kernel_physical_mapping_init() should be aligned on PMD
level down (see comment [1]). So, if we encounter a case where our address range
is part of large page but we need to clear only one entry (i.e asked to clear just
one page into 2M region). In that case, now we need to pass additional arguments
into kernel_physical_mapping, phys_pud_init and phys_pmd_init to hint the splitting
code that it should use our prot for specific entries and all other entries will use
the old_prot.

[1] http://lxr.free-electrons.com/source/arch/x86/mm/init_64.c#L546


> The interface kernel_physical_mapping_init() will then itself call:
>
> 	__kernel_physical_mapping_init_prot(..., PAGE_KERNEL);
>
> for the normal cases.
>
> That in a pre-patch of course.
>
> How does that sound?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

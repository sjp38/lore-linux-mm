Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 728EB6B037C
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 18:38:29 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j24so14667297ioi.0
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 15:38:29 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0048.outbound.protection.outlook.com. [104.47.41.48])
        by mx.google.com with ESMTPS id y64si418230ioy.15.2017.06.08.15.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 15:38:28 -0700 (PDT)
Subject: Re: [PATCH v6 10/34] x86, x86/mm, x86/xen, olpc: Use __va() against
 just the physical address in cr3
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
 <CALCETrVVhMf=zkiDNn_-hKDZLGXKFiwxuWkPmD5RJgHa5VUMiQ@mail.gmail.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <85355c4c-2cc1-daac-d8fe-ac6965b34606@amd.com>
Date: Thu, 8 Jun 2017 17:38:18 -0500
MIME-Version: 1.0
In-Reply-To: <CALCETrVVhMf=zkiDNn_-hKDZLGXKFiwxuWkPmD5RJgHa5VUMiQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, kexec@lists.infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 6/8/2017 1:05 AM, Andy Lutomirski wrote:
> On Wed, Jun 7, 2017 at 12:14 PM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
>> The cr3 register entry can contain the SME encryption bit that indicates
>> the PGD is encrypted.  The encryption bit should not be used when creating
>> a virtual address for the PGD table.
>>
>> Create a new function, read_cr3_pa(), that will extract the physical
>> address from the cr3 register. This function is then used where a virtual
>> address of the PGD needs to be created/used from the cr3 register.
> 
> This is going to conflict with:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/commit/?h=x86/pcid&id=555c81e5d01a62b629ec426a2f50d27e2127c1df
> 
> We're both encountering the fact that CR3 munges the page table PA
> with some other stuff, and some readers want to see the actual CR3
> value and other readers just want the PA.  The thing I prefer about my
> patch is that I get rid of read_cr3() entirely, forcing the patch to
> update every single reader, making review and conflict resolution much
> safer.
> 
> I'd be willing to send a patch tomorrow that just does the split into
> __read_cr3() and read_cr3_pa() (I like your name better) and then we
> can both base on top of it.  Would that make sense?

That makes sense to me.

> 
> Also:
> 
>> +static inline unsigned long read_cr3_pa(void)
>> +{
>> +       return (read_cr3() & PHYSICAL_PAGE_MASK);
>> +}
> 
> Is there any guarantee that the magic encryption bit is masked out in
> PHYSICAL_PAGE_MASK?  The docs make it sound like it could be any bit.
> (But if it's one of the low 12 bits, that would be quite confusing.)

Right now it's bit 47 and we're steering away from any of the currently
reserved bits so we should be safe.

Thanks,
Tom

> 
> --Andy
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

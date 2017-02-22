Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E3AC86B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:42:12 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f21so8822329pgi.4
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 07:42:12 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0042.outbound.protection.outlook.com. [104.47.40.42])
        by mx.google.com with ESMTPS id l4si1535610plk.280.2017.02.22.07.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 07:42:10 -0800 (PST)
Subject: Re: [RFC PATCH v4 08/28] x86: Extend the early_memremap support with
 additional attrs
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154348.19244.11884.stgit@tlendack-t1.amdoffice.net>
 <20170220154354.ggb7yzpjotmbrd5a@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <f9ff9b86-1b6e-d5e6-95f8-89892da52051@amd.com>
Date: Wed, 22 Feb 2017 09:42:02 -0600
MIME-Version: 1.0
In-Reply-To: <20170220154354.ggb7yzpjotmbrd5a@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/20/2017 9:43 AM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:43:48AM -0600, Tom Lendacky wrote:
>> Add to the early_memremap support to be able to specify encrypted and
>
> early_memremap()
>
> Please append "()" to function names in your commit messages text.
>
>> decrypted mappings with and without write-protection. The use of
>> write-protection is necessary when encrypting data "in place". The
>> write-protect attribute is considered cacheable for loads, but not
>> stores. This implies that the hardware will never give the core a
>> dirty line with this memtype.
>
> By "hardware will never give" you mean that WP writes won't land dirty
> in the cache but will go out to mem and when some other core needs them,
> they will have to come from memory?

I think this best explains it, from Table 7-8 of the APM Vol 2:

"Reads allocate cache lines on a cache miss, but only to the shared
state. All writes update main memory. Cache lines are not allocated
on a write miss. Write hits invalidate the cache line and update
main memory."

We're early enough that only the BSP is running and we don't have
to worry about accesses from other cores.  If this was to be used
outside of early boot processing, then some safeties might have to
be added.

>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/Kconfig                     |    4 +++
>>  arch/x86/include/asm/fixmap.h        |   13 ++++++++++
>>  arch/x86/include/asm/pgtable_types.h |    8 ++++++
>>  arch/x86/mm/ioremap.c                |   44 ++++++++++++++++++++++++++++++++++
>>  include/asm-generic/early_ioremap.h  |    2 ++
>>  mm/early_ioremap.c                   |   10 ++++++++
>>  6 files changed, 81 insertions(+)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index a3b8c71..581eae4 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -1417,6 +1417,10 @@ config AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
>>  	  If set to N, then the encryption of system memory can be
>>  	  activated with the mem_encrypt=on command line option.
>>
>> +config ARCH_USE_MEMREMAP_PROT
>> +	def_bool y
>> +	depends on AMD_MEM_ENCRYPT
>
> Why do we need this?
>
> IOW, all those helpers below will end up being defined unconditionally,
> in practice. Think distro kernels. Then saving the couple of bytes is
> not really worth the overhead.

I added this because some other architectures use a u64 for the
protection value instead of an unsigned long (i386 for one) and it
was causing build errors/warnings on those archs. And trying to bring
in the header to use pgprot_t instead of an unsigned long caused a ton
of build issues. This seemed to be the simplest and least intrusive way
to approach the issue.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

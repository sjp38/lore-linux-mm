Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 20A586B03A3
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 10:23:56 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h186so11947476ith.10
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 07:23:56 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0040.outbound.protection.outlook.com. [104.47.32.40])
        by mx.google.com with ESMTPS id f80si1424039pfd.394.2017.04.19.07.23.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 07:23:55 -0700 (PDT)
Subject: Re: [PATCH v5 01/32] x86: Documentation for AMD Secure Memory
 Encryption (SME)
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211625.10190.52568.stgit@tlendack-t1.amdoffice.net>
 <20170419090224.frmv2jhwfwoxvdie@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <bbda868c-9b34-4404-f563-98b000124ac5@amd.com>
Date: Wed, 19 Apr 2017 09:23:47 -0500
MIME-Version: 1.0
In-Reply-To: <20170419090224.frmv2jhwfwoxvdie@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 4/19/2017 4:02 AM, Borislav Petkov wrote:
> Always have a verb in the Subject to form a "do this" or "do that"
> sentence to better explain what the patch does:
>
> "Subject: [PATCH v5 01/32] x86: Add documentation for AMD Secure Memory Encryption (SME)"

Will do.

Btw, I tried to update all the subjects and descriptions to be
more descriptive but I'm sure there is still room for improvement
so keep the comments on them coming.

>
> On Tue, Apr 18, 2017 at 04:16:25PM -0500, Tom Lendacky wrote:
>> Create a Documentation entry to describe the AMD Secure Memory
>> Encryption (SME) feature and add documentation for the mem_encrypt=
>> kernel parameter.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  Documentation/admin-guide/kernel-parameters.txt |   11 ++++
>>  Documentation/x86/amd-memory-encryption.txt     |   60 +++++++++++++++++++++++
>>  2 files changed, 71 insertions(+)
>>  create mode 100644 Documentation/x86/amd-memory-encryption.txt
>>
>> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
>> index 3dd6d5d..84c5787 100644
>> --- a/Documentation/admin-guide/kernel-parameters.txt
>> +++ b/Documentation/admin-guide/kernel-parameters.txt
>> @@ -2165,6 +2165,17 @@
>>  			memory contents and reserves bad memory
>>  			regions that are detected.
>>
>> +	mem_encrypt=	[X86-64] AMD Secure Memory Encryption (SME) control
>> +			Valid arguments: on, off
>> +			Default (depends on kernel configuration option):
>> +			  on  (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=y)
>> +			  off (CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT=n)
>> +			mem_encrypt=on:		Activate SME
>> +			mem_encrypt=off:	Do not activate SME
>> +
>> +			Refer to Documentation/x86/amd-memory-encryption.txt
>> +			for details on when memory encryption can be activated.
>> +
>>  	mem_sleep_default=	[SUSPEND] Default system suspend mode:
>>  			s2idle  - Suspend-To-Idle
>>  			shallow - Power-On Suspend or equivalent (if supported)
>> diff --git a/Documentation/x86/amd-memory-encryption.txt b/Documentation/x86/amd-memory-encryption.txt
>> new file mode 100644
>> index 0000000..0b72ff2
>> --- /dev/null
>> +++ b/Documentation/x86/amd-memory-encryption.txt
>> @@ -0,0 +1,60 @@
>> +Secure Memory Encryption (SME) is a feature found on AMD processors.
>> +
>> +SME provides the ability to mark individual pages of memory as encrypted using
>> +the standard x86 page tables.  A page that is marked encrypted will be
>> +automatically decrypted when read from DRAM and encrypted when written to
>> +DRAM.  SME can therefore be used to protect the contents of DRAM from physical
>> +attacks on the system.
>> +
>> +A page is encrypted when a page table entry has the encryption bit set (see
>> +below on how to determine its position).  The encryption bit can be specified
>> +in the cr3 register, allowing the PGD table to be encrypted. Each successive
>
> I missed that the last time: do you mean here, "The encryption bit can
> be specified in the %cr3 register allowing for the page table hierarchy
> itself to be encrypted."?
>
>> +level of page tables can also be encrypted.
>
> Right, judging by the next sentence, it looks like it.

Correct. I like the hierarchy term so I'll add that to the text.

Note, just because the bit is set in %cr3 doesn't mean the full
hierarchy is encrypted. Each level in the hierarchy needs to have the
encryption bit set. So, theoretically, you could have the encryption
bit set in %cr3 so that the PGD is encrypted, but not set the encryption
bit in the PGD entry for a PUD and so the PUD pointed to by that entry
would not be encrypted.

Thanks,
Tom

>
> The rest looks and reads really nice to me, so feel free to add:
>
> Reviewed-by: Borislav Petkov <bp@suse.de>
>
> after addressing those minor nitpicks on your next submission.
>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEAF36B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 16:27:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p29so18262093pgn.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 13:27:08 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0052.outbound.protection.outlook.com. [104.47.32.52])
        by mx.google.com with ESMTPS id c32si2919955plj.171.2017.05.17.13.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 May 2017 13:27:07 -0700 (PDT)
Subject: Re: [PATCH v5 18/32] x86, mpparse: Use memremap to map the mpf and
 mpc data
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211930.10190.62640.stgit@tlendack-t1.amdoffice.net>
 <20170516083658.fq2h4ysmrbgn23cs@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <6e155b8f-b691-2ee0-8977-969aaab6199a@amd.com>
Date: Wed, 17 May 2017 15:26:58 -0500
MIME-Version: 1.0
In-Reply-To: <20170516083658.fq2h4ysmrbgn23cs@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/16/2017 3:36 AM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:19:30PM -0500, Tom Lendacky wrote:
>> The SMP MP-table is built by UEFI and placed in memory in a decrypted
>> state. These tables are accessed using a mix of early_memremap(),
>> early_memunmap(), phys_to_virt() and virt_to_phys(). Change all accesses
>> to use early_memremap()/early_memunmap(). This allows for proper setting
>> of the encryption mask so that the data can be successfully accessed when
>> SME is active.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/kernel/mpparse.c |  102 +++++++++++++++++++++++++++++++--------------
>>  1 file changed, 71 insertions(+), 31 deletions(-)
>>
>> diff --git a/arch/x86/kernel/mpparse.c b/arch/x86/kernel/mpparse.c
>> index fd37f39..afbda41d 100644
>> --- a/arch/x86/kernel/mpparse.c
>> +++ b/arch/x86/kernel/mpparse.c
>> @@ -429,7 +429,21 @@ static inline void __init construct_default_ISA_mptable(int mpc_default_type)
>>  	}
>>  }
>>
>> -static struct mpf_intel *mpf_found;
>> +static unsigned long mpf_base;
>> +
>> +static void __init unmap_mpf(struct mpf_intel *mpf)
>> +{
>> +	early_memunmap(mpf, sizeof(*mpf));
>> +}
>> +
>> +static struct mpf_intel * __init map_mpf(unsigned long paddr)
>> +{
>> +	struct mpf_intel *mpf;
>> +
>> +	mpf = early_memremap(paddr, sizeof(*mpf));
>> +
>> +	return mpf;
>
> 	return early_memremap(paddr, sizeof(*mpf));
>

Ok.

> ...
>
>> @@ -842,25 +873,26 @@ static int __init update_mp_table(void)
>>  	if (!enable_update_mptable)
>>  		return 0;
>>
>> -	mpf = mpf_found;
>> -	if (!mpf)
>> +	if (!mpf_base)
>>  		return 0;
>>
>> +	mpf = map_mpf(mpf_base);
>> +
>>  	/*
>>  	 * Now see if we need to go further.
>>  	 */
>>  	if (mpf->feature1 != 0)
>
> You're kidding, right? map_mpf() *can* return NULL.

Ugh...  don't know how I forgot about that. Will fix everywhere.

>
> Also, simplify that test:
>
> 	if (mpf->feature1)
> 		...

Ok, I can do that but I hope no one says anything about it being
unrelated to the patch. :)

>
>
>> -		return 0;
>> +		goto do_unmap_mpf;
>>
>>  	if (!mpf->physptr)
>> -		return 0;
>> +		goto do_unmap_mpf;
>>
>> -	mpc = phys_to_virt(mpf->physptr);
>> +	mpc = map_mpc(mpf->physptr);
>
> Again: error checking !!!
>
> You have other calls to early_memremap()/map_mpf() in this patch. Please
> add error checking everywhere.

Yup.

>
>>
>>  	if (!smp_check_mpc(mpc, oem, str))
>> -		return 0;
>> +		goto do_unmap_mpc;
>>
>> -	pr_info("mpf: %llx\n", (u64)virt_to_phys(mpf));
>> +	pr_info("mpf: %llx\n", (u64)mpf_base);
>>  	pr_info("physptr: %x\n", mpf->physptr);
>>
>>  	if (mpc_new_phys && mpc->length > mpc_new_length) {
>> @@ -878,21 +910,23 @@ static int __init update_mp_table(void)
>>  		new = mpf_checksum((unsigned char *)mpc, mpc->length);
>>  		if (old == new) {
>>  			pr_info("mpc is readonly, please try alloc_mptable instead\n");
>> -			return 0;
>> +			goto do_unmap_mpc;
>>  		}
>>  		pr_info("use in-position replacing\n");
>>  	} else {
>>  		mpf->physptr = mpc_new_phys;
>> -		mpc_new = phys_to_virt(mpc_new_phys);
>> +		mpc_new = map_mpc(mpc_new_phys);
>
> Ditto.
>
>>  		memcpy(mpc_new, mpc, mpc->length);
>> +		unmap_mpc(mpc);
>>  		mpc = mpc_new;
>>  		/* check if we can modify that */
>>  		if (mpc_new_phys - mpf->physptr) {
>>  			struct mpf_intel *mpf_new;
>>  			/* steal 16 bytes from [0, 1k) */
>>  			pr_info("mpf new: %x\n", 0x400 - 16);
>> -			mpf_new = phys_to_virt(0x400 - 16);
>> +			mpf_new = map_mpf(0x400 - 16);
>
> Ditto.
>
>>  			memcpy(mpf_new, mpf, 16);
>> +			unmap_mpf(mpf);
>>  			mpf = mpf_new;
>>  			mpf->physptr = mpc_new_phys;
>>  		}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7869C6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 10:05:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v26so3295172pfa.0
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 07:05:53 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0076.outbound.protection.outlook.com. [104.47.42.76])
        by mx.google.com with ESMTPS id p129si1593432pga.260.2017.06.28.07.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 07:05:52 -0700 (PDT)
Subject: Re: [PATCH v8 RESEND 27/38] iommu/amd: Allow the AMD IOMMU to work
 with memory encryption
References: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
 <20170627151230.17428.75281.stgit@tlendack-t1.amdoffice.net>
 <20170628093627.GD14532@8bytes.org>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <03a9d0f5-1f0e-ca0c-78a4-c3a7242f6935@amd.com>
Date: Wed, 28 Jun 2017 09:05:44 -0500
MIME-Version: 1.0
In-Reply-To: <20170628093627.GD14532@8bytes.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On 6/28/2017 4:36 AM, Joerg Roedel wrote:
> Hi Tom,

Hi Joerg,

> 
> On Tue, Jun 27, 2017 at 10:12:30AM -0500, Tom Lendacky wrote:
>> ---
>>   drivers/iommu/amd_iommu.c       |   30 ++++++++++++++++--------------
>>   drivers/iommu/amd_iommu_init.c  |   34 ++++++++++++++++++++++++++++------
>>   drivers/iommu/amd_iommu_proto.h |   10 ++++++++++
>>   drivers/iommu/amd_iommu_types.h |    2 +-
>>   4 files changed, 55 insertions(+), 21 deletions(-)
> 
> Looks like a straightforward change. Just one nit below.
> 
>> +static bool amd_iommu_supports_sme(void)
>> +{
>> +	if (!sme_active() || (boot_cpu_data.x86 != 0x17))
>> +		return true;
>> +
>> +	/* For Fam17h, a specific level of support is required */
>> +	if (boot_cpu_data.microcode >= 0x08001205)
>> +		return true;
>> +
>> +	if ((boot_cpu_data.microcode >= 0x08001126) &&
>> +	    (boot_cpu_data.microcode <= 0x080011ff))
>> +		return true;
>> +
>> +	pr_notice("AMD-Vi: IOMMU not currently supported when SME is active\n");
>> +
>> +	return false;
>> +}
> 
> The name of the function is misleading. It checks whether the IOMMU can
> be enabled when SME is active. But the name suggests that it checks
> whether the iommu hardware supports SME.
> 
> How about renaming it to amd_iommu_sme_check()?

Can do.

Thanks,
Tom

> 
> With that change the patch is:
> 
> 	Acked-by: Joerg Roedel <jroedel@suse.de>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF9606B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 11:46:08 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id n21-v6so2465256plp.9
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:46:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id i61-v6si11001184plb.138.2018.07.24.08.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 08:46:07 -0700 (PDT)
Subject: Re: [PATCH v6 11/13] x86/mm/pat: Prepare {reserve, free}_memtype()
 for "decoy" addresses
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153154382700.34503.10197588570935341739.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180724073641.GA15984@gmail.com>
From: Dave Jiang <dave.jiang@intel.com>
Message-ID: <896ea559-8fe5-9b2a-e763-407fae55cc01@intel.com>
Date: Tue, 24 Jul 2018 08:46:06 -0700
MIME-Version: 1.0
In-Reply-To: <20180724073641.GA15984@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Dan Williams <dan.j.williams@intel.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-nvdimm@lists.01.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, hch@lst.de, linux-edac@vger.kernel.org



On 07/24/2018 12:36 AM, Ingo Molnar wrote:
> 
> * Dan Williams <dan.j.williams@intel.com> wrote:
> 
>> In preparation for using set_memory_uc() instead set_memory_np() for
>> isolating poison from speculation, teach the memtype code to sanitize
>> physical addresses vs __PHYSICAL_MASK.
>>
>> The motivation for using set_memory_uc() for this case is to allow
>> ongoing access to persistent memory pages via the pmem-driver +
>> memcpy_mcsafe() until the poison is repaired.
>>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: "H. Peter Anvin" <hpa@zytor.com>
>> Cc: Tony Luck <tony.luck@intel.com>
>> Cc: Borislav Petkov <bp@alien8.de>
>> Cc: <linux-edac@vger.kernel.org>
>> Cc: <x86@kernel.org>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  arch/x86/mm/pat.c |   16 ++++++++++++++++
>>  1 file changed, 16 insertions(+)
>>
>> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
>> index 1555bd7d3449..6788ffa990f8 100644
>> --- a/arch/x86/mm/pat.c
>> +++ b/arch/x86/mm/pat.c
>> @@ -512,6 +512,17 @@ static int free_ram_pages_type(u64 start, u64 end)
>>  	return 0;
>>  }
>>  
>> +static u64 sanitize_phys(u64 address)
>> +{
>> +	/*
>> +	 * When changing the memtype for pages containing poison allow
>> +	 * for a "decoy" virtual address (bit 63 clear) passed to
>> +	 * set_memory_X(). __pa() on a "decoy" address results in a
>> +	 * physical address with it 63 set.
>> +	 */
>> +	return address & __PHYSICAL_MASK;
> 
> s/it/bit

Thanks Ingo! I'll update when I pull in the patch.

> 
> Thanks,
> 
> 	Ingo
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 

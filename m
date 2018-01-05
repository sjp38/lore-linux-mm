Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 666476B04CD
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 16:07:06 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 34so3751285plm.23
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 13:07:06 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d8si3998498pgc.558.2018.01.05.13.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 13:07:05 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
 <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
 <282e2a56-ded1-6eb9-5ecb-22858c424bd7@linux.intel.com>
 <nycvar.YFH.7.76.1801052014050.11852@cbobk.fhfr.pm>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <868196c9-52ed-4270-968f-97b7a6784f61@linux.intel.com>
Date: Fri, 5 Jan 2018 13:07:03 -0800
MIME-Version: 1.0
In-Reply-To: <nycvar.YFH.7.76.1801052014050.11852@cbobk.fhfr.pm>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On 01/05/2018 11:17 AM, Jiri Kosina wrote:
> On Fri, 5 Jan 2018, Dave Hansen wrote:
> 
>>> --- a/arch/x86/platform/efi/efi_64.c
>>> +++ b/arch/x86/platform/efi/efi_64.c
>>> @@ -95,6 +95,12 @@ pgd_t * __init efi_call_phys_prolog(void
>>>  		save_pgd[pgd] = *pgd_offset_k(pgd * PGDIR_SIZE);
>>>  		vaddress = (unsigned long)__va(pgd * PGDIR_SIZE);
>>>  		set_pgd(pgd_offset_k(pgd * PGDIR_SIZE), *pgd_offset_k(vaddress));
>>> +		/*
>>> +		 * pgprot API doesn't clear it for PGD
>>> +		 *
>>> +		 * Will be brought back automatically in _epilog()
>>> +		 */
>>> +		pgd_offset_k(pgd * PGDIR_SIZE)->pgd &= ~_PAGE_NX;
>>>  	}
>>>  	__flush_tlb_all();
>>
>> Wait a sec...  Where does the _PAGE_USER come from?  Shouldn't we see
>> the &init_mm in there and *not* set _PAGE_USER?
> 
> That's because pgd_populate() uses _PAGE_TABLE and not _KERNPG_TABLE for 
> reasons that are behind me.
> 
> I did put this on my TODO list, but for later.
> 
> (and yes, I tried clearing _PAGE_USER from init_mm's PGD, and no obvious 
> breakages appeared, but I wanted to give it more thought later).

Feel free to add my Ack on this.  I'd personally much rather muck with
random relatively unused bits of the efi code than touch the core PGD code.

We need to go look at it again in the 4.16 timeframe, probably.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

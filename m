Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 809D46B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 09:56:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d2so5301479pfh.7
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 06:56:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n38si1258279qte.478.2017.10.06.06.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 06:56:40 -0700 (PDT)
Subject: Re: [PATCH] mm: deferred_init_memmap improvements
References: <20171004152902.17300-1-pasha.tatashin@oracle.com>
 <071d574f-1d8c-5be9-ec92-6227db01bbd3@linux.vnet.ibm.com>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <0a836d3f-1a0c-8a9e-f4b2-eeb72a08a3e3@oracle.com>
Date: Fri, 6 Oct 2017 09:55:49 -0400
MIME-Version: 1.0
In-Reply-To: <071d574f-1d8c-5be9-ec92-6227db01bbd3@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Anshuman,

Thank you very much for looking at this. My reply below::

On 10/06/2017 02:48 AM, Anshuman Khandual wrote:
> On 10/04/2017 08:59 PM, Pavel Tatashin wrote:
>> This patch fixes another existing issue on systems that have holes in
>> zones i.e CONFIG_HOLES_IN_ZONE is defined.
>>
>> In for_each_mem_pfn_range() we have code like this:
>>
>> if (!pfn_valid_within(pfn)
>> 	goto free_range;
>>
>> Note: 'page' is not set to NULL and is not incremented but 'pfn' advances.
> 
> page is initialized to NULL at the beginning of the function.

Yes, it is initialized to NULL but at the beginning of 
for_each_mem_pfn_range() loop

> PFN advances but we dont proceed unless pfn_valid_within(pfn)
> holds true which basically should have checked with arch call
> back if the PFN is valid in presence of memory holes as well.
> Is not this correct ?

Correct, if pfn_valid_within() is false we jump to the "goto 
free_range;", which is at the end of for (; pfn < end_pfn; pfn++) loop, 
so we are not jumping outside of this loop.

> 
>> Thus means if deferred struct pages are enabled on systems with these kind
>> of holes, linux would get memory corruptions. I have fixed this issue by
>> defining a new macro that performs all the necessary operations when we
>> free the current set of pages.
> 
> If we bail out in case PFN is not valid, then how corruption
> can happen ?
> 

We are not bailing out. We continue next iteration with next pfn, but 
page is not incremented.

Please let me know if I am missing something.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

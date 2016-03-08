Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C3039828E1
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 16:00:38 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj10so20635123pad.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 13:00:38 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id xy2si6998581pab.48.2016.03.08.13.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 13:00:36 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <56DDED63.8010302@oracle.com>
 <20160308.145748.1648298790157991002.davem@davemloft.net>
 <56DF330B.2010600@oracle.com>
 <20160308.152746.1746115669072714849.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56DF3D4E.3090501@oracle.com>
Date: Tue, 8 Mar 2016 13:59:58 -0700
MIME-Version: 1.0
In-Reply-To: <20160308.152746.1746115669072714849.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: dave.hansen@linux.intel.com, luto@amacapital.net, rob.gardner@oracle.com, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/08/2016 01:27 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Tue, 8 Mar 2016 13:16:11 -0700
>
>> On 03/08/2016 12:57 PM, David Miller wrote:
>>> From: Khalid Aziz <khalid.aziz@oracle.com>
>>> Date: Mon, 7 Mar 2016 14:06:43 -0700
>>>
>>>> Good questions. Isn't set of valid VAs already constrained by VA_BITS
>>>> (set to 44 in arch/sparc/include/asm/processor_64.h)? As I see it we
>>>> are already not using the top 4 bits. Please correct me if I am wrong.
>>>
>>> Another limiting constraint is the number of address bits coverable by
>>> the 4-level page tables we use.  And this is sign extended so we have
>>> a top-half and a bottom-half with a "hole" in the center of the VA
>>> space.
>>>
>>> I want some clarification on the top bits during ADI accesses.
>>>
>>> If ADI is enabled, then the top bits of the virtual address are
>>> intepreted as tag bits.  Once "verified" with the ADI settings, what
>>> happense to these tag bits?  Are they dropped from the virtual address
>>> before being passed down the TLB et al. for translations?
>>
>> Bits 63-60 (tag bits) are dropped from the virtual address before
>> being passed down the TLB for translation when PSTATE.mcde = 1.
>
> Ok and you said that values 15 and 0 are special.
>
> I'm just wondering if this means you can't really use ADI mappings in
> the top half of the 64-bit address space.  If the bits are dropped, they
> will be zero, but they need to be all 1's for the top-half of the VA
> space since it's sign extended.
>

According to the manual when PSTATE.mcde=1, bits 63:60 of the virtual 
address of any load or store (using virtual address) are masked before 
being sent to memory system which includes MMU. Hardware TSB walker 
masks bits 63:60 and then sign extends from bit 59 before generating TSB 
pointer and before comparison to TSB TTE VAs but the virtual address in 
the TTE tag that is written to DTLB is masked and not sign extended. 
Manual also states that for implementations that fully support 60 bits 
or more of virtual address, they must sign-extend virtual address in TSB 
TTE tag.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

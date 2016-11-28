Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E12E06B0253
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:00:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so374129907pgx.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:00:12 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id 44si27311994plc.225.2016.11.28.09.00.11
        for <linux-mm@kvack.org>;
        Mon, 28 Nov 2016 09:00:11 -0800 (PST)
Subject: Re: [PATCH] proc: mm: export PTE sizes directly in smaps (v2)
References: <20161117002851.C7BACB98@viggo.jf.intel.com>
 <5837B774.6060604@linux.vnet.ibm.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <4e792e57-c34c-1609-f637-33cf3b136851@sr71.net>
Date: Mon, 28 Nov 2016 09:00:10 -0800
MIME-Version: 1.0
In-Reply-To: <5837B774.6060604@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org
Cc: hch@lst.de, akpm@linux-foundation.org, dan.j.williams@intel.com, linux-mm@kvack.org

On 11/24/2016 08:00 PM, Anshuman Khandual wrote:
...
>> The current mechanisms work fine when we have one or two page sizes.
>> But, they start to get a bit muddled when we mix page sizes inside
>> one VMA.  For instance, the DAX folks were proposing adding a set of
>> fields like:
> 
> So DAX is only case which creates this scenario of multi page sizes in
> the same VMA ? Is there any cases other than DAX mapping ?

Both file and anonymous huge pages.  No other ones in the core VM that I
can think of.

>> 	DevicePages:
>> 	DeviceHugePages:
>> 	DeviceGiganticPages:
>> 	DeviceGinormousPages:
> 
> I guess these are the page sizes supported at PTE, PMD, PUD, PGD level.
> Are all these page sizes supported right now or we are just creating
> place holder for future.

I know there are patches for PUD level support in DAX, but I don't think
they're merged yet.  There is definitely *not* support for PGD level
since we don't have such support in hardware on x86 as far as I know.

>> SwapPss:               0 kB
>> KernelPageSize:        4 kB
>> MMUPageSize:           4 kB
>> Locked:                0 kB
>> Ptes@4kB:	      32 kB
>> Ptes@2MB:	    2048 kB
> 
> So in the left column we are explicitly indicating the size of the PTE
> and expect the user to figure out where it can really be either at PTE,
> PMD, PUD etc. Thats little bit different that 'AnonHugePages' or the
> Shared_HugeTLB/Private_HugeTLB pages which we know are the the PMD/PUD
> level.

Yeah, it's a little different from what we have.

>> The format I used here should be unlikely to break smaps parsers
>> unless they're looking for "kB" and now match the 'Ptes@4kB' instead
>> of the one at the end of the line.
> 
> Right. So you are dropping the idea to introduce these fields as you
> mentioned before for DAX mappings.
> 
>  	DevicePages:
>  	DeviceHugePages:
>  	DeviceGiganticPages:
>  	DeviceGinormousPages:

Right.  We don't need those if we have this patch.

>>  	if (page) {
>>  		int mapcount = page_mapcount(page);
>> +		unsigned long hpage_size = huge_page_size(hstate_vma(vma));
>>
>> +		mss->rss_pud += hpage_size;
>>  		if (mapcount >= 2)
>> -			mss->shared_hugetlb += huge_page_size(hstate_vma(vma));
>> +			mss->shared_hugetlb += hpage_size;
>>  		else
>> -			mss->private_hugetlb += huge_page_size(hstate_vma(vma));
>> +			mss->private_hugetlb += hpage_size;
>>  	}
>>  	return 0;
> 
> Hmm, is this related to these new changes ? The replacement of 'hpage_size'
> instead of huge_page_size(hstate_vma(vma)) can be done in a separate patch.

Yes, this is theoretically unrelated, but I'm not breaking this 3-line
change up into a different patch unless there's a pretty good reason reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

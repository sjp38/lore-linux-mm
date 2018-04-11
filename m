Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 272906B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 11:48:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e9so1024368pfn.16
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 08:48:28 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g74si1084096pfd.351.2018.04.11.08.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 08:48:26 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
References: <20180228032657.32385-1-bhe@redhat.com>
 <20180228032657.32385-5-bhe@redhat.com>
 <5dd3942a-cf66-f749-b1c6-217b0c3c94dc@intel.com>
 <20180408082038.GB19345@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7cc53287-4570-84d6-502c-c3dfbd279b78@intel.com>
Date: Wed, 11 Apr 2018 08:48:25 -0700
MIME-Version: 1.0
In-Reply-To: <20180408082038.GB19345@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 04/08/2018 01:20 AM, Baoquan He wrote:
> On 04/06/18 at 07:50am, Dave Hansen wrote:
>> The code looks fine to me.  It's a bit of a shame that there's no
>> verification to ensure that idx_present never goes beyond the shiny new
>> nr_present_sections. 
> 
> This is a good point. Do you think it's OK to replace (section_nr <
> NR_MEM_SECTIONS) with (section_nr < nr_present_sections) in below
> for_each macro? This for_each_present_section_nr() is only used
> during sparse_init() execution.
> 
> #define for_each_present_section_nr(start, section_nr)          \
>         for (section_nr = next_present_section_nr(start-1);     \
>              ((section_nr >= 0) &&                              \
>               (section_nr < NR_MEM_SECTIONS) &&                 \                                                                                 
>               (section_nr <= __highest_present_section_nr));    \
>              section_nr = next_present_section_nr(section_nr))

I was more concerned about the loops that "consume" the section maps.
It seems like they might run over the end of the array.

>>> @@ -583,6 +592,7 @@ void __init sparse_init(void)
>>>  	unsigned long *usemap;
>>>  	unsigned long **usemap_map;
>>>  	int size;
>>> +	int idx_present = 0;
>>
>> I wonder whether idx_present is a good name.  Isn't it the number of
>> consumed mem_map[]s or usemaps?
> 
> Yeah, in sparse_init(), it's the index of present memory sections, and
> also the number of consumed mem_map[]s or usemaps. And I remember you
> suggested nr_consumed_maps instead. seems nr_consumed_maps is a little
> long to index array to make code line longer than 80 chars. How about
> name it idx_present in sparse_init(), nr_consumed_maps in
> alloc_usemap_and_memmap(), the maps allocation function? I am also fine
> to use nr_consumed_maps for all of them.

Does the large array index make a bunch of lines wrap or something?  If
not, I'd just use the long name.

>>>  		if (!map) {
>>>  			ms->section_mem_map = 0;
>>> +			idx_present++;
>>>  			continue;
>>>  		}
>>>  
>>
>>
>> This hunk seems logically odd to me.  I would expect a non-used section
>> to *not* consume an entry from the temporary array.  Why does it?  The
>> error and success paths seem to do the same thing.
> 
> Yes, this place is the hardest to understand. The temorary arrays are
> allocated beforehand with the size of 'nr_present_sections'. The error
> paths you mentioned is caused by allocation failure of mem_map or
> map_map, but whatever it's error or success paths, the sections must be
> marked as present in memory_present(). Error or success paths happened
> in alloc_usemap_and_memmap(), while checking if it's erorr or success
> paths happened in the last for_each_present_section_nr() of
> sparse_init(), and clear the ms->section_mem_map if it goes along error
> paths. This is the key point of this new allocation way.

I think you owe some commenting because this is so hard to understand.

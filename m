Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2FFE6B0007
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 07:00:52 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a70-v6so3899581qkb.16
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 04:00:52 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l44-v6si3977647qtb.119.2018.08.16.04.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 04:00:52 -0700 (PDT)
Subject: Re: [PATCH v1 3/5] mm/memory_hotplug: check if sections are already
 online/offline
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-4-david@redhat.com>
 <20180816104736.GA16861@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <62da84ee-090f-29e4-0a39-fcfd543ee81d@redhat.com>
Date: Thu, 16 Aug 2018 13:00:47 +0200
MIME-Version: 1.0
In-Reply-To: <20180816104736.GA16861@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 16.08.2018 12:47, Oscar Salvador wrote:
> On Thu, Aug 16, 2018 at 12:06:26PM +0200, David Hildenbrand wrote:
> 
>> +
>> +/* check if all mem sections are offline */
>> +bool mem_sections_offline(unsigned long pfn, unsigned long end_pfn)
>> +{
>> +	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>> +		unsigned long section_nr = pfn_to_section_nr(pfn);
>> +
>> +		if (WARN_ON(!valid_section_nr(section_nr)))
>> +			continue;
>> +		if (online_section_nr(section_nr))
>> +			return false;
>> +	}
>> +	return true;
>> +}
> 
> AFAICS pages_correctly_probed will catch this first.
> pages_correctly_probed checks for the section to be:
> 
> - present
> - valid
> - !online

Right, I missed that function.

> 
> Maybe it makes sense to rename it, and write another pages_correctly_probed routine
> for the offline case.
> 
> So all checks would stay in memory_block_action level, and we would not need
> the mem_sections_offline/online stuff.

I guess I would rather have it all moved into
online_pages/offline_pages, so we have a clean interface.

> 
> Thanks
> 


-- 

Thanks,

David / dhildenb

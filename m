Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92EF26B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:53:11 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u19-v6so10981678qkl.13
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 04:53:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z4-v6si4004390qkd.401.2018.07.30.04.53.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 04:53:10 -0700 (PDT)
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
References: <20180727165454.27292-1-david@redhat.com>
 <20180730113029.GM24267@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <6cc416e7-522c-a67e-2706-f37aadff084f@redhat.com>
Date: Mon, 30 Jul 2018 13:53:06 +0200
MIME-Version: 1.0
In-Reply-To: <20180730113029.GM24267@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Souptick Joarder <jrdr.linux@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@techadventures.net>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 30.07.2018 13:30, Michal Hocko wrote:
> On Fri 27-07-18 18:54:54, David Hildenbrand wrote:
>> Right now, struct pages are inititalized when memory is onlined, not
>> when it is added (since commit d0dc12e86b31 ("mm/memory_hotplug: optimize
>> memory hotplug")).
>>
>> remove_memory() will call arch_remove_memory(). Here, we usually access
>> the struct page to get the zone of the pages.
>>
>> So effectively, we access stale struct pages in case we remove memory that
>> was never onlined. So let's simply inititalize them earlier, when the
>> memory is added. We only have to take care of updating the zone once we
>> know it. We can use a dummy zone for that purpose.
> 
> I have considered something like this when I was reworking memory
> hotplug to not associate struct pages with zone before onlining and I
> considered this to be rather fragile. I would really not like to get
> back to that again if possible.
> 
>> So effectively, all pages will already be initialized and set to
>> reserved after memory was added but before it was onlined (and even the
>> memblock is added). We only inititalize pages once, to not degrade
>> performance.
> 
> To be honest, I would rather see d0dc12e86b31 reverted. It is late in
> the release cycle and if the patch is buggy then it should be reverted
> rather than worked around. I found the optimization not really
> convincing back then and this is still the case TBH.
> 

If I am not wrong, that's already broken in 4.17, no? What about that?

If we don't care about that, then I agree to reverting said commit for
v4.18.

-- 

Thanks,

David / dhildenb

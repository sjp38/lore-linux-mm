Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0AF86B186A
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 05:45:53 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e88-v6so6526230qtb.1
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 02:45:53 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c27-v6si971071qtk.178.2018.08.20.02.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 02:45:52 -0700 (PDT)
Subject: Re: [PATCH v1 5/5] mm/memory_hotplug: print only with DEBUG_VM in
 online/offline_pages()
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-6-david@redhat.com>
 <20180817081853.GB17638@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <6f52b600-06be-8b30-d181-04489fa6e9f2@redhat.com>
Date: Mon, 20 Aug 2018 11:45:46 +0200
MIME-Version: 1.0
In-Reply-To: <20180817081853.GB17638@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 17.08.2018 10:18, Oscar Salvador wrote:
>>  failed_addition:
>> +#ifdef CONFIG_DEBUG_VM
>>  	pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
>>  		 (unsigned long long) pfn << PAGE_SHIFT,
>>  		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
>> +#endif
> 
> I have never been sure about this.
> IMO, if I fail to online pages, I want to know I failed.
> I think that pr_err would be better than pr_debug and without CONFIG_DEBUG_VM.

I consider both error messages only partially useful, as

1. They only catch a subset of actual failures the function handles.
   E.g. onlining will not report an error message if the memory notifier
   failed.
2. Onlining/Offlining is usually (with exceptions - e.g. onlining during
   add_memory) triggered from user space, where we present an error
   code. At any times, the actual state of the memory blocks can be
   observed by querying the state.

I would even vote for dropping the two error case messages completely.
At least I don't consider them very useful.

> 
> But at least, if not, envolve it with a CONFIG_DEBUG_VM, but change pr_debug to pr_info.
> 
>> +#ifdef CONFIG_DEBUG_VM
>>  	pr_debug("memory offlining [mem %#010llx-%#010llx] failed\n",
>>  		 (unsigned long long) start_pfn << PAGE_SHIFT,
>>  		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
>> +#endif
> 
> Same goes here.
> 
> Thanks
> 


-- 

Thanks,

David / dhildenb

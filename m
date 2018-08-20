Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC9C36B187A
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 05:57:09 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m13-v6so1268967qkg.2
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 02:57:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 43-v6si1407684qvt.193.2018.08.20.02.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 02:57:09 -0700 (PDT)
Subject: Re: [PATCH v1 5/5] mm/memory_hotplug: print only with DEBUG_VM in
 online/offline_pages()
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-6-david@redhat.com>
 <20180817081853.GB17638@techadventures.net>
 <20180819123403.GA22352@WeideMacBook-Pro.local>
From: David Hildenbrand <david@redhat.com>
Message-ID: <a36c4a26-658a-f57a-fdff-9fcf17fc27a6@redhat.com>
Date: Mon, 20 Aug 2018 11:57:04 +0200
MIME-Version: 1.0
In-Reply-To: <20180819123403.GA22352@WeideMacBook-Pro.local>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, Oscar Salvador <osalvador@techadventures.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 19.08.2018 14:34, Wei Yang wrote:
> On Fri, Aug 17, 2018 at 10:18:53AM +0200, Oscar Salvador wrote:
>>>  failed_addition:
>>> +#ifdef CONFIG_DEBUG_VM
>>>  	pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
>>>  		 (unsigned long long) pfn << PAGE_SHIFT,
>>>  		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
>>> +#endif
>>
>> I have never been sure about this.
>> IMO, if I fail to online pages, I want to know I failed.
>> I think that pr_err would be better than pr_debug and without CONFIG_DEBUG_VM.
>>
>> But at least, if not, envolve it with a CONFIG_DEBUG_VM, but change pr_debug to pr_info.
>>
> 
> I don't have a clear rule about these debug macro neither.
> 
> While when you look at the page related logs in calculate_node_totalpages(),
> it is KERNEL_DEBUG level and without any config macro.
> 
> Maybe we should leave them at the same state?

I guess we can do that for the to debug messages.

When offlining memory right now:

:/# echo 0 > /sys/devices/system/memory/memory9/online
[   24.476207] Offlined Pages 32768
[   24.477200] remove from free list 48000 1024 50000
[   24.477896] remove from free list 48400 1024 50000
[   24.478584] remove from free list 48800 1024 50000
[   24.479454] remove from free list 48c00 1024 50000
[   24.480192] remove from free list 49000 1024 50000
[   24.480957] remove from free list 49400 1024 50000
[   24.481752] remove from free list 49800 1024 50000
[   24.482578] remove from free list 49c00 1024 50000
[   24.483302] remove from free list 4a000 1024 50000
[   24.484300] remove from free list 4a400 1024 50000
[   24.484902] remove from free list 4a800 1024 50000
[   24.485462] remove from free list 4ac00 1024 50000
[   24.486381] remove from free list 4b000 1024 50000
[   24.487108] remove from free list 4b400 1024 50000
[   24.487842] remove from free list 4b800 1024 50000
[   24.488610] remove from free list 4bc00 1024 50000
[   24.489548] remove from free list 4c000 1024 50000
[   24.490392] remove from free list 4c400 1024 50000
[   24.491224] remove from free list 4c800 1024 50000
...

While "remove from free list" is pr_info under CONFIG_DEBUG_VM,
"Offlined Pages ..." is pr_info without CONFIG_DEBUG_VM.

-- 

Thanks,

David / dhildenb

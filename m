Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF54C6B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 13:13:03 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c27-v6so1036126qkj.3
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 10:13:03 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p53-v6si9103602qvc.131.2018.07.23.10.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 10:13:02 -0700 (PDT)
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <f8d7b5f9-e5ee-0625-f53d-50d1841e1388@redhat.com>
Date: Mon, 23 Jul 2018 19:12:58 +0200
MIME-Version: 1.0
In-Reply-To: <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On 23.07.2018 13:45, Vlastimil Babka wrote:
> On 07/20/2018 02:34 PM, David Hildenbrand wrote:
>> Dumping tools (like makedumpfile) right now don't exclude reserved pages.
>> So reserved pages might be access by dump tools although nobody except
>> the owner should touch them.
> 
> Are you sure about that? Or maybe I understand wrong. Maybe it changed
> recently, but IIRC pages that are backing memmap (struct pages) are also
> PG_reserved. And you definitely do want those in the dump.

I proposed a new flag/value to mask pages that are logically offline but
Michal wanted me to go into this direction.

While we can special case struct pages in dump tools ("we have to
read/interpret them either way, so we can also dump them"), it smells
like my original attempt was cleaner. Michal?

> 
>> This is relevant in virtual environments where we soon might want to
>> report certain reserved pages to the hypervisor and they might no longer
>> be accessible - what already was documented for reserved pages a long
>> time ago ("might not even exist").
>>
>> David Hildenbrand (2):
>>   mm: clarify semantics of reserved pages
>>   kdump: include PG_reserved value in VMCOREINFO
>>
>>  include/linux/page-flags.h | 4 ++--
>>  kernel/crash_core.c        | 1 +
>>  2 files changed, 3 insertions(+), 2 deletions(-)
>>
> 


-- 

Thanks,

David / dhildenb

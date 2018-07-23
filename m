Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD2C6B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 13:20:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id x9-v6so959372qto.18
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 10:20:49 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v84-v6si3695317qkl.344.2018.07.23.10.20.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 10:20:48 -0700 (PDT)
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <20180723123043.GD31229@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <8daae80c-871e-49b6-1cf1-1f0886d3935d@redhat.com>
Date: Mon, 23 Jul 2018 19:20:43 +0200
MIME-Version: 1.0
In-Reply-To: <20180723123043.GD31229@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On 23.07.2018 14:30, Michal Hocko wrote:
> On Mon 23-07-18 13:45:18, Vlastimil Babka wrote:
>> On 07/20/2018 02:34 PM, David Hildenbrand wrote:
>>> Dumping tools (like makedumpfile) right now don't exclude reserved pages.
>>> So reserved pages might be access by dump tools although nobody except
>>> the owner should touch them.
>>
>> Are you sure about that? Or maybe I understand wrong. Maybe it changed
>> recently, but IIRC pages that are backing memmap (struct pages) are also
>> PG_reserved. And you definitely do want those in the dump.
> 
> You are right. reserve_bootmem_region will make all early bootmem
> allocations (including those backing memmaps) PageReserved. I have asked
> several times but I haven't seen a satisfactory answer yet. Why do we
> even care for kdump about those. If they are reserved the nobody should
> really look at those specific struct pages and manipulate them. Kdump
> tools are using a kernel interface to read the content. If the specific
> content is backed by a non-existing memory then they should simply not
> return anything.
> 

"new kernel" provides an interface to read memory from "old kernel".

The new kernel has no idea about
- which memory was added/online in the old kernel
- where struct pages of the old kernel are and what their content is
- which memory is save to touch and which not

Dump tools figure all that out by interpreting the VMCORE. They e.g.
identify "struct pages" and see if they should be dumped. The "new
kernel" only allows to read that memory. It cannot hinder to crash the
system (e.g. if a dump tool would try to read a hwpoison page).

So how should the "new kernel" know if a page can be touched or not?

The *only* way would be to have an interface to the hypervisor where we
"sense" if a memory location is safe to touch. I remember that xen or
hyper-v does that - they fake a zero page in that case, after querying
the hypervisor. But this does not sound like a clean approach to me,
especially es we need yet another hypervisor interface to sense for
memory provided via "some" device.

If we can find a way to just tag pages as "don't touch", it would be the
easiest and cleanest solution in my opinion.

-- 

Thanks,

David / dhildenb

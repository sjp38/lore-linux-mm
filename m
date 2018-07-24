Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFE46B0007
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:24:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5-v6so1713291edr.19
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 05:24:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k40-v6si4669853ede.416.2018.07.24.05.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 05:24:28 -0700 (PDT)
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <20180723123043.GD31229@dhcp22.suse.cz>
 <dca091d3-4c3d-eff5-57f8-a9a45050198d@suse.cz>
 <20180724111913.GH28386@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d14d7a45-91fd-63ef-ea57-513752af1f9e@suse.cz>
Date: Tue, 24 Jul 2018 14:22:06 +0200
MIME-Version: 1.0
In-Reply-To: <20180724111913.GH28386@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On 07/24/2018 01:19 PM, Michal Hocko wrote:
>> When creating a crashdump, I definitely need the pages containing memmap
>> included in the dump, so I can inspect the struct pages. But this is a
>> bit recursive issue, so I'll try making it clearer:
>>
>> 1) there are kernel pages with data (e.g. slab) that I typically need in
>> the dump, and are not PageReserved
>> 2) there are struct pages for pages 1) in the memmap that physically
>> hold the pageflags for 1), and these are PageReserved
>> 3) there are struct pages for pages 2) somewhere else in the memmap,
>> physically hold the pageflags for 2). They are probably also
>> PageReserved themselves ? and self-referencing.
>>
>> Excluding PageReserved from dump means there won't be cases 2) and 3) in
>> the dump, which at least for case 2) is making such dump almost useless
>> in many cases.
> 
> Yes, we cannot simply exclude all PageReserved pages. I was merely
> suggesting to rule out new special PageReserved pages that are denoting 
> offline pages. The same could be applied to HWPoison pages

So how about marking them with some "page type" that we got after
Matthew's struct page reorg? I assume the pages we're talking about are
in a state that they don't need the mapcount/mapping field or whatever
unions with the page type... but I guess some care would be needed to
not have false positives when the union field is actually used but
happens to look like the new type.

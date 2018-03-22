Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 02AD06B000D
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 14:39:45 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id w68so6108559vkd.16
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:39:44 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 73si2543409vkn.322.2018.03.22.11.39.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 11:39:43 -0700 (PDT)
Subject: Re: [RFC PATCH v2 2/4] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <20180320085452.24641-3-aaron.lu@intel.com>
 <7b1988e9-7d50-d55e-7590-20426fb257af@suse.cz>
 <20180320141101.GB2033@intel.com>
 <20180322171503.GH28468@bombadil.infradead.org>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <9ab5a6dd-c1b2-8da3-31f1-dd2237ea0f44@oracle.com>
Date: Thu, 22 Mar 2018 14:39:17 -0400
MIME-Version: 1.0
In-Reply-To: <20180322171503.GH28468@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Aaron Lu <aaron.lu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>



On 03/22/2018 01:15 PM, Matthew Wilcox wrote:
> On Tue, Mar 20, 2018 at 10:11:01PM +0800, Aaron Lu wrote:
>>>> A new document file called "struct_page_filed" is added to explain
>>>> the newly reused field in "struct page".
>>>
>>> Sounds rather ad-hoc for a single field, I'd rather document it via
>>> comments.
>>
>> Dave would like to have a document to explain all those "struct page"
>> fields that are repurposed under different scenarios and this is the
>> very start of the document :-)
>>
>> I probably should have explained the intent of the document more.
> 
> Dave and I are in agreement on "Shouldn't struct page be better documented".
> I came up with this a few weeks ago; never quite got round to turning it
> into a patch:
> 
> +---+-----------+-----------+--------------+----------+--------+--------------+
> | B | slab      | pagecache | tail 1       | anon     | tail 1 | hugetlb      |
> +===+===========+===========+==============+==========+========+==============+
> | 0 | flags                                                                   |
> +---+                                                                         |
> | 4 |                                                                         |
> +---+-----------+-----------+--------------+----------+--------+--------------+
> | 8 | s_mem     | mapping   | cmp_mapcount | anon_vma | defer  | mapping      |
> +---+           |           +--------------+          | list   |              |
> |12 |           |           |              |          |        |              |
> +---+-----------+-----------+--------------+----------+        +--------------+
> |16 | freelist  | index                               |        | index        |
> +---+           |                                     |        | (shifted)    |
> |20 |           |                                     |        |              |
> +---+-----------+-------------------------------------+--------+--------------+
> |24 | counters  | mapcount                                                    |
> +---+           +-----------+--------------+----------+--------+--------------+
> |28 |           | refcount  |              |          |        | refcount     |
> +---+-----------+-----------+--------------+----------+--------+--------------+
> |32 | next      | lru       | cmpd_head    |                   | lru          |
> +---+           |           |              +-------------------+              +
> |36 |           |           |              |                   |              |
> +---+-----------+           +--------------+-------------------+              +
> |40 | pages     |           | dtor / order |                   |              |
> +---+-----------+           +--------------+-------------------+              +
> |44 | pobjects  |           |              |                   |              |
> +---+-----------+-----------+--------------+----------------------------------+
> |48 | slb_cache | private   |              |                                  |
> +---+           |           +--------------+----------------------------------+
> |52 |           |           |              |                                  |
> +---+-----------+-----------+--------------+----------------------------------+

Shouldn't the anon column also contain lru?

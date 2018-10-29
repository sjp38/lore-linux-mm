Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E87F6B0495
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:21:23 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id e11-v6so3401759lji.23
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 11:21:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5-v6sor4104490ljh.31.2018.10.29.11.21.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 11:21:21 -0700 (PDT)
Subject: Re: [PATCH 08/17] prmem: struct page: track vmap_area
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-9-igor.stoppa@huawei.com>
 <20181024031200.GC25444@bombadil.infradead.org>
 <ffb887e1-2029-42d5-3a97-54546e4d28d8@gmail.com>
 <20181025021307.GH25444@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <4b1ed33c-9b3c-a61f-b919-aeed97edddac@gmail.com>
Date: Mon, 29 Oct 2018 20:21:18 +0200
MIME-Version: 1.0
In-Reply-To: <20181025021307.GH25444@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 25/10/2018 03:13, Matthew Wilcox wrote:
> On Thu, Oct 25, 2018 at 02:01:02AM +0300, Igor Stoppa wrote:
>>>> @@ -1747,6 +1750,10 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>>>>    	if (!addr)
>>>>    		return NULL;
>>>> +	va = __find_vmap_area((unsigned long)addr);
>>>> +	for (i = 0; i < va->vm->nr_pages; i++)
>>>> +		va->vm->pages[i]->area = va;
>>>
>>> I don't like it that you're calling this for _every_ vmalloc() caller
>>> when most of them will never use this.  Perhaps have page->va be initially
>>> NULL and then cache the lookup in it when it's accessed for the first time.
>>>
>>
>> If __find_vmap_area() was part of the API, this loop could be left out from
>> __vmalloc_node_range() and the user of the allocation could initialize the
>> field, if needed.
>>
>> What is the reason for keeping __find_vmap_area() private?
> 
> Well, for one, you're walking the rbtree without holding the spinlock,
> so you're going to get crashes.  I don't see why we shouldn't export
> find_vmap_area() though.

Argh, yes, sorry. But find_vmap_area() would be enough for what I need.

> Another way we could approach this is to embed the vmap_area in the
> vm_struct.  It'd require a bit of juggling of the alloc/free paths in
> vmalloc, but it might be worthwhile.

I have a feeling of unease about the whole vmap_area / vm_struct 
duality. They clearly are different types, with different purposes, but 
here and there there are functions that are named after some "area", yet 
they actually refer to vm_struct pointers.

I wouldn't mind spending some time understanding the reason for this 
apparently bizarre choice, but after I have emerged from the prmem swamp.

For now I'd stick to find_vmap_area().

--
igor

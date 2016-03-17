Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 14FC86B025F
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:15:34 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id x3so118667698pfb.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:15:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id yp9si12187925pab.121.2016.03.17.05.15.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 05:15:32 -0700 (PDT)
Subject: Re: [PATCH v1 11/19] zsmalloc: squeeze freelist into page->mapping
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-12-git-send-email-minchan@kernel.org>
 <20160315064053.GF1464@swordfish> <20160315065126.GA3039@bbox>
From: YiPing Xu <xuyiping@hisilicon.com>
Message-ID: <56EA9E8E.5040206@hisilicon.com>
Date: Thu, 17 Mar 2016 20:09:50 +0800
MIME-Version: 1.0
In-Reply-To: <20160315065126.GA3039@bbox>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>



On 2016/3/15 14:51, Minchan Kim wrote:
> On Tue, Mar 15, 2016 at 03:40:53PM +0900, Sergey Senozhatsky wrote:
>> On (03/11/16 16:30), Minchan Kim wrote:
>>> -static void *location_to_obj(struct page *page, unsigned long obj_idx)
>>> +static void objidx_to_page_and_ofs(struct size_class *class,
>>> +				struct page *first_page,
>>> +				unsigned long obj_idx,
>>> +				struct page **obj_page,
>>> +				unsigned long *ofs_in_page)
>>
>> this looks big; 5 params, function "returning" both page and offset...
>> any chance to split it in two steps, perhaps?
>
> Yes, it's rather ugly but I don't have a good idea.
> Feel free to suggest if you have a better idea.
 >
>>
>> besides, it is more intuitive (at least to me) when 'offset'
>> shortened to 'offt', not 'ofs'.

	the purpose to get 'obj_page' and 'ofs_in_page' is to map the page and 
get the meta-data pointer in the page, so, we can finish this in a 
single function.

	just like this, and maybe we could have a better function name

static unsigned long *map_handle(struct size_class *class,
	struct page *first_page, unsigned long obj_idx)
{
	struct page *cursor = first_page;
	unsigned long offset = obj_idx * class->size;
	int nr_page = offset >> PAGE_SHIFT;
	unsigned long offset_in_page = offset & ~PAGE_MASK;
	void *addr;
	int i;

	if (class->huge) {
		VM_BUG_ON_PAGE(!is_first_page(page), page);
		return &page_private(page);
	}

	for (i = 0; i < nr_page; i++)
		cursor = get_next_page(cursor);

	addr = kmap_atomic(cursor);
	
	return addr + offset_in_page;
}

static void unmap_handle(unsigned long *addr)
{
	if (class->huge) {
		return;
	}

	kunmap_atomic(addr & ~PAGE_MASK);
}

	all functions called "objidx_to_page_and_ofs" could use it like this, 
for example:

static unsigned long handle_from_obj(struct size_class *class,
				struct page *first_page, int obj_idx)
{
	unsigned long *head = map_handle(class, first_page, obj_idx);

	if (*head & OBJ_ALLOCATED_TAG)
		handle = *head & ~OBJ_ALLOCATED_TAG;

	unmap_handle(*head);

	return handle;
}

	'freeze_zspage', u'nfreeze_zspage' use it in the same way.

	but in 'obj_malloc', we still have to get the page to get obj.

	obj = location_to_obj(m_page, obj);


> Indeed. I will change it to get_page_and_offset instead of
> abbreviation if we cannot refactor it more.
>
>>
>> 	-ss
>>
>>>   {
>>> -	unsigned long obj;
>>> +	int i;
>>> +	unsigned long ofs;
>>> +	struct page *cursor;
>>> +	int nr_page;
>>>
>>> -	if (!page) {
>>> -		VM_BUG_ON(obj_idx);
>>> -		return NULL;
>>> -	}
>>> +	ofs = obj_idx * class->size;
>>> +	cursor = first_page;
>>> +	nr_page = ofs >> PAGE_SHIFT;
>>>
>>> -	obj = page_to_pfn(page) << OBJ_INDEX_BITS;
>>> -	obj |= ((obj_idx) & OBJ_INDEX_MASK);
>>> -	obj <<= OBJ_TAG_BITS;
>>> +	*ofs_in_page = ofs & ~PAGE_MASK;
>>> +
>>> +	for (i = 0; i < nr_page; i++)
>>> +		cursor = get_next_page(cursor);
>>>
>>> -	return (void *)obj;
>>> +	*obj_page = cursor;
>>>   }
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

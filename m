Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC536B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 03:48:17 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b7so5003733pga.12
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 00:48:17 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50111.outbound.protection.outlook.com. [40.107.5.111])
        by mx.google.com with ESMTPS id h20si1456524pgn.422.2018.02.05.00.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Feb 2018 00:48:15 -0800 (PST)
Subject: Re: [PATCH] mm/kasan: Don't vfree() nonexistent vm_area.
References: <12c9e499-9c11-d248-6a3f-14ec8c4e07f1@molgen.mpg.de>
 <20180201163349.8700-1-aryabinin@virtuozzo.com>
 <20180201195757.GC20742@bombadil.infradead.org>
 <e1cf8e8e-4cc4-ff4f-92e1-f6fcf373c67f@virtuozzo.com>
 <20180202172027.GB16840@bombadil.infradead.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5ea1af5e-213d-5881-652a-c3f2c535254a@virtuozzo.com>
Date: Mon, 5 Feb 2018 11:48:33 +0300
MIME-Version: 1.0
In-Reply-To: <20180202172027.GB16840@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org



On 02/02/2018 08:20 PM, Matthew Wilcox wrote:
> On Thu, Feb 01, 2018 at 11:22:55PM +0300, Andrey Ryabinin wrote:
>>>> +		vm = find_vm_area((void *)shadow_start);
>>>> +		if (vm)
>>>> +			vfree((void *)shadow_start);
>>>> +	}
>>>
>>> This looks like a complicated way to spell 'is_vmalloc_addr' ...
>>>
>>
>> It's not. shadow_start is never vmalloc address.
> 
> I'm confused.  How can you call vfree() on something that isn't a vmalloc
> address?
> 

a??vfree() is able to free any address returned by __vmalloc_node_range().
And __vmalloc_node_range() gives you any address you ask.
It doesn't have to be an address in [VMALLOC_START, VMALLOC_END] range.

That's also how the module_alloc()/module_memfree() works on architectures that
have designated area for modules.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

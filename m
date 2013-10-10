Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id BFCFD6B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 21:29:21 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1833512pdj.18
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 18:29:21 -0700 (PDT)
Message-ID: <525602E3.3080501@oracle.com>
Date: Thu, 10 Oct 2013 09:29:07 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] frontswap: enable call to invalidate area on swapoff
References: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com> <20131007150338.1fdee18b536bb1d9fe41a07b@linux-foundation.org> <1381220000.16135.10.camel@AMDC1943> <20131008130853.96139b79a0a4d3aaacc79ed2@linux-foundation.org> <20131009144045.GA5406@variantweb.net>
In-Reply-To: <20131009144045.GA5406@variantweb.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <spartacus06@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>


On 10/09/2013 10:40 PM, Seth Jennings wrote:
> On Tue, Oct 08, 2013 at 01:08:53PM -0700, Andrew Morton wrote:
>> On Tue, 08 Oct 2013 10:13:20 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:
>>
>>> On pon, 2013-10-07 at 15:03 -0700, Andrew Morton wrote:
>>>> On Mon, 07 Oct 2013 17:25:41 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:
>>>>
>>>>> During swapoff the frontswap_map was NULL-ified before calling
>>>>> frontswap_invalidate_area(). However the frontswap_invalidate_area()
>>>>> exits early if frontswap_map is NULL. Invalidate was never called during
>>>>> swapoff.
>>>>>
>>>>> This patch moves frontswap_map_set() in swapoff just after calling
>>>>> frontswap_invalidate_area() so outside of locks
>>>>> (swap_lock and swap_info_struct->lock). This shouldn't be a problem as
>>>>> during swapon the frontswap_map_set() is called also outside of any
>>>>> locks.
>>>>>
>>>>
>>>> Ahem.  So there's a bunch of code in __frontswap_invalidate_area()
>>>> which hasn't ever been executed and nobody noticed it.  So perhaps that
>>>> code isn't actually needed?
>>>>
>>>> More seriously, this patch looks like it enables code which hasn't been
>>>> used or tested before.  How well tested was this?
>>>>
>>>> Are there any runtime-visible effects from this change?
>>>
>>> I tested zswap on x86 and x86-64 and there was no difference. This is
>>> good as there shouldn't be visible anything because swapoff is unusing
>>> all pages anyway:
>>> 	try_to_unuse(type, false, 0); /* force all pages to be unused */
>>>
>>> I haven't tested other frontswap users.
>>
>> So is that code in __frontswap_invalidate_area() unneeded?
> 
> Yes, to expand on what Bob said, __frontswap_invalidate_area() is still
> needed to let any frontswap backend free per-swaptype resources.
> 
> __frontswap_invalidate_area() is _not_ for freeing structures associated
> with individual swapped out pages since all of the pages should be
> brought back into memory by try_to_unuse() before
> __frontswap_invalidate_area() is called.
> 
> The reason we never noticed this for zswap is that zswap has no
> dynamically allocated per-type resources.  In the expected case,
> where all of the pages have been drained from zswap,
> zswap_frontswap_invalidate_area() is a no-op.
> 

Not exactly, see the bug fix "mm/zswap: bugfix: memory leak when
re-swapon" from Weijie.
Zswap needs invalidate_area() also.

Thanks,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

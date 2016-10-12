Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 629786B0260
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:25:02 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g45so31022617qte.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:25:02 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id t66si3216869qkf.177.2016.10.12.00.25.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 00:25:01 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161011172228.GA30403@dhcp22.suse.cz>
 <7649b844-cfe6-abce-148e-1e2236e7d443@zoho.com>
 <20161012065332.GA9504@dhcp22.suse.cz>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57FDE531.7060003@zoho.com>
Date: Wed, 12 Oct 2016 15:24:33 +0800
MIME-Version: 1.0
In-Reply-To: <20161012065332.GA9504@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, akpm@linux-foundation.org, cl@linux.com

On 10/12/2016 02:53 PM, Michal Hocko wrote:
> On Wed 12-10-16 08:28:17, zijun_hu wrote:
>> On 2016/10/12 1:22, Michal Hocko wrote:
>>> On Tue 11-10-16 21:24:50, zijun_hu wrote:
>>>> From: zijun_hu <zijun_hu@htc.com>
>>>>
>>>> the LSB of a chunk->map element is used for free/in-use flag of a area
>>>> and the other bits for offset, the sufficient and necessary condition of
>>>> this usage is that both size and alignment of a area must be even numbers
>>>> however, pcpu_alloc() doesn't force its @align parameter a even number
>>>> explicitly, so a odd @align maybe causes a series of errors, see below
>>>> example for concrete descriptions.
>>>
>>> Is or was there any user who would use a different than even (or power of 2)
>>> alighment? If not is this really worth handling?
>>>
>>
>> it seems only a power of 2 alignment except 1 can make sure it work very well,
>> that is a strict limit, maybe this more strict limit should be checked
> 
> I fail to see how any other alignment would actually make any sense
> what so ever. Look, I am not a maintainer of this code but adding a new
> code to catch something that doesn't make any sense sounds dubious at
> best to me.
> 
> I could understand this patch if you see a problem and want to prevent
> it from repeating bug doing these kind of changes just in case sounds
> like a bad idea.
> 

thanks for your reply

should we have a generic discussion whether such patches which considers
many boundary or rare conditions are necessary.

i found the following code segments in mm/vmalloc.c
static struct vmap_area *alloc_vmap_area(unsigned long size,
                                unsigned long align,
                                unsigned long vstart, unsigned long vend,
                                int node, gfp_t gfp_mask)
{
...

        BUG_ON(!size);
        BUG_ON(offset_in_page(size));
        BUG_ON(!is_power_of_2(align));


should we make below declarations as conventions
1) when we say 'alignment', it means align to a power of 2 value
   for example, aligning value @v to @b implicit @v is power of 2
   , align 10 to 4 is 12
2) when we say 'round value @v up/down to boundary @b', it means the 
   result is a times of @b,  it don't requires @b is a power of 2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

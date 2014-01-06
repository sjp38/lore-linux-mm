Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id D37D76B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 14:08:29 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so18829643pbc.40
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 11:08:29 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id nu8si11226048pbb.252.2014.01.06.11.08.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jan 2014 11:08:28 -0800 (PST)
Message-ID: <52CAFF2A.5060407@codeaurora.org>
Date: Mon, 06 Jan 2014 11:08:26 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCHv3 00/11] Intermix Lowmem and vmalloc
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org> <52C70024.1060605@sr71.net> <52C734F4.5020602@codeaurora.org> <20140104073143.GA5594@gmail.com>
In-Reply-To: <20140104073143.GA5594@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org

On 1/3/2014 11:31 PM, Minchan Kim wrote:
> Hello,
>
> On Fri, Jan 03, 2014 at 02:08:52PM -0800, Laura Abbott wrote:
>> On 1/3/2014 10:23 AM, Dave Hansen wrote:
>>> On 01/02/2014 01:53 PM, Laura Abbott wrote:
>>>> The goal here is to allow as much lowmem to be mapped as if the block of memory
>>>> was not reserved from the physical lowmem region. Previously, we had been
>>>> hacking up the direct virt <-> phys translation to ignore a large region of
>>>> memory. This did not scale for multiple holes of memory however.
>>>
>>> How much lowmem do these holes end up eating up in practice, ballpark?
>>> I'm curious how painful this is going to get.
>>>
>>
>> In total, the worst case can be close to 100M with an average case
>> around 70M-80M. The split and number of holes vary with the layout
>> but end up with 60M-80M one hole and the rest in the other.
>
> One more thing I'd like to know is how bad direct virt <->phys tranlsation
> in scale POV and how often virt<->phys tranlsation is called in your worload
> so what's the gain from this patch?
>
> Thanks.
>

With one hole we did

#define __phys_to_virt(phys)
	phys >= mem_hole_end ? mem_hole : normal

We had a single global variable to check for the bounds and to do 
something similar with multiple holes the worst case would be O(number 
of holes). This would also all need to be macroized. Detection and 
accounting for these holes in other data structures (e.g. ARM meminfo) 
would be increasingly complex and lead to delays in bootup. The 
error/sanity checking for bad memory configurations would also be 
messier. Non-linear lowmem mappings also make debugging more difficult.

virt <-> phys translation is used on hot paths in IOMMU mapping so we 
want to keep virt <-> phys as fast as possible and not have to walk an 
array of addresses every time.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

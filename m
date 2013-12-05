Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id E89556B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 15:34:36 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so11503426yho.38
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 12:34:36 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id by6si15466885qcb.50.2013.12.05.12.34.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 12:34:36 -0800 (PST)
Message-ID: <52A0E357.7090008@ti.com>
Date: Thu, 5 Dec 2013 15:34:31 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation
 apis
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com> <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com> <20131203232445.GX8277@htj.dyndns.org> <52A0AB34.2030703@ti.com>,<20131205165325.GA24062@mtj.dyndns.org> <902E09E6452B0E43903E4F2D568737AB097B26B2@DNCE04.ent.ti.com>
In-Reply-To: <902E09E6452B0E43903E4F2D568737AB097B26B2@DNCE04.ent.ti.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Strashko, Grygorii" <grygorii.strashko@ti.com>
Cc: Tejun Heo <tj@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Grygorii,

On Thursday 05 December 2013 01:48 PM, Strashko, Grygorii wrote:
> Hi Tejun,
> 
>> On Thu, Dec 05, 2013 at 06:35:00PM +0200, Grygorii Strashko wrote:
>>>>> +#define memblock_virt_alloc_align(x, align) \
>>>>> +  memblock_virt_alloc_try_nid(x, align, BOOTMEM_LOW_LIMIT, \
>>>>> +                               BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
>>>>
>>>> Also, do we really need this align variant separate when the caller
>>>> can simply specify 0 for the default?
>>>
>>> Unfortunately Yes.
>>> We need it to keep compatibility with bootmem/nobootmem
>>> which don't handle 0 as default align value.
>>
>> Hmm... why wouldn't just interpreting 0 to SMP_CACHE_BYTES in the
>> memblock_virt*() function work?
>>
> 
> Problem is not with memblock_virt*(). The issue will happen in case if
> memblock or nobootmem are disabled in below code (memblock_virt*() is disabled).
> 
> +/* Fall back to all the existing bootmem APIs */
> +#define memblock_virt_alloc(x) \
> +       __alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
> 
> which will be transformed to 
> +/* Fall back to all the existing bootmem APIs */
> +#define memblock_virt_alloc(x, align) \
> +       __alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)
> 
> and used as
> 
> memblock_virt_alloc(size, 0);
> 
> so, by default bootmem code will use 0 as default alignment and not SMP_CACHE_BYTES
> and that is wrong.
> 
Looks like you didn't understood the suggestion completely.
The fall back inline will look like below .....

static inline memblock_virt_alloc(x, align)
{
	if (align == 0)
		align = SMP_CACHE_BYTES
	__alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT);
}

regards,
Santosh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

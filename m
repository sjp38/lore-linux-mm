Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC298E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 16:10:17 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id w24so2419958otk.22
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 13:10:17 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m5si1924792otk.80.2018.12.07.13.10.16
        for <linux-mm@kvack.org>;
        Fri, 07 Dec 2018 13:10:16 -0800 (PST)
Subject: Re: [PATCH v3 1/9] mm: Introduce new vm_insert_range API
References: <20181206183945.GA20932@jordon-HP-15-Notebook-PC>
 <53bbc095-c9f5-5d6a-6e50-6e060d17eb68@arm.com>
 <20181207171116.GA29923@bombadil.infradead.org>
 <CAFqt6zYCWOK-uS85GqCzcgT=+YKn1nBrRPq+M9y6eJjmXEKH+g@mail.gmail.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <67495f8f-2092-e42d-321e-5216c346513f@arm.com>
Date: Fri, 7 Dec 2018 21:10:00 +0000
MIME-Version: 1.0
In-Reply-To: <CAFqt6zYCWOK-uS85GqCzcgT=+YKn1nBrRPq+M9y6eJjmXEKH+g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On 2018-12-07 7:28 pm, Souptick Joarder wrote:
> On Fri, Dec 7, 2018 at 10:41 PM Matthew Wilcox <willy@infradead.org> wrote:
>>
>> On Fri, Dec 07, 2018 at 03:34:56PM +0000, Robin Murphy wrote:
>>>> +int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
>>>> +                   struct page **pages, unsigned long page_count)
>>>> +{
>>>> +   unsigned long uaddr = addr;
>>>> +   int ret = 0, i;
>>>
>>> Some of the sites being replaced were effectively ensuring that vma and
>>> pages were mutually compatible as an initial condition - would it be worth
>>> adding something here for robustness, e.g.:
>>>
>>> +     if (page_count != vma_pages(vma))
>>> +             return -ENXIO;
>>
>> I think we want to allow this to be used to populate part of a VMA.
>> So perhaps:
>>
>>          if (page_count > vma_pages(vma))
>>                  return -ENXIO;
> 
> Ok, This can be added.
> 
> I think Patch [2/9] is the only leftover place where this
> check could be removed.

Right, 9/9 could also have relied on my stricter check here, but since 
it's really testing whether it actually managed to allocate vma_pages() 
worth of pages earlier, Matthew's more lenient version won't help for 
that one. (Why privcmd_buf_mmap() doesn't clean up and return an error 
as soon as that allocation loop fails, without taking the mutex under 
which it still does a bunch more pointless work to only undo it again, 
is a mind-boggling mystery, but that's not our problem here...)

Robin.

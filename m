Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 984916B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 21:26:20 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o187so5693508qke.1
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 18:26:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a124sor1689392qkd.13.2017.10.08.18.26.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Oct 2017 18:26:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC=cRTMm41DpnSdv0BvBDLcdfgyssD2u5xqUmGUgZ5RdGroWhQ@mail.gmail.com>
References: <1505886205-9671-1-git-send-email-minchan@kernel.org>
 <1505886205-9671-5-git-send-email-minchan@kernel.org> <CAC=cRTMm41DpnSdv0BvBDLcdfgyssD2u5xqUmGUgZ5RdGroWhQ@mail.gmail.com>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Mon, 9 Oct 2017 09:26:18 +0800
Message-ID: <CAC=cRTN=1saVebn7E+Rpjh+WiOBthwO=v71+mmNJzmbP7REFOw@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] mm:swap: skip swapcache for swapin of synchronous device
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@lge.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>

On Fri, Sep 29, 2017 at 4:51 PM, huang ying
<huang.ying.caritas@gmail.com> wrote:
> On Wed, Sep 20, 2017 at 1:43 PM, Minchan Kim <minchan@kernel.org> wrote:

[snip]

>> diff --git a/mm/memory.c b/mm/memory.c
>> index ec4e15494901..163ab2062385 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2842,7 +2842,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
>>  int do_swap_page(struct vm_fault *vmf)
>>  {
>>         struct vm_area_struct *vma = vmf->vma;
>> -       struct page *page = NULL, *swapcache;
>> +       struct page *page = NULL, *swapcache = NULL;
>>         struct mem_cgroup *memcg;
>>         struct vma_swap_readahead swap_ra;
>>         swp_entry_t entry;
>> @@ -2881,17 +2881,35 @@ int do_swap_page(struct vm_fault *vmf)
>>                 }
>>                 goto out;
>>         }
>> +
>> +
>>         delayacct_set_flag(DELAYACCT_PF_SWAPIN);
>>         if (!page)
>>                 page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
>>                                          vmf->address);
>>         if (!page) {
>> -               if (vma_readahead)
>> -                       page = do_swap_page_readahead(entry,
>> -                               GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
>> -               else
>> -                       page = swapin_readahead(entry,
>> -                               GFP_HIGHUSER_MOVABLE, vma, vmf->address);
>> +               struct swap_info_struct *si = swp_swap_info(entry);
>> +
>> +               if (!(si->flags & SWP_SYNCHRONOUS_IO)) {
>> +                       if (vma_readahead)
>> +                               page = do_swap_page_readahead(entry,
>> +                                       GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
>> +                       else
>> +                               page = swapin_readahead(entry,
>> +                                       GFP_HIGHUSER_MOVABLE, vma, vmf->address);
>> +                       swapcache = page;
>> +               } else {
>> +                       /* skip swapcache */
>> +                       page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
>> +                       if (page) {
>> +                               __SetPageLocked(page);
>> +                               __SetPageSwapBacked(page);
>> +                               set_page_private(page, entry.val);
>> +                               lru_cache_add_anon(page);
>> +                               swap_readpage(page, true);
>> +                       }
>> +               }
>
> I have a question for this.  If a page is mapped in multiple processes
> (for example, because of fork).  With swap cache, after swapping out
> and swapping in, the page will be still shared by these processes.
> But with your changes, it appears that there will be multiple pages
> with same contents mapped in multiple processes, even if the page
> isn't written in these processes.  So this may waste some memory in
> some situation?  And copying from device is even faster than looking
> up swap cache in your system?

Hi, Minchan,

Could you help me on this?

Best Regards,
Huang, Ying

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

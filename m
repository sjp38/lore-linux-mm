Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADDD06B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 16:10:11 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id k19so1368049ita.8
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:10:11 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b189si2229262ioe.250.2018.02.15.13.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 13:10:10 -0800 (PST)
Subject: Re: [RFC PATCH V2 00/22] Intel(R) Resource Director Technology Cache
 Pseudo-Locking enabling
References: <cover.1518443616.git.reinette.chatre@intel.com>
 <e0d59d83-14a1-6059-6f0b-da47b3b7de31@oracle.com>
 <29d1be82-9fc8-ecde-a5ee-4eafc92e39f1@intel.com>
 <c8dbff0b-4d8c-85d9-3f83-539183a95bfa@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <66661860-cb12-1f03-9e89-267d285c52c2@oracle.com>
Date: Thu, 15 Feb 2018 13:10:02 -0800
MIME-Version: 1.0
In-Reply-To: <c8dbff0b-4d8c-85d9-3f83-539183a95bfa@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reinette Chatre <reinette.chatre@intel.com>, tglx@linutronix.de, fenghua.yu@intel.com, tony.luck@intel.com
Cc: gavin.hindman@intel.com, vikas.shivappa@linux.intel.com, dave.hansen@intel.com, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On 02/15/2018 12:39 PM, Reinette Chatre wrote:
> On 2/14/2018 10:31 AM, Reinette Chatre wrote:
>> On 2/14/2018 10:12 AM, Mike Kravetz wrote:
>>> On 02/13/2018 07:46 AM, Reinette Chatre wrote:
>>>> Adding MM maintainers to v2 to share the new MM change (patch 21/22) that
>>>> enables large contiguous regions that was created to support large Cache
>>>> Pseudo-Locked regions (patch 22/22). This week MM team received another
>>>> proposal to support large contiguous allocations ("[RFC PATCH 0/3]
>>>> Interface for higher order contiguous allocations" at
>>>> http://lkml.kernel.org/r/20180212222056.9735-1-mike.kravetz@oracle.com).
>>>> I have not yet tested with this new proposal but it does seem appropriate
>>>> and I should be able to rework patch 22 from this series on top of that if
>>>> it is accepted instead of what I have in patch 21 of this series.
>>>>
>>>
>>> Well, I certainly would prefer the adoption and use of a more general
>>> purpose interface rather than exposing alloc_gigantic_page().
>>>
>>> Both the interface I suggested and alloc_gigantic_page end up calling
>>> alloc_contig_range().  I have not looked at your entire patch series, but
>>> do be aware that in its present form alloc_contig_range will run into
>>> issues if called by two threads simultaneously for the same page range.
>>> Calling alloc_gigantic_page without some form of synchronization will
>>> expose this issue.  Currently this is handled by hugetlb_lock for all
>>> users of alloc_gigantic_page.  If you simply expose alloc_gigantic_page
>>> without any type of synchronization, you may run into issues.  The first
>>> patch in my RFC "mm: make start_isolate_page_range() fail if already
>>> isolated" should handle this situation IF we decide to expose
>>> alloc_gigantic_page (which I do not suggest).
>>
>> My work depends on the ability to create large contiguous regions,
>> creating these large regions is not the goal in itself. Certainly I
>> would want to use the most appropriate mechanism and I would gladly
>> modify my work to do so.
>>
>> I do not insist on using alloc_gigantic_page(). Now that I am aware of
>> your RFC I started the process to convert to the new
>> find_alloc_contig_pages(). I did not do so earlier because it was not
>> available when I prepared this work for submission. I plan to respond to
>> your RFC when my testing is complete but please give me a few days to do
>> so. Could you please also cc me if you do send out any new versions?
> 
> Testing with the new find_alloc_contig_pages() introduced in
> "[RFC PATCH 0/3] Interface for higher order contiguous allocations" at
> http://lkml.kernel.org/r/20180212222056.9735-1-mike.kravetz@oracle.com
> was successful. If this new interface is merged then Cache
> Pseudo-Locking can easily be ported to use that instead of what I have
> in patch 21/22 (exposing alloc_gigantic_page()) with the following
> change to patch 22/22:
> 

Nice.  Thank you for converting and testing with this interface.
-- 
Mike Kravetz

> 
> diff --git a/arch/x86/kernel/cpu/intel_rdt_pseudo_lock.c
> b/arch/x86/kernel/cpu/intel_rdt_pseudo_lock.c
> index 99918943a98a..b5e4ae379352 100644
> --- a/arch/x86/kernel/cpu/intel_rdt_pseudo_lock.c
> +++ b/arch/x86/kernel/cpu/intel_rdt_pseudo_lock.c
> @@ -228,9 +228,10 @@ static int contig_mem_alloc(struct
> pseudo_lock_region *plr)
>         }
> 
>         if (plr->size > KMALLOC_MAX_SIZE) {
> -               plr->kmem = alloc_gigantic_page(cpu_to_node(plr->cpu),
> -                                               get_order(plr->size),
> -                                               GFP_KERNEL | __GFP_ZERO);
> +               plr->kmem = find_alloc_contig_pages(get_order(plr->size),
> +                                                   GFP_KERNEL | __GFP_ZERO,
> +                                                   cpu_to_node(plr->cpu),
> +                                                   NULL);
>                 if (!plr->kmem) {
>                         rdt_last_cmd_puts("unable to allocate gigantic
> page\n");
>                         return -ENOMEM;
> @@ -255,7 +256,7 @@ static int contig_mem_alloc(struct
> pseudo_lock_region *plr)
>  static void contig_mem_free(struct pseudo_lock_region *plr)
>  {
>         if (plr->size > KMALLOC_MAX_SIZE)
> -               free_gigantic_page(plr->kmem, get_order(plr->size));
> +               free_contig_pages(plr->kmem, 1 << get_order(plr->size));
>         else
>                 kfree(page_to_virt(plr->kmem));
>  }
> 
> 
> It does seem as though there will be a new API for large contiguous
> allocations, eliminating the need for patch 21 of this series. How large
> contiguous regions are allocated are independent of Cache Pseudo-Locking
> though and the patch series as submitted still stands. I can include the
> above snippet in a new version of the series but I am not sure if it is
> preferred at this time. Please do let me know, I'd be happy to.
> 
> Reinette
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <462C88B1.8080906@yahoo.com.au>
Date: Mon, 23 Apr 2007 20:21:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au> <462C2DC7.5070709@redhat.com> <462C2F33.8090508@redhat.com> <462C7A6F.9030905@redhat.com>
In-Reply-To: <462C7A6F.9030905@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Use TLB batching for MADV_FREE.  Adds another 10-15% extra performance
> to the MySQL sysbench results on my quad core system.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> Rik van Riel wrote:
> 
>>> I've added a 5th column, with just your mmap_sem patch and
>>> without my madv_free patch.  It is run with the glibc patch,
>>> which should make it fall back to MADV_DONTNEED after the
>>> first MADV_FREE call fails.
> 
> 
> With the attached patch to make MADV_FREE use tlb batching, not
> only do we gain an additional 10-15% performance but Nick's
> mmap_sem patch also shows the performance increase that we
> expected to see.
> 
> It looks like the tlb flushes (and IPIs) from zap_pte_range()
> could have been the problem.  They're gone now.

I guess it is a good idea to batch these things. But can you
do that on all architectures? What happens if your tlb flush
happens after another thread already accesses it again, or
after it subsequently gets removed from the address space via
another CPU?

> 
> The second column from the right has Nick's patch and my own
> two patches.  Performance with 16 threads is almost triple what
> it used to be...
> 
> vanilla   glibc  glibc      glibc        glibc      glibc      glibc
>                  madv_free  madv_free               madv_free madv_free
>                             mmap_sem     mmap_sem   mmap_sem
>                                                     tlb batch  tlb_batch
> threads
> 
>  1     610     609     596         545         534     547     537
>  2    1032    1136    1196        1200        1180    1293    1194
>  4    1070    1128    2014        2024        2027    2248    2040
>  8    1000    1088    1665        2087        2089    2314    1869
>  16    779    1073    1310        1999        2012    2214    1557
> 
> 
>> Now that I think about it - this is all with the rawhide kernel
>> configuration, which has an ungodly number of debug config
>> options enabled.
>>
>> I should try this with a more normal kernel, on various different
>> systems.
> 
> 
> This is for another day. :)
> 
> First some ebizzy runs...
> 
> 
> ------------------------------------------------------------------------
> 
> --- linux-2.6.20.x86_64/mm/memory.c.orig	2007-04-23 02:48:36.000000000 -0400
> +++ linux-2.6.20.x86_64/mm/memory.c	2007-04-23 02:54:42.000000000 -0400
> @@ -677,11 +677,15 @@ static unsigned long zap_pte_range(struc
>  						remove_exclusive_swap_page(page);
>  						unlock_page(page);
>  					}
> -					ptep_clear_flush_dirty(vma, addr, pte);
> -					ptep_clear_flush_young(vma, addr, pte);
>  					SetPageLazyFree(page);
>  					if (PageActive(page))
>  						deactivate_tail_page(page);
> +					ptent = *pte;
> +					set_pte_at(mm, addr, pte,
> +						pte_mkclean(pte_mkold(ptent)));
> +					/* tlb_remove_page frees it again */
> +					get_page(page);
> +					tlb_remove_page(tlb, page);
>  					continue;
>  				}
>  			}


-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

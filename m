Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 685596B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 11:55:21 -0500 (EST)
Message-ID: <50E70A4D.6050601@redhat.com>
Date: Sat, 05 Jan 2013 00:58:53 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: kernel BUG at mm/huge_memory.c:1798!
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com> <535932623.34838584.1356410331076.JavaMail.root@redhat.com> <20130103175737.GA3885@suse.de>
In-Reply-To: <20130103175737.GA3885@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, hughd@google.com, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On 01/04/2013 01:57 AM, Mel Gorman wrote:
> (Adding Michel and Rik to cc)
>
> On Mon, Dec 24, 2012 at 11:38:51PM -0500, Zhouping Liu wrote:
>> Hello all,
>>
>> I found the below kernel bug using latest mainline(637704cbc95),
>> my hardware has 2 numa nodes, and it's easy to reproduce the issue
>> using LTP test case: "# ./mmap10 -a -s -c 200":
>>
> Sorry for the long delay in responding, first day back online after being
> off for a holiday. I can reproduce this problem. It takes many iterations
> but triggers within a minute. It also affects 3.8-rc2.
>
> This BUG is triggered because the rmap walk is not finding all vmas mapping
> a page (walk found 0 avc's while the page mapcount was positive). THP
> requires this rmap walk to be correct or minimally all the pmds will not
> be marked as splitting. If PMDs are not marked splitting then all sorts
> of problems can occur. The test case triggering this is fairly simple.
>
> o A process creates a mapping 10MB-4KB in size
> o The process forks, then unmaps the entire mapping and exits
> o First child forks then unmaps part of the mapping and exits
> o Second child unmaps then unmaps part of the mapping and exits
>
> The partial unmapping on a page boundary but not a THP boundary is what
> causes the THP split and allows this bug to be triggered. The two children
> are racing with each other.
>
> I confirmed that this bug triggers on UMA and the THP migration for NUMA
> balancing is very unlikely to be a factor.  As it looked like anon_vma
> rwsem was being taken for write in the correct places, it led me to conclude
> that this must be a race within split_huge_page() itself somewhere.
>
> split_huge_page consists of three tasks
>
>    o __split_huge_page_splitting marks all PMDs as splitting
>
>    o __split_huge_page_refcount uses the page compound lock to serialise
>      based on the page and converts the compount page into 512 base pages
>
>    o __split_huge_page_map uses the page table lock to serialise within
>      the address space and updates the PTE
>
> None of these affect avc linkages but they might be affecting the rmap
> walk after the conversion to interval trees. I'm adding Michel and Rik
> to the cc in case they can quickly spot how the walk could be affected
> during a THP split.
>
> The patch below hides the race by serialising split_huge_page but the
> exact race needs to be identified before figuring out what the real locking
> problem is. That's as far as I got with it today and will pick it up again
> tomorrow. Better theories as to what is going wrong are welcome.

Hello Mel,

I have tested the below patch, and run the reproducer for a long time, 
the issue
couldn't be triggered any more with the patch.

Thanks for your patch, and I will tested your new patch(it seemed that 
this one
is a little different with the new one), provide the feedback ASAP.

Zhouping

>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9e894ed..f815ddb 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1822,6 +1822,8 @@ int split_huge_page(struct page *page)
>   	anon_vma = page_lock_anon_vma_read(page);
>   	if (!anon_vma)
>   		goto out;
> +	page_unlock_anon_vma_read(anon_vma);
> +	anon_vma_lock_write(anon_vma);
>   	ret = 0;
>   	if (!PageCompound(page))
>   		goto out_unlock;
> @@ -1832,7 +1834,7 @@ int split_huge_page(struct page *page)
>   
>   	BUG_ON(PageCompound(page));
>   out_unlock:
> -	page_unlock_anon_vma_read(anon_vma);
> +	anon_vma_unlock(anon_vma);
>   out:
>   	return ret;
>   }
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

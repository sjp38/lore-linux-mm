Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 27A696B0035
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 06:40:49 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so5721088pab.17
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 03:40:48 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id sn4si21342683pab.203.2014.06.23.03.40.47
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 03:40:48 -0700 (PDT)
Message-ID: <53A80424.8030105@cn.fujitsu.com>
Date: Mon, 23 Jun 2014 18:40:36 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/13] mm, THP: don't hold mmap_sem in khugepaged when
 allocating THP
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz> <1403279383-5862-2-git-send-email-vbabka@suse.cz> <20140620174533.GA9635@node.dhcp.inet.fi> <53A7BD91.8020802@cn.fujitsu.com> <53A7F8DC.8090106@suse.cz>
In-Reply-To: <53A7F8DC.8090106@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On 06/23/2014 05:52 PM, Vlastimil Babka wrote:
> On 06/23/2014 07:39 AM, Zhang Yanfei wrote:
>> Hello
>>
>> On 06/21/2014 01:45 AM, Kirill A. Shutemov wrote:
>>> On Fri, Jun 20, 2014 at 05:49:31PM +0200, Vlastimil Babka wrote:
>>>> When allocating huge page for collapsing, khugepaged currently holds mmap_sem
>>>> for reading on the mm where collapsing occurs. Afterwards the read lock is
>>>> dropped before write lock is taken on the same mmap_sem.
>>>>
>>>> Holding mmap_sem during whole huge page allocation is therefore useless, the
>>>> vma needs to be rechecked after taking the write lock anyway. Furthemore, huge
>>>> page allocation might involve a rather long sync compaction, and thus block
>>>> any mmap_sem writers and i.e. affect workloads that perform frequent m(un)map
>>>> or mprotect oterations.
>>>>
>>>> This patch simply releases the read lock before allocating a huge page. It
>>>> also deletes an outdated comment that assumed vma must be stable, as it was
>>>> using alloc_hugepage_vma(). This is no longer true since commit 9f1b868a13
>>>> ("mm: thp: khugepaged: add policy for finding target node").
>>>
>>> There is no point in touching ->mmap_sem in khugepaged_alloc_page() at
>>> all. Please, move up_read() outside khugepaged_alloc_page().
>>>
> 
> Well there's also currently no point in passing several parameters to khugepaged_alloc_page(). So I could clean it up as well, but I imagine later we would perhaps reintroduce them back, as I don't think the current situation is ideal for at least two reasons.
> 
> 1. If you read commit 9f1b868a13 ("mm: thp: khugepaged: add policy for finding target node"), it's based on a report where somebody found that mempolicy is not observed properly when collapsing THP's. But the 'policy' introduced by the commit isn't based on real mempolicy, it might just under certain conditions results in an interleave, which happens to be what the reporter was trying.
> 
> So ideally, it should be making node allocation decisions based on where the original 4KB pages are located. For example, allocate a THP only if all the 4KB pages are on the same node. That would also automatically obey any policy that has lead to the allocation of those 4KB pages.
> 
> And for this, it will need again the parameters and mmap_sem in read mode. It would be however still a good idea to drop mmap_sem before the allocation itself, since compaction/reclaim might take some time...
> 
> 2. (less related) I'd expect khugepaged to first allocate a hugepage and then scan for collapsing. Yes there's khugepaged_prealloc_page, but that only does something on !NUMA systems and these are not the future.
> Although I don't have the data, I expect allocating a hugepage is a bigger issue than finding something that could be collapsed. So why scan for collapsing if in the end I cannot allocate a hugepage? And if I really cannot find something to collapse, would e.g. caching a single hugepage per node be a big hit? Also, if there's really nothing to collapse, then it means khugepaged won't compact. And since khugepaged is becoming the only source of sync compaction that doesn't give up easily and tries to e.g. migrate movable pages out of unmovable pageblocks, this might have bad effects on fragmentation.
> I believe this could be done smarter.
> 
>> I might be wrong. If we up_read in khugepaged_scan_pmd(), then if we round again
>> do the for loop to get the next vma and handle it. Does we do this without holding
>> the mmap_sem in any mode?
>>
>> And if the loop end, we have another up_read in breakouterloop. What if we have
>> released the mmap_sem in collapse_huge_page()?
> 
> collapse_huge_page() is only called from khugepaged_scan_pmd() in the if (ret) condition. And khugepaged_scan_mm_slot() has similar if (ret) for the return value of khugepaged_scan_pmd() to break out of the loop (and not doing up_read() again). So I think this is correct and moving up_read from khugepaged_alloc_page() to collapse_huge_page() wouldn't
> change this?

Ah, right.

> 
> 
> .
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

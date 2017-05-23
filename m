Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6579D6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 05:24:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y65so157932559pff.13
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:24:16 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id l10si20446172plk.133.2017.05.23.02.24.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 02:24:15 -0700 (PDT)
Message-ID: <5923FF31.5020801@huawei.com>
Date: Tue, 23 May 2017 17:21:53 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com> <591EBE71.7080402@huawei.com> <alpine.LSU.2.11.1705191453040.3819@eggly.anvils> <591F9A09.6010707@huawei.com> <alpine.LSU.2.11.1705191852360.11060@eggly.anvils> <591FA78E.9050307@huawei.com> <alpine.LSU.2.11.1705191935220.11750@eggly.anvils> <591FB173.4020409@huawei.com> <a94c202d-7d9f-0a62-3049-9f825a1db50d@suse.cz>
In-Reply-To: <a94c202d-7d9f-0a62-3049-9f825a1db50d@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Xishi Qiu <qiuxishi@huawei.com>, Andrew
 Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2017/5/23 0:51, Vlastimil Babka wrote:
> On 05/20/2017 05:01 AM, zhong jiang wrote:
>> On 2017/5/20 10:40, Hugh Dickins wrote:
>>> On Sat, 20 May 2017, Xishi Qiu wrote:
>>>> Here is a bug report form redhat: https://bugzilla.redhat.com/show_bug.cgi?id=1305620
>>>> And I meet the bug too. However it is hard to reproduce, and 
>>>> 624483f3ea82598("mm: rmap: fix use-after-free in __put_anon_vma") is not help.
>>>>
>>>> From the vmcore, it seems that the page is still mapped(_mapcount=0 and _count=2),
>>>> and the value of mapping is a valid address(mapping = 0xffff8801b3e2a101),
>>>> but anon_vma has been corrupted.
>>>>
>>>> Any ideas?
>>> Sorry, no.  I assume that _mapcount has been misaccounted, for example
>>> a pte mapped in on top of another pte; but cannot begin tell you where
>>> in Red Hat's kernel-3.10.0-229.4.2.el7 that might happen.
>>>
>>> Hugh
>>>
>>> .
>>>
>> Hi, Hugh
>>
>> I find the following message from the dmesg.
>>
>> [26068.316592] BUG: Bad rss-counter state mm:ffff8800a7de2d80 idx:1 val:1
>>
>> I can prove that the __mapcount is misaccount.  when task is exited. the rmap
>> still exist.
> Check if the kernel in question contains this commit: ad33bb04b2a6 ("mm:
> thp: fix SMP race condition between THP page fault and MADV_DONTNEED")
  HI, Vlastimil
 
  I miss the patch.  when I read the patch. I find the following issue. but I am sure it is right.

      if (unlikely(pmd_trans_unstable(pmd)))
        return 0;
    /*
     * A regular pmd is established and it can't morph into a huge pmd
     * from under us anymore at this point because we hold the mmap_sem
     * read mode and khugepaged takes it in write mode. So now it's
     * safe to run pte_offset_map().
     */
    pte = pte_offset_map(pmd, address);

  after pmd_trans_unstable call,  without any protect method.  by the comments,
  it think the pte_offset_map is safe.    before pte_offset_map call, it still may be
  unstable. it is possible?

  Thanks
zhongjiang
>> Thanks
>> zhongjiang
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

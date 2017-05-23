Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5494B6B0279
	for <linux-mm@kvack.org>; Mon, 22 May 2017 22:22:33 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c132so178315162oia.6
        for <linux-mm@kvack.org>; Mon, 22 May 2017 19:22:33 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id u7si7973954oie.81.2017.05.22.19.22.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 19:22:32 -0700 (PDT)
Message-ID: <59239C4C.5020709@huawei.com>
Date: Tue, 23 May 2017 10:19:56 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com> <591EBE71.7080402@huawei.com> <alpine.LSU.2.11.1705191453040.3819@eggly.anvils> <591F9A09.6010707@huawei.com> <alpine.LSU.2.11.1705191852360.11060@eggly.anvils> <591FA78E.9050307@huawei.com> <alpine.LSU.2.11.1705191935220.11750@eggly.anvils> <5922B3D4.1030700@huawei.com> <alpine.LSU.2.11.1705221213580.4090@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1705221213580.4090@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel
 Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On 2017/5/23 3:26, Hugh Dickins wrote:

> On Mon, 22 May 2017, Xishi Qiu wrote:
>> On 2017/5/20 10:40, Hugh Dickins wrote:
>>> On Sat, 20 May 2017, Xishi Qiu wrote:
>>>>
>>>> Here is a bug report form redhat: https://bugzilla.redhat.com/show_bug.cgi?id=1305620
>>>> And I meet the bug too. However it is hard to reproduce, and 
>>>> 624483f3ea82598("mm: rmap: fix use-after-free in __put_anon_vma") is not help.
>>>>
>>>> From the vmcore, it seems that the page is still mapped(_mapcount=0 and _count=2),
>>>> and the value of mapping is a valid address(mapping = 0xffff8801b3e2a101),
>>>> but anon_vma has been corrupted.
>>>>
>>>> Any ideas?
>>>
>>> Sorry, no.  I assume that _mapcount has been misaccounted, for example
>>> a pte mapped in on top of another pte; but cannot begin tell you where
>>
>> Hi Hugh,
>>
>> What does "a pte mapped in on top of another pte" mean? Could you give more info?
> 
> I mean, there are various places in mm/memory.c which decide what they
> intend to do based on orig_pte, then take pte lock, then check that
> pte_same(pte, orig_pte) before taking it any further.  If a pte_same()
> check were missing (I do not know of any such case), then two racing
> tasks might install the same pte, one on top of the other - page
> mapcount being incremented twice, but decremented only once when
> that pte is finally unmapped later.
> 

Hi Hugh,

Do you mean that the ptes from two racing point to the same page?
or the two racing point to two pages, but one covers the other later?
and the first page maybe alone in the lru list, and it will never be freed
when the process exit.

We got this info before crash.
[26068.316592] BUG: Bad rss-counter state mm:ffff8800a7de2d80 idx:1 val:1

Thanks,
Xishi Qiu

> Please see similar discussion in the earlier thread at
> marc.info/?l=linux-mm&m=148222656211837&w=2
> 
> Hugh
> 
>>
>> Thanks,
>> Xishi Qiu
>>
>>> in Red Hat's kernel-3.10.0-229.4.2.el7 that might happen.
>>>
>>> Hugh
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

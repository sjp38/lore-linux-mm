Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2217A2803BF
	for <linux-mm@kvack.org>; Mon, 22 May 2017 12:52:36 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g143so26274858wme.13
        for <linux-mm@kvack.org>; Mon, 22 May 2017 09:52:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q184si161949wmg.165.2017.05.22.09.52.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 09:52:33 -0700 (PDT)
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com>
 <591EBE71.7080402@huawei.com>
 <alpine.LSU.2.11.1705191453040.3819@eggly.anvils>
 <591F9A09.6010707@huawei.com>
 <alpine.LSU.2.11.1705191852360.11060@eggly.anvils>
 <591FA78E.9050307@huawei.com>
 <alpine.LSU.2.11.1705191935220.11750@eggly.anvils>
 <591FB173.4020409@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a94c202d-7d9f-0a62-3049-9f825a1db50d@suse.cz>
Date: Mon, 22 May 2017 18:51:58 +0200
MIME-Version: 1.0
In-Reply-To: <591FB173.4020409@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>, Hugh Dickins <hughd@google.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/20/2017 05:01 AM, zhong jiang wrote:
> On 2017/5/20 10:40, Hugh Dickins wrote:
>> On Sat, 20 May 2017, Xishi Qiu wrote:
>>> Here is a bug report form redhat: https://bugzilla.redhat.com/show_bug.cgi?id=1305620
>>> And I meet the bug too. However it is hard to reproduce, and 
>>> 624483f3ea82598("mm: rmap: fix use-after-free in __put_anon_vma") is not help.
>>>
>>> From the vmcore, it seems that the page is still mapped(_mapcount=0 and _count=2),
>>> and the value of mapping is a valid address(mapping = 0xffff8801b3e2a101),
>>> but anon_vma has been corrupted.
>>>
>>> Any ideas?
>> Sorry, no.  I assume that _mapcount has been misaccounted, for example
>> a pte mapped in on top of another pte; but cannot begin tell you where
>> in Red Hat's kernel-3.10.0-229.4.2.el7 that might happen.
>>
>> Hugh
>>
>> .
>>
> Hi, Hugh
> 
> I find the following message from the dmesg.
> 
> [26068.316592] BUG: Bad rss-counter state mm:ffff8800a7de2d80 idx:1 val:1
> 
> I can prove that the __mapcount is misaccount.  when task is exited. the rmap
> still exist.

Check if the kernel in question contains this commit: ad33bb04b2a6 ("mm:
thp: fix SMP race condition between THP page fault and MADV_DONTNEED")

> Thanks
> zhongjiang
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

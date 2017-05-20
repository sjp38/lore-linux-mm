Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0C4A280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 23:03:16 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x64so72837785pgd.6
        for <linux-mm@kvack.org>; Fri, 19 May 2017 20:03:16 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id 22si1381624pgg.71.2017.05.19.20.03.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 20:03:15 -0700 (PDT)
Message-ID: <591FB173.4020409@huawei.com>
Date: Sat, 20 May 2017 11:01:07 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com> <591EBE71.7080402@huawei.com> <alpine.LSU.2.11.1705191453040.3819@eggly.anvils> <591F9A09.6010707@huawei.com> <alpine.LSU.2.11.1705191852360.11060@eggly.anvils> <591FA78E.9050307@huawei.com> <alpine.LSU.2.11.1705191935220.11750@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1705191935220.11750@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil
 Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2017/5/20 10:40, Hugh Dickins wrote:
> On Sat, 20 May 2017, Xishi Qiu wrote:
>> Here is a bug report form redhat: https://bugzilla.redhat.com/show_bug.cgi?id=1305620
>> And I meet the bug too. However it is hard to reproduce, and 
>> 624483f3ea82598("mm: rmap: fix use-after-free in __put_anon_vma") is not help.
>>
>> From the vmcore, it seems that the page is still mapped(_mapcount=0 and _count=2),
>> and the value of mapping is a valid address(mapping = 0xffff8801b3e2a101),
>> but anon_vma has been corrupted.
>>
>> Any ideas?
> Sorry, no.  I assume that _mapcount has been misaccounted, for example
> a pte mapped in on top of another pte; but cannot begin tell you where
> in Red Hat's kernel-3.10.0-229.4.2.el7 that might happen.
>
> Hugh
>
> .
>
Hi, Hugh

I find the following message from the dmesg.

[26068.316592] BUG: Bad rss-counter state mm:ffff8800a7de2d80 idx:1 val:1

I can prove that the __mapcount is misaccount.  when task is exited. the rmap
still exist.

Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

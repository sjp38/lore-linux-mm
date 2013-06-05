Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 929426B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 22:50:07 -0400 (EDT)
Message-ID: <51AEA72B.5070707@huawei.com>
Date: Wed, 5 Jun 2013 10:49:15 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: Transparent Hugepage impact on memcpy
References: <51ADAC15.1050103@huawei.com> <20130604123050.GA32707@hacker.(null)> <20130604202017.GJ3463@redhat.com>
In-Reply-To: <20130604202017.GJ3463@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, qiuxishi <qiuxishi@huawei.com>, Hush Bensen <hush.bensen@gmail.com>

Hi Andrea,

Thanks for your patient explanation:). Please see below.

On 2013/6/5 4:20, Andrea Arcangeli wrote:

> Hello everyone,
> 
> On Tue, Jun 04, 2013 at 08:30:51PM +0800, Wanpeng Li wrote:
>> On Tue, Jun 04, 2013 at 04:57:57PM +0800, Jianguo Wu wrote:
>>> Hi all,
>>>
>>> I tested memcpy with perf bench, and found that in prefault case, When Transparent Hugepage is on,
>>> memcpy has worse performance.
>>>
>>> When THP on is 3.672879 GB/Sec (with prefault), while THP off is 6.190187 GB/Sec (with prefault).
>>>
>>
>> I get similar result as you against 3.10-rc4 in the attachment. This
>> dues to the characteristic of thp takes a single page fault for each 
>> 2MB virtual region touched by userland.
> 
> I had a look at what prefault does and page faults should not be
> involved in the measurement of GB/sec. The "stats" also include the
> page faults but the page fault is not part of the printed GB/sec, if
> "-o" is used.

Agreed.

> 
> If the perf test is correct, it looks more an hardware issue with
> memcpy and large TLBs than a software one. memset doesn't exibith it,
> if this was something fundamental memset should also exibith it. It

Yes, I test memset with perf bench, it's little faster with THP:
THP:    6.458863 GB/Sec (with prefault)
NO-THP: 6.393698 GB/Sec (with prefault)

> shall be possible to reproduce this with hugetlbfs in fact... if you
> want to be 100% sure it's not software, you should try that.
> 

Yes, I got following result:
hugetlb:    2.518822 GB/Sec	(with prefault)
no-hugetlb: 3.688322 GB/Sec	(with prefault)

> Chances are there's enough pre-fetching going on in the CPU to
> optimize for those 4k tlb loads in streaming copies, and the
> pagetables are also cached very nicely with streaming copies. Maybe
> large TLBs somewhere are less optimized for streaming copies. Only
> something smarter happening in the CPU optimized for 4k and not yet
> for 2M TLBs can explain this: if the CPU was equally intelligent it
> should definitely be faster with THP on even with "-o".
> 
> Overall I doubt there's anything in software to fix here.
> 
> Also note, this is not related to additional cache usage during page
> faults that I mentioned in the pdf. Page faults or cache effects in
> the page faults are completely removed from the equation because of
> "-o". The prefault pass, eliminates the page faults and trashes away
> all the cache (regardless if the page fault uses non-temporal stores
> or not) before the "measured" memcpy load starts.
> 

Test results from perf stat show a significant reduction in cache-references and cache-misses
when THP is off, how to explain this?
	cache-misses	cache-references
THP:	35455940	66267785
NO-THP: 16920763	17200000

> I don't think this is a major concern, as a proof of thumb you just
> need to prefix the "perf" command with "time" to see it: the THP

I test with "time ./perf bench mem memcpy -l 1gb -o", and the result is
consistent with your expect.

THP:
       3.629896 GB/Sec (with prefault)

real	0m0.849s
user	0m0.472s
sys	0m0.372s

NO-THP:
       6.169184 GB/Sec (with prefault)

real	0m1.013s
user	0m0.412s
sys	0m0.596s

> version still completes much faster despite the prefault part of it
> is slightly slower with THP on.
> 

Why the prefault part is slower with THP on?
perf bench shows when no prefault, with THP on is much faster:

# ./perf bench mem memcpy -l 1gb -n
THP:    1.759009 GB/Sec
NO-THP: 1.291761 GB/Sec

Thanks again for your explanation.

Jianguo Wu.

> THP pays off the most during computations that are accessing randomly,
> and not sequentially.
> 
> Thanks,
> Andrea
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id BB81A6B0032
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 16:20:24 -0400 (EDT)
Date: Tue, 4 Jun 2013 22:20:17 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Transparent Hugepage impact on memcpy
Message-ID: <20130604202017.GJ3463@redhat.com>
References: <51ADAC15.1050103@huawei.com>
 <20130604123050.GA32707@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604123050.GA32707@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, qiuxishi <qiuxishi@huawei.com>

Hello everyone,

On Tue, Jun 04, 2013 at 08:30:51PM +0800, Wanpeng Li wrote:
> On Tue, Jun 04, 2013 at 04:57:57PM +0800, Jianguo Wu wrote:
> >Hi all,
> >
> >I tested memcpy with perf bench, and found that in prefault case, When Transparent Hugepage is on,
> >memcpy has worse performance.
> >
> >When THP on is 3.672879 GB/Sec (with prefault), while THP off is 6.190187 GB/Sec (with prefault).
> >
> 
> I get similar result as you against 3.10-rc4 in the attachment. This
> dues to the characteristic of thp takes a single page fault for each 
> 2MB virtual region touched by userland.

I had a look at what prefault does and page faults should not be
involved in the measurement of GB/sec. The "stats" also include the
page faults but the page fault is not part of the printed GB/sec, if
"-o" is used.

If the perf test is correct, it looks more an hardware issue with
memcpy and large TLBs than a software one. memset doesn't exibith it,
if this was something fundamental memset should also exibith it. It
shall be possible to reproduce this with hugetlbfs in fact... if you
want to be 100% sure it's not software, you should try that.

Chances are there's enough pre-fetching going on in the CPU to
optimize for those 4k tlb loads in streaming copies, and the
pagetables are also cached very nicely with streaming copies. Maybe
large TLBs somewhere are less optimized for streaming copies. Only
something smarter happening in the CPU optimized for 4k and not yet
for 2M TLBs can explain this: if the CPU was equally intelligent it
should definitely be faster with THP on even with "-o".

Overall I doubt there's anything in software to fix here.

Also note, this is not related to additional cache usage during page
faults that I mentioned in the pdf. Page faults or cache effects in
the page faults are completely removed from the equation because of
"-o". The prefault pass, eliminates the page faults and trashes away
all the cache (regardless if the page fault uses non-temporal stores
or not) before the "measured" memcpy load starts.

I don't think this is a major concern, as a proof of thumb you just
need to prefix the "perf" command with "time" to see it: the THP
version still completes much faster despite the prefault part of it
is slightly slower with THP on.

THP pays off the most during computations that are accessing randomly,
and not sequentially.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

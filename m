Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 57CEF6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 15:34:13 -0400 (EDT)
Date: Tue, 25 Sep 2012 21:33:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4 0/8] Avoid cache trashing on clearing huge/gigantic
 page
Message-ID: <20120925193356.GX7620@redhat.com>
References: <1345470757-12005-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120913160506.d394392a.akpm@linux-foundation.org>
 <20120914055210.GC9043@gmail.com>
 <20120925142703.GA1598@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120925142703.GA1598@otc-wbsnb-06>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

Hi Kirill,

On Tue, Sep 25, 2012 at 05:27:03PM +0300, Kirill A. Shutemov wrote:
> On Fri, Sep 14, 2012 at 07:52:10AM +0200, Ingo Molnar wrote:
> > Without repeatable hard numbers such code just gets into the 
> > kernel and bitrots there as new CPU generations come in - a few 
> > years down the line the original decisions often degrade to pure 
> > noise. We've been there, we've done that, we don't want to 
> > repeat it.
> 
> <sorry, for late answer..>
> 
> Hard numbers are hard.
> I've checked some workloads: Mosbench, NPB, specjvm2008. Most of time the
> patchset doesn't show any difference (within run-to-run deviation).
> On NPB it recovers THP regression, but it's probably not enough to make
> decision.
> 
> It would be nice if somebody test the patchset on other system or
> workload. Especially, if the configuration shows regression with
> THP enabled.

If the only workload that gets a benefit is NPB then we've the proof
this is too hardware dependend to be a conclusive result.

It may have been slower by an accident, things like cache
associativity off by one bit, combined with the implicit coloring
provided to the lowest 512 colors could hurts more if the cache
associativity is low.

I'm saying this because NPB on a thinkpad (Intel CPU I assume) is the
benchmark that shows the most benefit among all benchmarks run on that
hardware.

http://www.phoronix.com/scan.php?page=article&item=linux_transparent_hugepages&num=2

I've once seen certain computations that run much slower with perfect
cache coloring but most others runs much faster with the page
coloring. Doesn't mean page coloring is bad per se. So the NPB on that
specific hardware may have been the exception and not the interesting
case. Especially considering the effect of cache-copying is opposite
on slightly different hw.

I think the the static_key should be off by default whenever the CPU
L2 cache size is >= the size of the copy (2*HPAGE_PMD_SIZE). Now the
cache does random replacement so maybe we could also allow cache
copies for twice the size of the copy (L2size >=
4*HPAGE_PMD_SIZE). Current CPUs have caches much larger than 2*2MB...

It would make a whole lot more sense for hugetlbfs giga pages than for
THP (unlike for THP, cache trashing with giga pages is guaranteed),
but even with giga pages, it's not like they're allocated frequently
(maybe once per OS reboot) so that's also sure totally lost in the
noise as it only saves a few accesses after the cache copy is
finished.

It's good to have tested it though.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 21 Nov 2007 14:39:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
In-Reply-To: <20071121222059.GC31674@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0711211434290.3809@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
 <20071115162706.4b9b9e2a.akpm@linux-foundation.org> <20071121222059.GC31674@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Nov 2007, Mel Gorman wrote:

> Overall, the single list is slower than the split lists although seeing it in a
> larger benchmark may be difficult. The biggest suprise by far is that disabling
> the PCPU list altogether seemed to have comparable performance. Intuitively,
> this makes no sense and means the benchmark code should be read over by a
> second person to check for mistakes.
> 
> I cannot see the evidence of this 3x improvement around the 32K filesize
> mark. It may be because my test is very different to what happened before,
> I got something wrong or the per-CPU allocator is not as good as it used to
> be and does not give out the same hot-pages all the time. I tried running
> tests on 2.6.23 but the results of PCPU vs no-PCPU were comparable to
> 2.6.24-rc2-mm1 so it is not something that has changed very recently.
> 
> As it is, the single PCP list may need another revision or at least
> more investigation to see why it slows so much in comparison to the split
> lists. The more controversial question is why disabling PCP appeared to make
> no difference in this test.

The disabling of PCPs is for us (SGI) a performance benefit for certain 
loads and we have seen this in tests about 2 years ago.

I sure wish to know why the single PCP list is not that efficient. Could 
you simply remove the cold handling and put all pages always at the front 
and always allocate from the front? Maybe it is the additional list 
handling overhead that makes the difference.

> Any comments on the test or what could be done differently?

1) Could you label the axis? Its a bit difficult to see what you exactly 
are measuring there.

2) it may be useful to do these tests with anonymous pages because the 
file handling paths are rather slow and you may not hit zone lock 
contention because there are other things in the way (radix tree?)
 
> o The fact the machine was NUMA might have skewed the results. I bound the CPU,
>   but did not set nodemasks. Node-local policies should have been used. I have
>   kicked off tests on bl6-13 which has 4 cores but non-NUMA. It'll be a long
>   time before they complete though

The ratio of processors per node is important to see the lock contention 
here. Or run an SMP system with lots of processors.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

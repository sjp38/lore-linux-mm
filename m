Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AA7476B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 17:52:51 -0500 (EST)
Date: Wed, 24 Feb 2010 23:52:04 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 36/36] khugepaged
Message-ID: <20100224225204.GG29956@random.random>
References: <20100221141009.581909647@redhat.com>
 <20100221141758.658303189@redhat.com>
 <20100224121111.232602ba.akpm@linux-foundation.org>
 <4B858BFC.8020801@redhat.com>
 <20100224125253.2edb4571.akpm@linux-foundation.org>
 <4B8592BB.1040007@redhat.com>
 <20100224131220.396216af.akpm@linux-foundation.org>
 <4B859900.6060504@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B859900.6060504@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 04:24:16PM -0500, Rik van Riel wrote:
> The hugepage patchset as it stands tries to allocate huge
> pages synchronously, but will fall back to normal 4kB pages
> if they are not.
> 
> Similarly, khugepaged only compacts anonymous memory into
> hugepages if/when hugepages become available.
> 
> Trying to always allocate hugepages synchronously would
> mean potentially having to defragment memory synchronously,
> before we can allocate memory for a page fault.
> 
> While I have no numbers, I have the strong suspicion that
> the performance impact of potentially defragmenting 2MB
> of memory before each page fault could lead to more
> performance inconsistency than allocating small pages at
> first and having them collapsed into large pages later...
> 
> The amount of work involved in making a 2MB page available
> could be fairly big, which is why I suspect we will be
> better off doing it asynchronously - preferably on otherwise
> idle CPU core.

I agree. This is also why I have doubts we'll need a memory compaction
kernel thread that has to provide free hugepages always available for
page faults. But that's another topic and the memory compaction kernel
thread may be worth it indipendent of khugepaged. Surely if there
wasn't khugepaged, such a memory compaction kernel thread would be a
must, but we need khugepaged for other reasons too so we can as well
take advantage of it to speedup the short lived allocations by not
requiring them to defrag memory. Long lived allocations will be taken
care of by khugepaged.

The fundamental reason why khugepaged is unavoidable, is that some
memory can be fragmented and not everything can be relocated. So when
a virtual machine quits and releases gigabytes of hugepages, we want
to use those freely available hugepages to create huge-pmd in the
other virtual machines that may be running on fragmented memory, to
maximize the CPU efficiency at all times. The scan is slow, it takes
nearly zero cpu time, except when it copies data (in which case it
means we definitely want to pay for that cpu time) so it seems a good
tradeoff.

As sysctl that control defrag there is only one right now and it turns
defrag on and off. We could make it more finegrined and have two
files, one for the page faults in transparent_hugepage/defrag as
always|madvise|never, and one yes|no in
transparent_hugepage/khugepaged/defrag but that may be
overdesign... I'm not sure really when and how to invoke memory
compaction, so having that maximum amount of knobs really is only
requires if we can't came up with an optimal design. If we can came up
with an optimal solution the current system wide "yes|no" in
transparent_hugepage/defrag should be enough (currently it defaults to
"no" because there's no real memory compaction invoked yet, and
shrinking blind isn't very helpful anyway, unless we go with
__GFP_REPEAT|GFP_IO|GFP_FS which stalls the system often).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

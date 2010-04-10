Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F41B26B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 17:01:45 -0400 (EDT)
Message-ID: <4BC0E6ED.7040100@redhat.com>
Date: Sun, 11 Apr 2010 00:00:29 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <20100406011345.GT5825@random.random> <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org> <20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> <20100410204756.GR5708@random.random>
In-Reply-To: <20100410204756.GR5708@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/10/2010 11:47 PM, Andrea Arcangeli wrote:
> On Sat, Apr 10, 2010 at 11:42:44PM +0300, Avi Kivity wrote:
>    
>> 3-5% improvement.  I had to tune khugepaged to scan more aggressively
>> since the run is so short.  The working set is only ~100MB here though.
>>      
> We need to either solve it with a kernel workaround or have an
> environment var for glibc to do the right thing...
>
>    

IMO, both.  The kernel should align vmas on 2MB boundaries (good for 
small pages as well).  glibc should use 2MB increments.  Even on <2MB 
sized vmas, the kernel should reserve the large page frame for a while 
in the hope that the application will use it in a short while.

> The best I got so far with gcc is with, about half goes in hugepages
> with this but it's not enough as likely lib invoked mallocs goes into
> heap and extended 1M at time.
>    

There are also guard pages around stacks IIRC, we could make them 2MB on 
x86-64.

> export MALLOC_MMAP_THRESHOLD_=$[1024*1024*1024]
> export MALLOC_TOP_PAD_=$[1024*1024*1024]
>
> Whatever we do, it has to be possible to disable it of course with
> malloc debug options, or with electric fence of course, but it's not
> like the default 1M provides any benefit compared to growing it 2M
> aligned ;) so it's quite an obvious thing to address in glibc in my
> view.

Well, but mapping a 2MB vma with a large page could be a considerable 
waste if the application doesn't eventually use it.  I'd like to map the 
pages with small pages (belonging to a large frame) and if the 
application actually uses the pages, switch to a large pte.

Something that can also improve small pages is to prefault the vma with 
small pages, but with the accessed and dirty bit cleared.  Later, we 
check those bits and reclaim the pages if they're unused, or coalesce 
them if they were used.  The nice thing is that we save tons of page 
faults in the common case where the pages are used.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

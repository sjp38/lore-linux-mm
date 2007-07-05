Date: Fri, 6 Jul 2007 07:18:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <20070706071853.9434deae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070705181308.GB8320@stroyan.net>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
	<20070705181308.GB8320@stroyan.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Stroyan <mike@stroyan.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, clameter@sgi.com, y-goto@jp.fujitsu.com, dmosberger@gmail.com, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Thu, 5 Jul 2007 12:13:09 -0600
Mike Stroyan <mike@stroyan.net> wrote:
>   The L3 cache is involved in the HP-UX defect description because the
> earlier HP-UX patch PHKL_33781 added flushing of the instruction cache
> when an executable mapping was removed.  Linux never added that
> unsuccessfull attempt at montecito cache coherency.  In the current
> linux situation it can execute old cache lines straight from L2 icache.
> 
Hmm... I couldn't understand "why icache includes old lines in a new page."
This happens at
 - a file is newly loaded into page-cache.
 - only on NFS.
 - happens very *often* if the program is unlucky.

So I wrote my understainding as I think.

> > Now, I think icache should be flushed before set_pte().
> > This is a patch to try that.
> > 
> > 1. remove all lazy_mmu_prot_update()...which is used by only ia64.
> > 2. implements flush_cache_page()/flush_icache_page() for ia64.
> > 
> > Something unsure....
> > 3. mprotect() flushes cache before removing pte. Is this sane ?
> >    I added flush_icache_range() before set_pte() here.
> > 
> > Any comments and advices ?
> 
>   I am concerned about performance consequences.  With the change
> from lazy_mmu_prot_update to __flush_icache_page_ia64 you dropped
> the code that avoids icache flushes for non-executable pages.

Hmm? I added VM_EXEC check in flush_(d|i)cache_page(). Isn't it enough ?

> Section 4.6.2 of David Mosberger and Stephane Eranian's
> "ia-64 linux kernel design and implementation" goes into some
> detail about the performance penalties avoided by limiting icache
> flushes to executable pages and defering flushes until the first
> fault for execution.
> 
>   Have you done any benchmarking to measure the performance
> effect of these additional cache flushes?  It would be particularly
> interesting to measure on large systems with many CPUs.  The fc.i
> instruction needs to be broadcast to all CPUs in the system.

no benchmarks yet.

> 
>   The only defect that I see in the current implementation of
> lazy_mmu_prot_update() is that it is called too late in some
> functions that are already calling it.  Are your large changes
> attempting to correct other defects?  Or are you simplifying
> away potentially valuable code because you don't understand it?
> 
I know your *simple* patch in April wasn't included. So I wrote this.
In April thread, commenter's advices was "implement flush_icache_page()" I think.  
If you have a better patch, please post.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id E27936B0036
	for <linux-mm@kvack.org>; Thu, 16 May 2013 13:14:46 -0400 (EDT)
Message-ID: <51951403.6030605@sr71.net>
Date: Thu, 16 May 2013 10:14:43 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 5/7] create __remove_mapping_batch()
References: <20130507211954.9815F9D1@viggo.jf.intel.com> <20130507212001.49F5E197@viggo.jf.intel.com> <20130514155117.GW11497@suse.de>
In-Reply-To: <20130514155117.GW11497@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tim.c.chen@linux.intel.com

On 05/14/2013 08:51 AM, Mel Gorman wrote:
> The same comments I had before about potentially long page lock hold
> times still apply at this point. Andrew's concerns about the worst-case
> scenario where no adjacent page on the LRU has the same mapping also
> still applies. Is there any noticable overhead with his suggested
> workload of a single threaded process that opens files touching one page
> in each file until reclaim starts?

This is an attempt to address some of Andrew's concerns from here:

 	http://lkml.kernel.org/r/20120912122758.ad15e10f.akpm@linux-foundation.org

The executive summary: This does cause a small amount of increased CPU
time in __remove_mapping_batch().  But, it *is* small and it comes with
a throughput increase.

Test #1:

1. My goal here was to create an LRU with as few adjacent pages in the
   same file as possible.
2. Using lots of small files turned out to be a pain in the butt just
   because I need to create tens of thousands of them.
3. I ended up writing a program that does:
	for (offset = 0; offset < somenumber; offset += PAGE_SIZE)
		for_each_file(f)
			read(f, offset)...
4. This was sitting in a loop where the working set of my file reads was
   slightly larger than the total amount of memory, so we were
   effectively evicting page cache with streaming reads.

Even doing that above loop across ~2k files at once, __remove_mapping()
itself isn't CPU intensive in the single-threaded case.  In my testing,
it only shows up at 0.021% of CPU usage.  That went up to 0.036% (and
shifted to __remove_mapping_batch()) with these patches applied.

In any case, there are no showstoppers here.  We're way down looking at
the 0.01% of CPU time scale.

    sample    %
     delta   change
    ------   ------
       462     2.7% ata_scsi_queuecmd
       194     0.1% default_idle
        59   999.9% __remove_mapping_batch
        54   490.9% prepare_to_wait
        41   585.7% rcu_process_callbacks
       -32   -49.2% blk_queue_bio
       -35  -100.0% __remove_mapping
       -38   -33.6% generic_file_aio_read
       -41   -68.3% mix_pool_bytes.constprop.0
       -48   -11.9% __wake_up
       -53   -66.2% copy_user_generic_string
       -75    -8.4% finish_task_switch
       -79   -53.4% cpu_startup_entry
       -87   -15.9% blk_end_bidi_request
      -109   -14.3% scsi_request_fn
      -172    -3.6% __do_softirq

Test #2:

The second test I did was a single-threaded dd.  I did a 4GB dd over and
over with just barely less than 4GB of memory available.  This was the
test that we would expect to hurt us in the single-threaded case since
we spread out accesses to 'struct page' over time and have less cache
warmth.  The total disk throughput (as reported by vmstat) actually went
_up_ 6% in this case with these patches.

Here are the relevant bits grepped out of 'perf report' during the dd:

> -------- perf.vanilla.data ----------
>      3.75%         swapper  [kernel.kallsyms]     [k] intel_idle                                
>      2.83%              dd  [kernel.kallsyms]     [k] put_page                                  
>      1.30%         kswapd0  [kernel.kallsyms]     [k] __ticket_spin_lock                        
>      1.05%              dd  [kernel.kallsyms]     [k] __ticket_spin_lock                        
>      1.04%         kswapd0  [kernel.kallsyms]     [k] shrink_page_list                          
>      0.38%         kswapd0  [kernel.kallsyms]     [k] __remove_mapping                          
>      0.34%         kswapd0  [kernel.kallsyms]     [k] put_page                                  
> -------- perf.patched.data ----------
>      4.47%          swapper  [kernel.kallsyms]           [k] intel_idle                                               
>      2.02%               dd  [kernel.kallsyms]           [k] put_page                                                 
>      1.55%               dd  [kernel.kallsyms]           [k] __ticket_spin_lock                                       
>      1.21%          kswapd0  [kernel.kallsyms]           [k] shrink_page_list                                         
>      0.97%          kswapd0  [kernel.kallsyms]           [k] __ticket_spin_lock                                       
>      0.43%          kswapd0  [kernel.kallsyms]           [k] put_page                                                 
>      0.36%          kswapd0  [kernel.kallsyms]           [k] __remove_mapping                                         
>      0.28%          kswapd0  [kernel.kallsyms]           [k] __remove_mapping_batch                 

And the same functions from 'perf diff':

>              +4.47%  [kernel.kallsyms]           [k] intel_idle                                               
>      3.22%   -0.77%  [kernel.kallsyms]           [k] put_page                                                 
>              +1.21%  [kernel.kallsyms]           [k] shrink_page_list                                         
>              +0.36%  [kernel.kallsyms]           [k] __remove_mapping                                         
>              +0.28%  [kernel.kallsyms]           [k] __remove_mapping_batch                                   
>      0.39%   -0.39%  [kernel.kallsyms]           [k] __remove_mapping                                         
>      1.04%   -1.04%  [kernel.kallsyms]           [k] shrink_page_list                                         
>      3.68%   -3.68%  [kernel.kallsyms]           [k] intel_idle                                    

1. Idle time goes up by quite a bit, probably since we hold the page
   locks longer amounts of time, and cause more sleeping on them
2. put_page() got substantially cheaper, probably since we are now doing
   all the put_page()s closer to each other.
3. __remove_mapping_batch() is definitely costing us CPU, and not
   directly saving it anywhere else (like shrink_page_list() which also
   gets a bit worse)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

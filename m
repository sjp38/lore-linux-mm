Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id C2E266B0044
	for <linux-mm@kvack.org>; Thu, 17 May 2012 05:07:31 -0400 (EDT)
Message-ID: <4FB4BFFD.5030508@kernel.org>
Date: Thu, 17 May 2012 18:08:13 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] zsmalloc: support zsmalloc to ARM, MIPS, SUPERH
References: <1337133919-4182-1-git-send-email-minchan@kernel.org> <20120517083213.GC14027@linux-sh.org>
In-Reply-To: <20120517083213.GC14027@linux-sh.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Chen Liqin <liqin.chen@sunplusct.com>

On 05/17/2012 05:32 PM, Paul Mundt wrote:

> On Wed, May 16, 2012 at 11:05:17AM +0900, Minchan Kim wrote:
>> About local_flush_tlb_kernel_range,
>> If architecture is very smart, it could flush only tlb entries related to vaddr.
>> If architecture is smart, it could flush only tlb entries related to a CPU.
>> If architecture is _NOT_ smart, it could flush all entries of all CPUs.
>> So, it would be best to support both portability and performance.
>>
> ..
> 
>> Need double check about supporting local_flush_tlb_kernel_range
>> in ARM, MIPS, SUPERH maintainers. And I will Ccing unicore32 and
>> score maintainers because arch directory in those arch have
>> local_flush_tlb_kernel_range, too but I'm very unfamiliar with those
>> architecture so pass it to maintainers.
>> I didn't coded up dumb local_flush_tlb_kernel_range which flush
>> all cpus. I expect someone need ZSMALLOC will implement it easily in future.
>>
> 
> One thing you might consider is providing a stubbed definition that wraps
> to flush_tlb_kernel_range() in the !SMP case, as this will extend your
> testing coverage for staging considerably.
> 
> Once you exclude all of the non-SMP platforms, you're left with the
> following:
> 
> 	- blackfin: doesn't count, no TLB to worry about.
> 	- hexagon: seems to imply that the SMP case uses thread-based
> 	  CPUs that share an MMU, so no additional cost.
> 	- ia64: Does a global flush, which already has a FIXME comment.
> 	- m32r, mn10300: local_flush_tlb_all() could be wrapped.
> 	- parisc: global flush?
> 	- s390: Tests the cpumask to do a local flush, otherwise has a
> 	  __tlb_flush_local() that can be wrapped.
> 	- sparc32: global flush
> 	- sparc64: __flush_tlb_kernel_range() looks like a local flush.
> 	- tile: does strange hypervisory things, presumably global.
> 	- x86: has a local_flush_tlb() that could be wrapped.
> 
> Which doesn't look quite that bad. You could probably get away with a
> Kconfig option for optimized local TLB flushing or something, since
> single function Kconfig options seem to be all the rage these days.


I missed this sentence.

Thanks for very helpful comment, Paul!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

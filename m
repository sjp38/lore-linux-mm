Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 0816F6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 08:58:32 -0400 (EDT)
Date: Tue, 25 Sep 2012 13:58:24 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: sparsemem issues
Message-ID: <20120925125824.GF11266@suse.de>
References: <CAEkdkmVnnCCHvrFzhib_USGQGQYc7UhQjO-nTyp+RLiTXjRtGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAEkdkmVnnCCHvrFzhib_USGQGQYc7UhQjO-nTyp+RLiTXjRtGA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ss ss <nizhan.chen@gmail.com>
Cc: linux-mm@kvack.org, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, wency@cn.fujitsu.com, Bob Picco <bob.picco@hp.com>, Dave Hansen <haveblue@us.ibm.com>

On Tue, Sep 25, 2012 at 07:27:42PM +0800, ss ss wrote:
> Hi all,
> 
> This is my first time send email to mm community, if something is wrong or
> silly, please forgive me.
> I have some confusions of sparsemem:
> 
> 1. sparsemem
> 
> It seems that all mem_sections descriptors (except the second level if use
> sparsemem extreme )are allocated
> before memory_present, then when the are allocated ?
> 

In the simple case, from the bootmem allocator during system
initialisation. It's more complex in the memory hotplug case.

> 2. sparsemem extreme
> 
> sparsemem extreme implementation [commit : 3e347261a80b57df] changelog:
> 
>  "This two level layout scheme is able to achieve smaller memory
> requirements for SPARSEMEM
>   with the tradeoff of an additional shift and load when fetching the
> memory section."
> 
> then how to judge when the benefit from achieve smaller memory
>  requirements for SPARSEMEM
> is worth with the additional shift and load when fetching the memory
> section.??
> 

Experimentation.

> "The patch attempts isolates the implementation details of the physical
> layout of the sparsemem section
>  array."
> 
> but how it isolates?
> 

That's effectively a "how long is a piece of string?" question. There is
no way to answer it properly.

> 3. sparsemem vmemmap
> 
> 1)
>  The two key operations pfn_to_page and page_to_page become:
> 
>     #define __pfn_to_page(pfn)      (vmemmap + (pfn))
>     #define __page_to_pfn(page)     ((page) - vmemmap)
> 
> how can guarantee the block of memory to be used to back the virtual memory
> map is start from vmemmap?
> 

Because vmemmap is just a pointer to a place in memory where the math
works out. It's not necessary backed by RAM as it's just a virtual mapping.
I suggest you read the original commit message that introduced vmemmap and
the discussions around the time when it was introduced. It's a bit of legwork
but it should explain some of the motivations of vmemmap and how it works.

> 2)
> in Documentation/x86/x86_64/mm.txt
> 
> Virtual memory map with 4 level page tables:
> 
> 0000000000000000 - 00007fffffffffff (=47 bits) user space, different per mm
> hole caused by [48:63] sign extension
> ffff800000000000 - ffff80ffffffffff (=40 bits) guard hole
> ffff880000000000 - ffffc7ffffffffff (=64 TB) direct mapping of all phys.
> memory
> ffffc80000000000 - ffffc8ffffffffff (=40 bits) hole
> ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space
> ffffe90000000000 - ffffe9ffffffffff (=40 bits) hole
> ffffea0000000000 - ffffeaffffffffff (=40 bits) virtual memory map (1TB)
> ... unused hole ...
> ffffffff80000000 - ffffffffa0000000 (=512 MB)  kernel text mapping, from
> phys 0
> ffffffffa0000000 - fffffffffff00000 (=1536 MB) module mapping space
> 
> what's the total memory of the example? why virtual memory map(1TB) is that
> big ? then in x86_64 platform 4GB memory, virtual memory map will start
> from what address?
> 

This is the virtual address layout, it does not say anything about how
much memory is installed in the machine. The rest of the questions are
vague and I cannot think of a sensible way of answering them.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

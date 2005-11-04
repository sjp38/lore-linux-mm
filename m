Date: Fri, 04 Nov 2005 09:10:28 -0800
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <335310000.1131124228@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.64.0511040814530.27915@g5.osdl.org>
References: <20051104145628.90DC71845CE@thermo.lanl.gov><Pine.LNX.4.64.0511040738540.27915@g5.osdl.org> <331390000.1131120808@[10.10.2.4]> <Pine.LNX.4.64.0511040814530.27915@g5.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andy Nelson <andy@thermo.lanl.gov>, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

>> Well, I think it depends on the workload a lot. However fast your TLB is,
>> if we move from "every cacheline read requires is a TLB miss" to "every
>> cacheline read is a TLB hit" that can be a huge performance knee however
>> fast your TLB is. Depends heavily on the locality of reference and size
>> of data set of the application, I suspect.
> 
> I'm sure there are really pathological examples, but the thing is, they 
> won't be on reasonable code.
> 
> Some modern CPU's have TLB's that can span the whole cache. In other 
> words, if your data is in _any_ level of caches, the TLB will be big 
> enough to find it.
> 
> Yes, that's not universally true, and when it's true, the TLB is two-level 
> and you can have loads where it will usually miss in the first level, but 
> we're now talking about loads where the _data_ will then always miss in 
> the first level cache too. So the TLB miss cost will always be _lower_ 
> than the data miss cost.
> 
> Right now, you should buy Opteron if you want that kind of large TLB. I 
> _think_ Intel still has "small" TLB's (the cpuid information only goes up 
> to 128 entries, I think), but at least Intel has a really good fill. And I 
> would bet (but have no first-hand information) that next generation 
> processors will only get bigger TLB's. These things don't tend to shrink.

Well. Last time I looked they had something in the order of 512 entries
per MB of cache or so (ie 2MB of coverage per MB of cache). So it'll only 
cover it if you're using 2K of the data in each page (50%), but not if 
you're touching cachelines distributed widely over pages. with large 
pages, you cover 1000 times that much. Some apps may not be able to 
acheive a 50% locality of reference, just by their nature ... not sure 
that's bad programming for the big number crunching cases, or DB workloads 
with random access patterns to large data sets.

Of course, this doesn't just apply to HPC/database either. dcache walks
on large fileserver, etc. 

Even if we're talking data cache / icache misses, it gets even worse,
doesn't it? Several cacheline misses for pagetable walks per data cacheline
miss. Lots of the compute intensive stuff doesn't even come close to 
fitting in data cache by orders of magnitude.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

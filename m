Subject: Re: Better pagecache statistics ?
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1133452790.27824.117.camel@localhost.localdomain>
References: <1133377029.27824.90.camel@localhost.localdomain>
	 <20051201152029.GA14499@dmt.cnet>
	 <1133452790.27824.117.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 01 Dec 2005 17:10:11 +0100
Message-Id: <1133453411.2853.67.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Out of "Cached" value - to get details like
> 
> 	<mmap> - xxx KB
> 	<shared mem> - xxx KB
> 	<text, data, bss, malloc, heap, stacks> - xxx KB
> 	<filecache pages total> -- xxx KB
> 		(filename1 or <dev>, <ino>) -- #of pages
> 		(filename2 or <dev>, <ino>) -- #of pages
> 		
> This would be really powerful on understanding system better.

to some extend it might be useful.
I have a few concerns though
1) If we make these stats into an ABI then it becomes harder to change
the architecture of the VM radically since such concepts may not even
exist in the new architecture. As long as this is some sort of advisory,
humans-only file I think this isn't too much of a big deal though.

2) not all the concepts you mention really exist as far as the kernel is
concerned. I mean.. a mmap file is file cache is .. etc.
malloc/heap/stacks are also not differentiated too much and are mostly
userspace policy (especially thread stacks). 

A split in
* non-file backed
  - mapped once
  - mapped more than once
* file backed
  - mapped at least once
  - not mapped
I can see as being meaningful. Assigning meaning to it beyond this is
dangerous; that is more an interpretation of the policy userspace
happens to use for things and I think coding that into the kernel is a
mistake.

Knowing which files are in memory how much is, as debug feature,
potentially quite useful for VM hackers to see how well the various VM
algorithms work. I'm concerned about the performance impact (eg you can
do it only once a day or so, not every 10 seconds) and about how to get
this data out in a consistent way (after all, spewing this amount of
debug info will in itself impact the vm balances)

Greetings,
    Arjan van de Ven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

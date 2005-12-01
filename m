Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jB1GNcrV005346
	for <linux-mm@kvack.org>; Thu, 1 Dec 2005 11:23:38 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jB1GN5SI097182
	for <linux-mm@kvack.org>; Thu, 1 Dec 2005 09:23:05 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jB1GNbVe005561
	for <linux-mm@kvack.org>; Thu, 1 Dec 2005 09:23:38 -0700
Subject: Re: Better pagecache statistics ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <1133453411.2853.67.camel@laptopd505.fenrus.org>
References: <1133377029.27824.90.camel@localhost.localdomain>
	 <20051201152029.GA14499@dmt.cnet>
	 <1133452790.27824.117.camel@localhost.localdomain>
	 <1133453411.2853.67.camel@laptopd505.fenrus.org>
Content-Type: text/plain
Date: Thu, 01 Dec 2005 08:23:48 -0800
Message-Id: <1133454228.21429.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-12-01 at 17:10 +0100, Arjan van de Ven wrote:
> > Out of "Cached" value - to get details like
> > 
> > 	<mmap> - xxx KB
> > 	<shared mem> - xxx KB
> > 	<text, data, bss, malloc, heap, stacks> - xxx KB
> > 	<filecache pages total> -- xxx KB
> > 		(filename1 or <dev>, <ino>) -- #of pages
> > 		(filename2 or <dev>, <ino>) -- #of pages
> > 		
> > This would be really powerful on understanding system better.
> 
> to some extend it might be useful.
> I have a few concerns though
> 1) If we make these stats into an ABI then it becomes harder to change
> the architecture of the VM radically since such concepts may not even
> exist in the new architecture. As long as this is some sort of advisory,
> humans-only file I think this isn't too much of a big deal though.

ABI or API ? yuck. I am thinking more like a /proc/cachedetail like
thing (mostly for debug).

> 
> 2) not all the concepts you mention really exist as far as the kernel is
> concerned. I mean.. a mmap file is file cache is .. etc.
> malloc/heap/stacks are also not differentiated too much and are mostly
> userspace policy (especially thread stacks). 
> 
> A split in
> * non-file backed
>   - mapped once
>   - mapped more than once
> * file backed
>   - mapped at least once
>   - not mapped
> I can see as being meaningful. Assigning meaning to it beyond this is
> dangerous; that is more an interpretation of the policy userspace
> happens to use for things and I think coding that into the kernel is a
> mistake.

You are right. I think, kernel should NOT try to distinguish more than
that. This would at least separate out most of the stuff anyway (with
few execeptions).

> 
> Knowing which files are in memory how much is, as debug feature,
> potentially quite useful for VM hackers to see how well the various VM
> algorithms work. I'm concerned about the performance impact (eg you can
> do it only once a day or so, not every 10 seconds) and about how to get
> this data out in a consistent way (after all, spewing this amount of
> debug info will in itself impact the vm balances)

Yes. I am worried about that too. We do have "mapping->nrpages"  to
represent how many of them are in cache. But getting to all mappings
(especially the ones we can't get to from any process - closed files)
and printing them is quite expensive and need to hold locks :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

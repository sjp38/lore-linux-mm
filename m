Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iB8J8MGM013002
	for <linux-mm@kvack.org>; Wed, 8 Dec 2004 14:08:22 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iB8J8M1m280270
	for <linux-mm@kvack.org>; Wed, 8 Dec 2004 14:08:22 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iB8J8H0n022240
	for <linux-mm@kvack.org>; Wed, 8 Dec 2004 14:08:21 -0500
Date: Wed, 08 Dec 2004 11:07:27 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Anticipatory prefaulting in the page fault handler V1
Message-ID: <140570000.1102532847@flay>
In-Reply-To: <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain><Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com><Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org><Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com><Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org><Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com><Pine.LNX.4.58.0412011608500.22796@ppc970.osdl.org> <41AEB44D.2040805@pobox.com><20041201223441.3820fbc0.akpm@osdl.org> <41AEBAB9.3050705@pobox.com><20041201230217.1d2071a8.akpm@osdl.org> <179540000.1101972418@[10.10.2.4]><41AEC4D7.4060507@pobox.com> <20041202101029.7fe8b303.cliffw@osdl.org> <Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, nickpiggin@yahoo.com.au
Cc: Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> The page fault handler for anonymous pages can generate significant overhead
> apart from its essential function which is to clear and setup a new page
> table entry for a never accessed memory location. This overhead increases
> significantly in an SMP environment.
> 
> In the page table scalability patches, we addressed the issue by changing
> the locking scheme so that multiple fault handlers are able to be processed
> concurrently on multiple cpus. This patch attempts to aggregate multiple
> page faults into a single one. It does that by noting
> anonymous page faults generated in sequence by an application.
> 
> If a fault occurred for page x and is then followed by page x+1 then it may
> be reasonable to expect another page fault at x+2 in the future. If page
> table entries for x+1 and x+2 would be prepared in the fault handling for
> page x+1 then the overhead of taking a fault for x+2 is avoided. However
> page x+2 may never be used and thus we may have increased the rss
> of an application unnecessarily. The swapper will take care of removing
> that page if memory should get tight.
> 
> The following patch makes the anonymous fault handler anticipate future
> faults. For each fault a prediction is made where the fault would occur
> (assuming linear acccess by the application). If the prediction turns out to
> be right (next fault is where expected) then a number of pages is
> preallocated in order to avoid a series of future faults. The order of the
> preallocation increases by the power of two for each success in sequence.
> 
> The first successful prediction leads to an additional page being allocated.
> Second successful prediction leads to 2 additional pages being allocated.
> Third to 4 pages and so on. The max order is 3 by default. In a large
> continous allocation the number of faults is reduced by a factor of 8.
> 
> The patch may be combined with the page fault scalability patch (another
> edition of the patch is needed which will be forthcoming after the
> page fault scalability patch has been included). The combined patches
> will triple the possible page fault rate from ~1 mio faults sec to 3 mio
> faults sec.
> 
> Standard Kernel on a 512 Cpu machine allocating 32GB with an increasing
> number of threads (and thus increasing parallellism of page faults):

Mmmm ... we tried doing this before for filebacked pages by sniffing the
pagecache, but it crippled forky workloads (like kernel compile) with the 
extra cost in zap_pte_range, etc. 

Perhaps the locality is better for the anon stuff, but the cost is also
higher. Exactly what benchmark were you running on this? If you just run
a microbenchmark that allocates memory, then it will definitely be faster.
On other things, I suspect not ...

M.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

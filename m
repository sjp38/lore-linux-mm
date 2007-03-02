Message-ID: <45E7B276.3020504@goop.org>
Date: Thu, 01 Mar 2007 21:13:26 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org> <45E7835A.8000908@in.ibm.com> <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Balbir Singh <balbir@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> Virtualization in general. We don't know what it is - in IBM machines it's 
> a hypervisor. With Xen and VMware, it's usually a hypervisor too. With 
> KVM, it's obviously a host Linux kernel/user-process combination.
>
> The point being that in the guests, hotunplug is almost useless (for 
> bigger ranges), and we're much better off just telling the virtualization 
> hosts on a per-page level whether we care about a page or not, than to 
> worry about fragmentation.
>
> And in hosts, we usually don't care EITHER, since it's usually done in a 
> hypervisor.
>   

The paravirt_ops patches I just posted implement all the machinery
required to create a pseudo-physical to machine address mapping under
the kernel.  This is used under Xen because it directly exposes the
pagetables to its guests, but there's no reason why you couldn't use
this layer to implement the same mapping without an underlying
hypervisor.  This allows the kernel to see a normal linear "physical"
address space which is in fact its mapped over a discontigious set of
machine ("real physical") pages.

Andrew and I discussed using it for a kdump kernel, so that you could
load it into a random bunch of pages, and set things up so that it sees
itself as being contiguous.

The mapping is pretty simple.  It intercepts __pte (__pmd, etc) to map
the "physical" page to the real machine page, and pte_val does the
reverse mapping.

You could implement this today as a farily simple, thin paravirt_ops
backend.  The main tricky part is making sure all the device drivers are
correct in using bus addresses (which are mapped to real machine
addresses), and that they don't assume that adjacent kernel virtual
pages are physically adjacent.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 12 Oct 2004 08:16:51 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: NUMA: Patch for node based swapping
Message-ID: <1513170000.1097594210@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.58.0410120751010.11558@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0410120751010.11558@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> In a NUMA systems single nodes may run out of memory. This may occur even
> by only reading from files which will clutter node memory with cached
> pages from the file.
> 
> However, as long as the system as a whole does have enough memory
> available, kswapd is not run at all. This means that a process allocating
> memory and running on a node that has no memory left, will get memory
> allocated from other nodes which is inefficient to handle. It would be
> better if kswapd would throw out some pages (maybe some of the cached
> pages from files that have only once been read) to reclaim memory in the
> node.
> 
> The following patch checks the memory usage after each allocation in a
> zone. If the allocation in a zone falls below a certain minimum, kswapd is
> started for that zone alone.

I agree it's a problem, but you really don't want to go kicking pages out
to disk when we have free memory - the solution is, I think, to migrate
the least-recently used pages out to the other node, not all the way to
disk. The page relocate stuff from the defrag code being proposed may help
(if they fix it not to go via swap ;-)). I'll try to find some time to
look at it again.

M.

PS, might be possible to add a mechanism to ask kswapd to reclaim some 
cache pages without doing swapout, but I fear of messing with the delicate
balance of the universe - cache vs user.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

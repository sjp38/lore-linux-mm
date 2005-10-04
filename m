From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH]: Clean up of __alloc_pages
Date: Tue, 4 Oct 2005 12:02:52 -0500
References: <20051001120023.A10250@unix-os.sc.intel.com>
 <200510041126.53247.raybry@mpdtxmail.amd.com>
 <138020000.1128442248@[10.10.2.4]>
In-Reply-To: <138020000.1128442248@[10.10.2.4]>
MIME-Version: 1.0
Message-ID: <200510041202.53016.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Andi Kleen <ak@suse.de>, Rohit Seth <rohit.seth@intel.com>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 04 October 2005 11:10, Martin J. Bligh wrote:
> --Ray Bryant <raybry@mpdtxmail.amd.com> wrote (on Tuesday, October 04, 2005 
>
 <snip> 

> >
> > That's exactly what Martin Hick's additions to __alloc_pages() were
> > trying to achieve.   However, we've never figured out how to make the
> > "very low overhead light try to free pages" thing work with low enough
> > overhead that it can be left on all of the time.    As soon as we make
> > this the least bit more expensive, then this hurts those workloads (file
> > servers being one example) who don't care about local, but who need the
> > fastest possible allocations.
> >
> > This problem is often a showstopper on larger NUMA systems, at least for
> > HPC type applications, where the inability to guarantee local storage
> > allocation when it is requested can make the application run
> > significantly slower.
>
> Can we not do some migration / more targeted pressure balancing in kswapd?
> Ie if we had a constant measure of per-node pressure, we could notice an
> imbalance, and start migrating the least recently used pages from the node
> under most pressure to the node under least ...
>
> M.
>

Unfortunately, I think that anything that doesn't happen synchronously (with 
the original allocation request) happens to late.    In order to make this 
work we'd have to not only migrate the excess page cache pages off of the 
loaded nodes, but find the supposed-to-be-local pages that got allocated off 
node and migrate them back.   I'm not sure how to do all of that.  :-)

(Another way to think about this is that if we truly balanced page cache 
allocations across nodes via migration, then we could have equally as well 
originally allocated the page cache pages round-robin across the nodes and 
gotten the balancing for free.)

Another idea that I have been kicking around for some time is the notion of a
MPOL_LOCAL memory policy.    MPOL_LOCAL would be kind of like a dynamic 
MPOL_BIND in the sense that the policy would allow allocation only on a 
single node, but that signal node would be dynamically set to the current 
node (rather than statically set ala MPOL_BIND).    The result of such  an 
allocation policy would be that if a local allocation can't be made, then the 
current task will end up in synchronous page reclaim until some memory 
becomes free.  That would force clean page cache pages to be discarded.
(This idea is similar, in spirit, to Rohit's suggestion for __GFP_NODEONLY...)

The intent of this is for an otherwise mempolicy unaware application to be run 
under numactl and MPOL_LOCAL if it requires local storage allocations.
File server applications (or other applications that demand the fastest 
storage allocation without regard to local) would chose not to be run in such 
a fashion.

The down side of this is that a task that requests more memory than is 
available on a node (and is running under MPOL_LOCAL) could invoke the OOM 
handler.    We'd have to special case this under the OOM handler, I would 
imagine, although a similar problem may exist with MPOL_BIND at the present 
time, anyway.


> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 3 Aug 2004 01:29:08 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: tmpfs round-robin NUMA allocation
Message-Id: <20040803012908.6211ace3.ak@suse.de>
In-Reply-To: <Pine.SGI.4.58.0408021656300.58514@kzerza.americas.sgi.com>
References: <Pine.SGI.4.58.0408021656300.58514@kzerza.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Mon, 2 Aug 2004 17:52:52 -0500
Brent Casavant <bcasavan@sgi.com> wrote:

> Hello,
> 
> OK, I swear that it's complete coincidence that something else I'm
> looking at happens to fall into tmpfs...
> 
> It would be helpful to be able to round-robin tmpfs allocations
> (except for /dev/null and shm) between nodes on NUMA systems.
> This avoids putting undue memory pressure on a single node, while
> leaving other nodes less used.

Hmm, maybe for tmpfs used as normal files. But when tmpfs is used as shmfs
local policy may be better (consider a database allocating its shared cache
- i suspect for those local policy is the better default). 

Perhaps it would make sense to only do interleaving by default when
tmpfs is used using read/write, but not using a mmap fault.

In general for all read/write page cache operations a default interleaving policy
looks like a good idea. Except for anonymous memory of course. 

The rationale is the same - these are mostly file caches
and a bit of additional latency for a file read is not an 
issue, but memory pressure on specific nodes is.

The VM/VFS keep these paths separated, so it would be possible to do.

So if you do it please do it for everybody. 

Longer term I would like to have arbitary policy for named
page cache objects (not only tmpfs/hugetlbfs), but that is a 
bit more work. Using interleaving for it would be a good start.

> 
> I looked at using the MPOL_INTERLEAVE policy to accomplish this,
> however I think there's a flaw with that approach.  Since that
> policy uses the vm_pgoff value (which for tmpfs is determined by
> the inode swap page index) to determine the node from which to
> allocate, it seems that we'll overload the first few available
> nodes for interleaving instead of evenly distributing pages.
> This will be particularly exacerbated if there are a large number
> of small files in the tmpfs filesystem.
> 
> I see two possible ways to address this, and hope you can give me
> some guidance as to which one you'd prefer to see implemented.
> 
> The first, and more hackerly, way of addressing the problem is to
> use MPOL_INTERLEAVE, but change the tmpfs shmem_alloc_page() code
> (for CONFIG_NUMA) to perform its own round-robinning of the vm_pgoff
> value instead of deriving it from the swap page index.  This should
> be straightforward to do, and will add very little additional code.
> 
> The second, and more elegant, way of addressing the problem is to
> create a new MPOL_ROUNDROBIN policy, which would be identical to
> MPOL_INTERLEAVE, except it would use either a counter or rotor to
> choose the node from which to allocate.  This would probably be
> just a bit more code than the previous idea, but would also provide
> a more general facility that could be useful elsewhere.
> 
> In either case, I would set each inode to use the corresponding policy
> by default for tmpfs files.  If an application "knows better" than
> to use round-robin allocation in some circumstance, it could use
> the mbind() call to change the placement for a particular mmap'd tmpfs
> file.
> 
> For the /dev/null and shm uses of tmpfs I would leave things as-is.
> The MPOL_DEFAULT policy will usually be appropriate in these cases,
> and mbind() can alter that situation on a case-by-case basis.

My thoughts exactly.

 
> So, the big decision is whether I should put the round-robining
> into tmpfs itself, or write the more general mechanism for the
> NUMA memory policy code.

I don't like the using a global variable for this. The problem
is that it is quite evenly distributed at the beginning, as soon
as pages get dropped you can end up with worst case scenarios again.

I would prefer to use an "exact", but more global approach. How about 
something  like (inodenumber + pgoff) % numnodes ?
anonymous memory can use the process pid instead of inode number.

So basically I would suggest to split alloc_page_vma() into two 
new functions, one that is used for mmap faults, the other used 
for read/write. The only difference would be the default policy
when the vma policy and process policies are NULL. 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

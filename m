Date: Mon, 2 Aug 2004 17:52:52 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: tmpfs round-robin NUMA allocation
Message-ID: <Pine.SGI.4.58.0408021656300.58514@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: hugh@veritas.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Hello,

OK, I swear that it's complete coincidence that something else I'm
looking at happens to fall into tmpfs...

It would be helpful to be able to round-robin tmpfs allocations
(except for /dev/null and shm) between nodes on NUMA systems.
This avoids putting undue memory pressure on a single node, while
leaving other nodes less used.

I looked at using the MPOL_INTERLEAVE policy to accomplish this,
however I think there's a flaw with that approach.  Since that
policy uses the vm_pgoff value (which for tmpfs is determined by
the inode swap page index) to determine the node from which to
allocate, it seems that we'll overload the first few available
nodes for interleaving instead of evenly distributing pages.
This will be particularly exacerbated if there are a large number
of small files in the tmpfs filesystem.

I see two possible ways to address this, and hope you can give me
some guidance as to which one you'd prefer to see implemented.

The first, and more hackerly, way of addressing the problem is to
use MPOL_INTERLEAVE, but change the tmpfs shmem_alloc_page() code
(for CONFIG_NUMA) to perform its own round-robinning of the vm_pgoff
value instead of deriving it from the swap page index.  This should
be straightforward to do, and will add very little additional code.

The second, and more elegant, way of addressing the problem is to
create a new MPOL_ROUNDROBIN policy, which would be identical to
MPOL_INTERLEAVE, except it would use either a counter or rotor to
choose the node from which to allocate.  This would probably be
just a bit more code than the previous idea, but would also provide
a more general facility that could be useful elsewhere.

In either case, I would set each inode to use the corresponding policy
by default for tmpfs files.  If an application "knows better" than
to use round-robin allocation in some circumstance, it could use
the mbind() call to change the placement for a particular mmap'd tmpfs
file.

For the /dev/null and shm uses of tmpfs I would leave things as-is.
The MPOL_DEFAULT policy will usually be appropriate in these cases,
and mbind() can alter that situation on a case-by-case basis.

So, the big decision is whether I should put the round-robining
into tmpfs itself, or write the more general mechanism for the
NUMA memory policy code.

Thoughts/opinions valued,
Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

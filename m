Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705251444420.8208@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
	 <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com>
	 <1180114648.5730.64.camel@localhost>  <200705252301.00722.ak@suse.de>
	 <1180129271.21879.45.camel@localhost>
	 <Pine.LNX.4.64.0705251444420.8208@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 29 May 2007 09:57:47 -0400
Message-Id: <1180447067.5067.31.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-25 at 14:46 -0700, Christoph Lameter wrote:
> On Fri, 25 May 2007, Lee Schermerhorn wrote:
> 
> > As I've said, I view this series as addressing a number of problems,
> > including the numa_maps hang when displaying hugetlb shmem segments with
> > shared policy [that one by accident, I admit], the incorrect display of
> 
> That hang exists only if you first add a shared policy right?

hugetlbfs inodes already have shared policy struct in their private info
struct.  These get initialized when you create a SHM_HUGETLB segment,
but the .{get|set}_policy vm_ops are not "hooked up".  If I just hook
them up, then hugetlb segment DO obey the policy, as seen using
get_mempolicy() with the MPOL_F_NODE|MPOL_F_ADDR construct.  However, a
display of the numa_maps for the task hangs.  This is without any of my
shared policy patches.  With my patch series, everything works fine--for
my definition of fine.

> 
> > shmem segment policy from different tasks, and the disconnect between
> 
> Ahh.. Never checked that. What is happening with shmem policy display?

I've included a memtoy script below that illustrates what's happening.
You can grab the latest memtoy from:

http://free.linux.hp.com/~lts/Tools/memtoy-latest.tar.gz

To build you'll need the GNU readline and history packages and the
libnuma headers [numactl-devel package?].  These aren't loaded by
default on SLES10, and they're on the SDK iso, which I don't have, so I
haven't built there.  Did build on RHEL5, but I had to load the
numactl-devel package from the install image to get the libnuma headers.

Run script with "memtoy -v <path-to-script>".

Lee

# memtoy script to test shmem policy & numa maps
#
# 1) create a 64 page shmem segment -- shmget() internally
shmem s1 64p
#
# now memtoy has the shmem id in it's internal segment table.
show
#
# 2) now, before mapping [attaching to] the segment, fork a
#    child process.  The child will inherit the [unattached]
#    segment in it's segment table.
child c1
#
/c1 show
#
# 3) map/attach the segment in the parent and apply shared 
#    memory policy to different ranges of the segment, as
#    supported by existing shared policy infrastructure.
#    Using just 2 nodes [0 and 1] because I tested on a
#    2 socket AMD x86_64 blade.  It's also the minimum
#    "interesting" config.
map s1
mbind s1 0p 8p default
mbind s1 8p 16p interleave 0,1
mbind s1 16p 16p bind 0
mbind s1 32p 32p bind 1
#
# 4) now touch the segment to fault in pages.  With a shmem
#    segment, it shouldn't matter whether we touch with a read
#    or write, as it will fault in a page based on the shared
#    policy.  [It DOES matter for anon pages -- read faults
#    on previously unpopulated pages don't obey vma policy
#    installed by mbind()--unless we now have per node 
#    ZEROPAGE?]
touch s1 
#
# 5) Where did it land?  Does it obey the policies installed
#    above?
where s1
#
# 6) Tell the child to attach the segment and see where it
#    thinks it lives.  Child should see the same thing
/c1 map s1
/c1 where s1
#
# 7) pause memtoy.  In another window [or after pushing the
#    paused task to the background], examine the numa_maps
#    of the parent and child.   The pids were displayed when
#    memtoy started and when the child was created, but I'll
#    display them again here.
pid
/c1 pid
pause
#
# What did you see???
# 
# SIGINT [^C ?] to continue/exit





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

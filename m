Subject: Interesting Bug in page migration via mbind()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 16:45:06 -0400
Message-Id: <1193863506.5299.139.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

While exploring mempolicies installed by multiple tasks on different
ranges of shared memory segments, I came across this bug.  After some
investigation, I've determined that it isn't specifically associated
with shared policies.  I can make it happen with a single task with and
shared mmap()ed files, which more or less ignore the mempolicy, except
in mbind() when MPOL_MF_MOVE is specified.  The bug is hit when the
memory range to be migrated spans multiple vmas.  Also happens with
shared anon mappings; under the covers these are very similar to shm
segments.

I have tested and hit this bug as far back as a 2.6.18 kernel.  I didn't
look further back.

First the scenario [see attached memtoy script]:

1) mmap() a file or anonymous memory shared or a shared memory segment.
I think a file mapped private would do, as long as we don't write and
COW the pages.

2) Install a policy on a subset of the mapped range.  You can install a
different policy on other ranges, or leave them default.  Doesn't
matter.  Note that this will split the vma at the boundary/ies of the
policy range.  In my tests, I install policy on the first 8 pages.  

3) Now, apply a different policy that will result in page
migrations--i.e., specifying different nodes--to the entire range of the
original mapping via mbind() with MPOL_MF_MOVE [or MOVE_ALL].  Note that
this will apply the new policy to all vmas in the range, but will not
attempt to merge them, if possible.  That shouldn't be an issue, because
the vmas in the range might be unmergeable for different reasons from
mempolicy.

What happens:  

We hit the BUG_ON() in mm/rmap.c:vma_address() when we try to unmap a
page in the second vma in the region.

try_to_unmap_file() walks the rmap prio_tree to find vmas supposedly
mapping the page's pgoff, and passes the vmas so found along with the
page to try_to_unmap_one().  try_to_unmap_one() immediately calls
vma_address() to obtain the virtual address of the page in the vma.  

vma_address() computes the va from the page index and the vma's vm_start
and vm_pgoff.  It then makes sure that the address falls within the vma
range.  If not, it will bug out for !PageAnon() pages, and return
-EFAULT for anon pages.

With the scenario above, eventually we find a vma that claims to map the
pages pgoff, but the pgoff and resulting address is outside the range of
the vma.  In my tests, where I always change the policy at the front of
the mapped range in step 2, the bug always occurs at the first page in
the mbind(MOVE) range beyond the range where I installed a different
policy--i.e., at the point were the vmas were split.

Apparently, the rmap prio_tree "thinks" that the new vma at the front of
the original range still maps the pages beyond the split point. Why this
is so remains TBD.  Maybe I'm misinterpreting what I'm seeing.

At first I thought that I had to have 2 tasks with different vma
configurations, resulting from different vma splittings in the 2 tasks.
However, it will occur in one task that splits the vma via mbind() and
then attempts to migrate the entire original range via another mbind().


How to address?

I'd like to find out why the prio tree thinks that the vma before the
split point maps pages after the split point.  That will take some more
digging.  

Currently, altho' this is a very unlikely situation, if it does happen,
the bug can leave pages and prio tree locked, causing other tasks to
hang later.  [I have had to reset my test platform to recover in some
cases].  A quick work around would be to remove the bug check [I've
tested this] or make it a warning and return -EFAULT for all types of
pages when the computed address falls outside the vma.  In this case,
we'll just fail to migrate pages after the split point.  

This probably isn't so bad as this is a fairly contrived situation, but
could prevent cpuset page migration from doing its thing [via
migrate_to_node()] if any of the tasks it tries to migrate have any
file-backed mappings with vmas split via mbind().  

Thoughts?

Lee

----------

Here's an memtoy script that will demonstrate the problem with a single
task and a smallist shared anon region.  As always:

http://free.linux.hp.com/~lts/Tools/memtoy-latest.tar.gz

# memtoy script
# demonstrate spurious vma_address() bug check with page migration.
# requires 4 node numa system -- e.g., 4 socket AMD x86_64
#
# create a 16 page shared anon segment and attach it
# use shared anon so we get tmpfs [!anon] pages to trigger BUG_ON()
anon a1 16p shared
map a1 shared
#
# mbind 1st 8 pages interleaved across 3 of 4 nodes
# any policy will do, but this yields a recognizable pattern when
# it works.
mbind a1 0 8p interleave 0,1,2
#
# touch [write] the segment to fault in.
touch a1 w
#
# check location so far.  does it follow expected policy?
# the upper 8 pages should be placed according to default policy--i.e.,
# on the node where parent is executing.  Call this node N1
where a1
#
# should be OK to this point.
#
# Now, try to migrate all pages to some node N2 != N1 with
# MPOL_BIND + MPOL_MF_MOVE.  We want a different node
# so that we can see if the migration worked on the upper
# 8 pages.
# this is likely to hit bug check in rmap.c:vma_address()
mbind a1 0 16p bind+move 3
#
where a1








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

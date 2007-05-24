Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705241216560.30537@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
	 <Pine.LNX.4.64.0705241216560.30537@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 24 May 2007 16:46:20 -0400
Message-Id: <1180039580.5327.92.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-24 at 12:24 -0700, Christoph Lameter wrote:
> On Thu, 24 May 2007, Lee Schermerhorn wrote:
> 
> > Basic "problem":  currently [~2.6.21], files mmap()ed SHARED
> > do not follow mem policy applied to the mapped regions.  Instead, 
> > shared, file backed pages are allocated using the allocating
> > tasks' task policy.  This is inconsistent with the way that anon
> > and shmem pages are handled, violating, for me, the Principle
> > of Least Astonishment.
> 
> Yes sort of.  Anonymous pages are not shared and shmem pages are special 
> anyways. With file backed pages we are talking about the page cache right?

Aononymous pages are shared between tasks and their descendants until
one task breaks COW sharing.  Shmem pages are special in that they use
the inode/address_space mechanisms for fault handling, but are backed by
swap space.  But, yes, we're talking about page cache pages.  A regular
file mapped shared looks a lot like a shmem area to the mapping task,
except that it ignores any policy installed via mbind().

> 
> It would be great to have policies that can be set for the pagecache.
> Preferably per cpuset or so.

IMO, it would be useful to have those as well.  Ray Bryant posted
patches quite a while back, but that thread died off.  Could easily be
added.  Integration with this series would be quite easy:  instead of
get_file_policy() defaulting to the task and then system policies, it
could take another path:  per task page cache policy [perhaps from it's
cpuset?] and then system-wide page cache default policy.

> 
> > One reason for this is that down where pages are allocated for
> > file backed pages, the faulting (mm, vma, address) are not 
> > available to compute the policy.  However, we do have the
> > address_space [a.k.a. mapping] and file index/offset available.
> > If the applicable policy could be determined from just this info,
> > the vma and address would not be required.
> 
> Hmmm.. Hmmmm... yes logical.
> 
> > Note that hugepage shmem segments do not follow the vma policy even
> > tho' the hugetlbfs inode_info contains the shared policy struct.
> > This situation arises because the hugetlbfs vm_ops do not contain the
> > shmem_{get|set}_policy ops.  One can't just add these.  If you do,
> > a read/cat of /proc/<pid>/numa_maps will hang.  I haven't investigated
> > reason for the hang.  However, this series does not suffer that
> > problem.
> 
> Could you do a separate patch that fixes the hugetlbfs problem? There are 
> more exceptions in mempolicy.c that you may have to deal with.

I can take a look at the numa_maps hang.  I did try a patch that just
hooked up the hugetlbfs vm_ops, but testing showed the hang.  I'll try
to make time to investigate the hang.  If I can fix that, hooking up the
vm_ops is trivial.

> 
> > This series of patches implements NUMA memory policy for shared,
> > mmap()ed files.   Because files mmap()ed SHARED are shared between
> > tasks just like shared memory regions, I've used the shared_policy
> > infrastructure from shmem.  This infrastructure applies policies
> > directly to ranges of a file using an rb_tree.  The tree is indexed
> > by the page offset, which we have in page cache allocation contexts.
> > 
> > Note that the method used is similar to one proposed by Steve Longerbeam
> > quite a few years ago, except that I dynamically allocate the shared
> > policy struct when needed, rather than embedding it directly in the
> > inode/address_space.
> > 
> > This series result in the following internal and external semantics:
> > 
> > 1) The vma get|set_policy ops handle memory policies on sub-vma
> >    address ranges for shared, linear mappings [shmem, files]
> >    without splitting the vmas at the policy boundaries. Private
> >    and non-linear mappings still split the vma to apply policy.
> >    However, vma policy is still not visible to the nopage fault path.  
> 
> So the process may set a policy that is then ignored? Instead we 
> use the policy in the inode? Setting a policy sets the policy for the 
> complete inode? Can we set policies on segments of pages of an inode?

That happens now--vma policy, set by mbind(), is ignored--with shared
mapped files.  In fact, it happens today with private, read-only
mappings.   If you never write to a page to break COW sharing, you
always use the page cache page which follows task/system default policy.
This is one of those rough edges that surprises people [me, anyway].

> 
> > 2) As with shmem segments, the shared policies applied to shared
> >    file mappings persist as long as the inode remains--i.e., until
> >    the file is deleted or the inode recycled--whether or not any
> >    task has the file mapped or even open.  We could, I suppose,
> >    free the shared policy on last close.
> 
> What happens if something evicts the inode (reclaim) and then we need
> to reread it later? Isnt this a bit unpredictable?

One can't evict the inode while the file is open or mapped, right?  If
the question is about applying policy directly to the files [as Steve
Longerbeam wanted to do for executables], such a feature would require a
mechanism such as this series implements.  And, in my experience, the
policy applied to a mapped file has as much, if not more, to do with the
applications' useage of the file than with the particular file itself.
So, as long as one task of the application keeps the file mapped, or
open, the policy that it applies will persist.

With the current implementation, if you place a page cache page via task
policy, and then change the policy, the placement of the page will be
unpredictable if it ever gets paged out.  Yeah, I know.  You can lock
the page down.  Not everyone wants to do that; not everyone has the
privileges to do so.   All in all, I think this is an improvement over
the current state of affairs relative to persistence of policy.

The only surprise, I think, would be the policy persisting after all
tasks closed and unmapped the file.  As you say, the policy can then
persist for an unpredictable time in the inode cache.  The next mapper
of the file may be surprised to find that it already has a policy.  As I
mentioned above, I currently don't free the shared policy on last
close/unmap, but I could easily add that.

> 
> > 3) Vma policy of private mappings of files only apply when the 
> >    task gets a private copy of the page--i.e., when do_wp_page()
> >    breaks the COW sharing and allocates a private page.  Private,
> >    read-only mappings of a file use the shared policy which 
> >    defaults, as before, to process policy, which itself defaults
> >    to, well... default policy.  This is how mapped files have
> >    always behaved.
> 
> Let it be the way it is?

Exactly.  I haven't changed anything in this area.  Currently, you get
task policy for shared or private mappings/read-only access and vma
policy when you write to the page, creating a private anon page.  With
my changes, you get the same thing, unless some task has explicitly
installed a shared policy on the file.

I don't how much effort one should expend on handling concurrent shared
and private mappings to a file.  Certainly, tasks can do this, but I
haven't thought of any compelling use cases.  Haven't thought about it
much at all.  If it were important, one could break COW if the private
mapping's vma policy differed from the shared policy for the file at
that offset.  But, this would add additional checks in the fault path
for what would have been a minor fault.  So far, I can't justify that.

>  
> > 4) mbind(... 'MOVE*, ...) will not migrate page cache pages in
> >    a private mapping if the file has a shared policy.  Rather,
> >    only anon pages that the mapping task has "COWed" will be
> >    migrated.  If the mapped file does NOT have a shared policy
> >    or the file is mapped shared, then the pages will be migrated,
> >    subject to mapcount, preserving the existing semantics.
> 
> Hmmm... That could get a bit confusing.

Uh, yeah.  Again, this is the case of both shared and private mappings
of a single file.  It didn't seem fair to let a task with a private
mapping migrate page cache pages that some other tasks [maybe including
itself?] have placed with a shared policy.  Of course, with the current
migration implementation, we don't migrate pages referenced by multiple
ptes.  I'd like to "fix" that, someday ;-).

> 
>  
> > Impact On Kernel Build times
> 
> I think what you would like to show is that there is no negative impact on 
> concurrent reads and write on the page cache. The additional checking
> may impact scalability.

Hmmm.  Shouldn't be additional checks in performance paths.  I think the
only additions are in *page_cache_alloc*() where we're already in a
major fault and will ultimately have to wait for IO.  However, I'd love
for someone to give it a spin on a really large configuration [hint,
hint ;-)].  Seriously, as posted, the applies and builds cleanly for
2.6.22-rc2-mm1 on ia64 and x86_64.  As long as it doesn't conflict with
one's private patches, it should be relatively painless.

Thanks for the feedback,
Lee

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

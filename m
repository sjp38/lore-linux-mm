Date: Thu, 24 May 2007 12:24:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
In-Reply-To: <20070524172821.13933.80093.sendpatchset@localhost>
Message-ID: <Pine.LNX.4.64.0705241216560.30537@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Lee Schermerhorn wrote:

> Basic "problem":  currently [~2.6.21], files mmap()ed SHARED
> do not follow mem policy applied to the mapped regions.  Instead, 
> shared, file backed pages are allocated using the allocating
> tasks' task policy.  This is inconsistent with the way that anon
> and shmem pages are handled, violating, for me, the Principle
> of Least Astonishment.

Yes sort of.  Anonymous pages are not shared and shmem pages are special 
anyways. With file backed pages we are talking about the page cache right?

It would be great to have policies that can be set for the pagecache.
Preferably per cpuset or so.

> One reason for this is that down where pages are allocated for
> file backed pages, the faulting (mm, vma, address) are not 
> available to compute the policy.  However, we do have the
> address_space [a.k.a. mapping] and file index/offset available.
> If the applicable policy could be determined from just this info,
> the vma and address would not be required.

Hmmm.. Hmmmm... yes logical.

> Note that hugepage shmem segments do not follow the vma policy even
> tho' the hugetlbfs inode_info contains the shared policy struct.
> This situation arises because the hugetlbfs vm_ops do not contain the
> shmem_{get|set}_policy ops.  One can't just add these.  If you do,
> a read/cat of /proc/<pid>/numa_maps will hang.  I haven't investigated
> reason for the hang.  However, this series does not suffer that
> problem.

Could you do a separate patch that fixes the hugetlbfs problem? There are 
more exceptions in mempolicy.c that you may have to deal with.

> This series of patches implements NUMA memory policy for shared,
> mmap()ed files.   Because files mmap()ed SHARED are shared between
> tasks just like shared memory regions, I've used the shared_policy
> infrastructure from shmem.  This infrastructure applies policies
> directly to ranges of a file using an rb_tree.  The tree is indexed
> by the page offset, which we have in page cache allocation contexts.
> 
> Note that the method used is similar to one proposed by Steve Longerbeam
> quite a few years ago, except that I dynamically allocate the shared
> policy struct when needed, rather than embedding it directly in the
> inode/address_space.
> 
> This series result in the following internal and external semantics:
> 
> 1) The vma get|set_policy ops handle memory policies on sub-vma
>    address ranges for shared, linear mappings [shmem, files]
>    without splitting the vmas at the policy boundaries. Private
>    and non-linear mappings still split the vma to apply policy.
>    However, vma policy is still not visible to the nopage fault path.  

So the process may set a policy that is then ignored? Instead we 
use the policy in the inode? Setting a policy sets the policy for the 
complete inode? Can we set policies on segments of pages of an inode?

> 2) As with shmem segments, the shared policies applied to shared
>    file mappings persist as long as the inode remains--i.e., until
>    the file is deleted or the inode recycled--whether or not any
>    task has the file mapped or even open.  We could, I suppose,
>    free the shared policy on last close.

What happens if something evicts the inode (reclaim) and then we need
to reread it later? Isnt this a bit unpredictable?

> 3) Vma policy of private mappings of files only apply when the 
>    task gets a private copy of the page--i.e., when do_wp_page()
>    breaks the COW sharing and allocates a private page.  Private,
>    read-only mappings of a file use the shared policy which 
>    defaults, as before, to process policy, which itself defaults
>    to, well... default policy.  This is how mapped files have
>    always behaved.

Let it be the way it is?
 
> 4) mbind(... 'MOVE*, ...) will not migrate page cache pages in
>    a private mapping if the file has a shared policy.  Rather,
>    only anon pages that the mapping task has "COWed" will be
>    migrated.  If the mapped file does NOT have a shared policy
>    or the file is mapped shared, then the pages will be migrated,
>    subject to mapcount, preserving the existing semantics.

Hmmm... That could get a bit confusing.

 
> Impact On Kernel Build times

I think what you would like to show is that there is no negative impact on 
concurrent reads and write on the page cache. The additional checking
may impact scalability.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

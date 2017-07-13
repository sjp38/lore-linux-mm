Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C121440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:33:32 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id s20so31545034qki.12
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:33:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a11si5724719qtd.334.2017.07.13.13.33.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 13:33:30 -0700 (PDT)
Date: Thu, 13 Jul 2017 22:33:27 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
Message-ID: <20170713203327.GL22628@redhat.com>
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170711123642.GC11936@dhcp22.suse.cz>
 <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
 <20170712114655.GG28912@dhcp22.suse.cz>
 <3a2cfeae-520c-b6e5-2808-cf1bcf62b067@oracle.com>
 <20170713061651.GA14492@dhcp22.suse.cz>
 <21b264e7-b879-f072-03d2-f6f4aec5c957@oracle.com>
 <20170713163054.GK22628@redhat.com>
 <28a8da13-bdc2-3f23-dee9-607377ac1cc3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28a8da13-bdc2-3f23-dee9-607377ac1cc3@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Jul 13, 2017 at 11:11:37AM -0700, Mike Kravetz wrote:
> Here is my understanding of how things work for old_len == 0 of anon
> mappings:
> - shared mappings
> 	- New vma is created at new virtual address
> 	- vma refers to the same underlying object/pages as old vma
> 	- after mremap, no page tables exist for new vma, they are
> 	  created as pages are accessed/faulted
> 	- page at new_address is same as page at old_address

Yes, and this isn't backed by anon memory, it's backed by
shmem. "Shared anon mapping" is really synonymous of shmem, the fact
it's not a mmap of a tmpfs file is purely an API detail.

> - private mappings
> 	- New vma is created at new virtual address
> 	- vma does not refer to same pages as old vma.  It is a 'new'
> 	  private anon mapping.
> 	- after mremap, no page tables exist for new vma.  access to
> 	  the range of the new vma will result in faults that allocate
> 	  a new page.
> 	- page at new_address is different than  page at old_address
> 	  the new vma will result in new 

Yes, for a anon private mapping (so backed by real anonymous memory)
no payload in the old vma could possibly go in the new vma.

> So, the result of mremap(old_len == 0) on a private mapping is that it
> simply creates a new private mapping.  IMO, this is contrary to the purpose
> of mremap.  mremap should return a mapping that is somehow related to
> the original mapping.

I agree there's no point to ever use the mremap(old_len == 0)
undocumented trick, to create a new anon private mmap, when you could
use mmap instead and the result would be the same.

So it's plausible nobody could use it for it.

> Perhaps you are thinking about mremap of a private file mapping?  I was
> not considering that case.  I believe you are right.  In this case a
> private COW mapping based on the original mapping would be created.  So,
> this seems more in line with the intent of mremap.  The new mapping is
> still related to the old mapping.

Yes my earlier example was all about filebacked private mappings, to
point out those also have a deterministic behavior with the old_len ==
0 trick and it could be still used because the IPC_RMID was executed
early on.

The point is that you could always use a plain new mmap instead of the
old_len == 0 trick, but that applies to shared mappings as well.

My argument is that if you keep it and document it for shared anon
mappings, I don't see something fundamentally wrong as keeping it for
private filebacked mappings too as the shmat ID may have been deleted
for those too.

> With this in mind, what about returning EINVAL only for the anon private
> mapping case?

The only case where there's no excuse to use mremap(old_len == 0) as
replacement for a new mmap is the private anon mappings case, so while
it may still break something (as opposed to a deprecation warning), I
guess the likely hood somebody is using it, is very low.

> However, if you have a fd (for a file mapping) then I can not see why
> someone would be using the old_len == 0 trick.  It would be more straight
> forward to simply use mmap to create the additional mapping.

That applies to MAP_SHARED too and that's why deprecating the whole
undocumented old_len ==0 sounded and still sound attractive to me, but
doing it right away without a deprecation warning cycle, sounds too
risky.

> > So an alternative would be to start by adding a WARN_ON_ONCE deprecation
> > warning instead of -EINVAL right away.
> > 
> > The vma->vm_flags VM_ACCOUNT being wiped on the original vma as side
> > effect of using the old_len == 0 trick looks like a bug, I guess it
> > should get fixed if we intend to keep old_len and document it for the
> > long term.
> 
> Others seem to think we should keep old_len == 0 and document.

The only case where it makes sense is after IPC_RMID, but with
memfd_create there's no point anymore to use IPC_RMID.

tmpfs/hugetlbfs/realfs files can be unlinked while the fd is still
open so again no need of the mremap(old_len == 0) trick.

Which is why I'd find it attractive to deprecate it if we could, but I
assume we can't drop it even if undocumented, which is why I felt a
deprecation warning would be suitable in this case (similar to
deprecation warning of sysfs and then dropped via config option). I am
assuming here that nobody is using it because it's undocumented and it
has a bug in the VM_ACCOUNT code too. Without a deprecation warning
it'd be hard to tell if the assumption is correct.

> I assume you are concerned about the do_munmap call in move_vma?  That

Yes exactly.

> does indeed look to be of concern.  This happens AFTER setting up the
> new mapping.  So, I'm thinking we should tear down the new mapping in
> the case do_munmap of the old mapping fails?  That 'should' simply
> be a matter of:
> - moving page tables back to original mapping
> - remove/delete new vma

Yes.

> - I don't think we need to 'unmap' the new vma as there should be no
>   associated pages.

The new vma doesn't require memory allocations to drop as it was just
created by copy_vma so there's no risk of further failures in the
unwind.

After the unwind it'll return -ENOMEM to userland (which we don't
right now).

> I'll look into doing this as well.

It's mostly theoretical, the chances of an allocation failure
triggering exactly in that split_vma are basically zero, but I think
it'd be more correct and safer.

> Just curious, do those userfaultfd callouts still work as desired in the
> case of map duplication (old_len == 0)?

old_len == 0 is fine with userfaultfd because, len == 0 returns
-EINVAL in do_munmap before userfaultfd_unmap_prep is called.

Still looking at the VM_ACCOUNT adjustments around do_munmap:

mremap:

	/* Conceal VM_ACCOUNT so old reservation is not undone */
	if (vm_flags & VM_ACCOUNT) {

do_munmap:

	if (uf) {
		int error = userfaultfd_unmap_prep(vma, start, end, uf);

		if (error)
			return error;
	}

	/*
	 * If we need to split any vma, do it now to save pain later.
	 *
	 * Note: mremap's move_vma VM_ACCOUNT handling assumes a partially
	 * unmapped vm_area_struct will remain in use: so lower split_vma
	 * places tmp vma above, and higher split_vma places tmp vma below.
	 */

I don't see this assumption where it matters that on do_munmap
failure, mremap assumes the partially unmapped vma remains in use. In
fact it's not partially unmapped at all, it's only split at the
"start" address of the do_munmap but not unmapped.

mremap caller simply sets excess = 0 and assumes it's all still mapped
at the original vma as expected regardless of the order of the
__split_vma executed in do_munmap.

The whole VM_ACCOUNT logic in this place exists since the start of the
git history so I can't see the change originating the above comment,
but I assume the comment is wrong or simply confusing.

I don't see a problem in userfaultfd_unmap_prep failing with -ENOMEM
in relation to the VM_ACCOUNT logic above, before split_vma is called
(callee doesn't seem to make assumption).

However unrelated to mremap old_len == 0, but purely internal to
do_munmap and theoretical, if either of the two __split_vma fails
there's no need to send an unmap event and in fact it'd be wrong to,
so userfaultfd_unmap_prep should be moved after both split_vma succeded.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

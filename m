Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41E246810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 19:31:19 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z22so3073552qka.4
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 16:31:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b185si676996qkf.160.2017.07.11.16.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 16:31:18 -0700 (PDT)
Date: Wed, 12 Jul 2017 01:31:14 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
Message-ID: <20170711233114.GH22628@redhat.com>
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170711123642.GC11936@dhcp22.suse.cz>
 <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
 <20170711210256.GF22628@redhat.com>
 <fcfa8403-3151-41eb-4ac4-bbac55705626@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fcfa8403-3151-41eb-4ac4-bbac55705626@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Jul 11, 2017 at 02:57:38PM -0700, Mike Kravetz wrote:
> Well, the JVM has had a config option for the use of hugetlbfs for quite
> some time.  I assume they have already had to deal with these issues.

Yes, the config tweak exists well before THP existed but in production
I know nobody who used it because as you start more processes you risk
running out of hugetlbfs reservation and in addition the reservation
"wastes memory" at times.

> What prompted this discussion is that they want the mremap mirroring/
> duplication functionality extended to support hugetlbfs.  This is pretty
> straight forward.  But, I wanted to have a discussion about whether the
> mremap(old_size == 0) functionality should be formally documented first.

Agreed.

> Do note that if you actually create/mount a hugetlbfs filesystem and
> use a fd in that filesystem you can get the desired functionality.  However,
> they want to avoid this extra step if possible and use mmap(anon, hugetlb).

I see, I thought they needed to use the mremap on pure SHM because of
the there was no MAP_HUGETLB in the mmap flags of the use case.

> I'm guessing that if memfd_create supported hugetlbfs, that would also
> meet their needs.  Any thoughts about extending memfd_create support to
> hugetlbfs?  I can't think of any big issues.  In fact, 'under the covers'
> there actually is a hugetlbfs file created for anon mappings.  However,
> that is not exposed to the user.

Yes, that should fit fine as MFD_HUGETLB or similar.

> Yes, that is why I think it is a bug.  Not that kernel is unstable, but
> rather the unintentional/unexpected result.

The most unexpected is the old mapping isn't wiped, at least it
doesn't seem to cause trouble to anon as move_page_tables is
nullified (old_end == old_addr so the loop never runs).

> > memfd_create doesn't have such issue, the new mmap MAP_PRIVATE will
> > get the file pages correctly after a new mmap (even if there were cows
> > in the old MAP_PRIVATE mmap).
> > 
> >> One reason for the RFC was to determine if people thought we should:
> >> 1) Just document the existing old_size == 0 functionality
> >> 2) Create a more explicit interface such as a new mremap flag for this
> >>    functionality
> >>
> >> I am waiting to see what direction people prefer before making any
> >> man page updates.
> > 
> > I guess old_size == 0 would better be dropped if possible, if
> > memfd_create fits perfectly your needs as I supposed above. If it's
> > not dropped then it's not very far from allowing mmap of /proc/self/mm
> > again (removed around so far as 2.3.x?).
> 
> Yes, in my google'ing it appears the first users of mremap(old_size == 0)
> previously used mmap of /proc/self/mm.
> 
> If memfd_create can be extended to support hugetlbfs, then I might suggest
> dropping the memfd_create(old_size == 0) support.  Just a thought.

memfd_create interface sounds more robust than this mremap trick,
they would have to deal with one more fd that's all.

old_len == 0 by nullifying move_page_tables will cause not harm to
anon pages however the place where we would drop the vma is do_munmap
here:

	if (vm_flags & VM_ACCOUNT) {
		vma->vm_flags &= ~VM_ACCOUNT;
		excess = vma->vm_end - vma->vm_start - old_len;
[..]
	if (do_munmap(mm, old_addr, old_len, uf_unmap) < 0) {
		/* OOM: unable to split vma, just get accounts right */
		vm_unacct_memory(excess >> PAGE_SHIFT);
		excess = 0;
	}

It looks like a split_vma allocation failure can leave the old vma
around in a equal way to old_len == 0 (but in such case all anon
payload will have been moved to the new vma). That also seems safe as
far as the kernel is concerned but it could cause userland failure if
you depend on SIGSEGV to trigger later on the original vma you thought
was implicitly munmapped (and in MAP_SHARED case it could even lead to
unexpected file corruption instead of an expected SIGSEGV). If nobody
ever depends on whatever is left on the old vma it's ok, but it could
still leave file handle pinned unexpectedly if it's not anon.

The other issue of the old_len = 0 trick is that will unexpectedly
wipe the VM_ACCOUNT from the original vma as side effect of the above,
but it'd only be noticeable if you care about strict accounting. So
there is at least such one glitch in it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

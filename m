Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 38EEA6B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 21:12:22 -0400 (EDT)
Date: Wed, 22 Aug 2012 03:12:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: kernel BUG at mm/memory.c:1230
Message-ID: <20120822011213.GM29978@redhat.com>
References: <1337884054.3292.22.camel@lappy>
 <20120524120727.6eab2f97.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120524120727.6eab2f97.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, viro <viro@zeniv.linux.org.uk>, oleg@redhat.com, "a.p.zijlstra" <a.p.zijlstra@chello.nl>, mingo <mingo@kernel.org>, Dave Jones <davej@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hi everyone,

On Thu, May 24, 2012 at 12:07:27PM -0700, Andrew Morton wrote:
> On Thu, 24 May 2012 20:27:34 +0200
> Sasha Levin <levinsasha928@gmail.com> wrote:
> 
> > Hi all,
> > 
> > During fuzzing with trinity inside a KVM tools guest, using latest linux-next, I've stumbled on the following:
> > 
> > [ 2043.098949] ------------[ cut here ]------------
> > [ 2043.099014] kernel BUG at mm/memory.c:1230!
> 
> That's
> 
> 	VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
> 
> in zap_pmd_range()?

Originally split_huge_page_address didn't exist. If the vma was
splitted at a not 2m aligned address by a syscall like madvise that
would only mangle the vma and not touch the pagetables (munmap for
example was safe), the THP would remain in place and it would lead to
a BUG_ON in split_huge_page where the number of rmaps was different
than the page_mapcount for a cascade of side effects of the above bug
triggering. It was a the most more obscure BUG_ON I got in the whole
THP development and the hardest bug to fix (it was not easily
reproducible either, madvise not so common).

After I fixed it adding split_huge_page_address, I also added this
VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem)). So if I missed any
split_huge_page_address invocation I would get a more meaningful
VM_BUG_ON, closer to the actual bug, signaling problems in the vma
layout and not anymore a misleading BUG_ON in the split_huge_page
internals when in fact split_huge_page was perfectly fine.

My previous theory was a bug in the vma mangling of mbind, it could
still be it, I didn't review it closely yet. But mbind is one syscall
that like madvise depends on split_huge_page_address when it does
split_vma!

So now I think I found the cause of the above
VM_BUG_ON. split_huge_page_address uses pmd_present so it won't run if
the hugepage is under splitting. So it's likely the below will fix the
above VM_BUG_ON. The race condition is tiny, it's not a critical bug
and it makes sense that only a syscall stresser like trinity can
exercise it and not any real app.

static void split_huge_page_address(struct mm_struct *mm,
				    unsigned long address)
{
[..]
	if (!pmd_present(*pmd))
		return;
	/*
	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
	 * materialize from under us.
	 */
	split_huge_page_pmd(mm, pmd);
}

This time I think it is worth to fix pmd_present for good instead of
converting it to !pmd_none like I did with most others.

I'm well aware pmd_present wasn't ok during split_huge_page but most
have been converted and I didn't change what wasn't absolutely
necessary in case some lowlevel code depended on the lowlevel
semantics of pmd_present (strict _PRESENT check) but now it looks to
risky not to fix it.

The below patch isn't well tested yet. Reviews welcome. Especially if
you could test it again with trinity over the mbind syscall it'd be
wonderful.

Thanks,
Andrea

===

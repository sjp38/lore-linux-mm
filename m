Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id CC94D6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:32:12 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id i8so4668594qcq.3
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 09:32:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x8si923073qar.226.2014.04.10.09.32.10
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 09:32:11 -0700 (PDT)
Date: Thu, 10 Apr 2014 18:27:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1829!
Message-ID: <20140410162750.GD2749@redhat.com>
References: <53440991.9090001@oracle.com>
 <20140410102527.GA24111@node.dhcp.inet.fi>
 <20140410134436.GA25933@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140410134436.GA25933@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Bob Liu <lliubbo@gmail.com>

Hi,

On Thu, Apr 10, 2014 at 04:44:36PM +0300, Kirill A. Shutemov wrote:
> Okay, below is my attempt to fix the bug. I'm not entirely sure it's
> correct. Andrea, could you take a look?

The possibility the interval tree implicitly broke the walk order of
the anon_vma list didn't cross my mind, that's very good catch!
Breakage of the rmap walk order definitely can explain that BUG_ON in
split_huge_page that signals a pte was missed by the rmap walk.

Because this bug only fired on split_huge_page I guess you assumed I
introduced this dependency on order with THP. But it's not actually
the case, there was a place in the VM that already depended on perfect
rmap walk. This is all about providing a perfect rmap walk. A perfect
rmap walk is one where missing a pte is fatal. That other place that
already existed before THP is migrate.c.

The other thing that could break the perfect rmap_walk in additon to a
wrong rmap_walk order, is the exec path where we do an mremap without
a vma covering the destination range (no vma means, no possible
perfect rmap_walk as we need the vma to reach the pte) but that was
handled by other means (see the invalid_migration_vma in migrate.c and
the other checks for is_vma_temporary_stack in huge_memory.c, THP
didn't need to handle it but migrate.c had to). Places using
is_vma_temporary_stack can tell you the cases where a perfect rmap
walk is required and I'm not aware of other locations other than these
two.

split_huge_page might be more pedantic in making sure a pte wasn't
missed (I haven't checked in detail to tell how migrate.c would behave
in such case, split_huge_page just BUG_ON).

So I doubt making a local fix to huge_memory.c is enough, at least
migrate.c (i.e. rmap_walk_anon) should be handled too somehow.

While I'm positive the breakge of rmap_walk order explains the BUG_ON
with trinity (as your forking testcase also shows), I'm quite
uncomfortable to depend on comparison on atomic mapcount that is an
atomic for a reason, to know if the order went wrong and we shall
repeat the loop because fork created a pte we missed.

The commit message doesn't explain how do you guarantee mapcount
cannot change from under us in a racey way. If we go with this fix,
I'd suggest to explain that crucial point about the safety of the
page->mapcount comparison in that code path, in the commit message. It
may be safe by other means! I'm not saying it's definitely not safe,
but it's at least not obviously safe as it looks like the atomic
mapcount could change while it is being read, and there was no obvious
explaination of how it is safe despite it is not stable.

The other downside is that an infinite loop in kernel mode with no
debug message printed, would make this less debuggable too if a real
functional bug hits (not as result of race because of rmap walk
ordering breakage).

I assume the interval tree ordering cannot be fixed, but I'd recommend
to look closer into that possibility too before ruling it out.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

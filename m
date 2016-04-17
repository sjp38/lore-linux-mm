Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB2F6B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 21:49:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so260944513pfe.3
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 18:49:38 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id s202si12171120pfs.76.2016.04.16.18.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 18:49:37 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id r5so12307390pag.1
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 18:49:37 -0700 (PDT)
Date: Sat, 16 Apr 2016 18:49:28 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 09/31] huge tmpfs: avoid premature exposure of new
 pagetable
In-Reply-To: <20160411115422.GF22996@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1604161830510.1896@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils> <alpine.LSU.2.11.1604051423160.5965@eggly.anvils> <20160411115422.GF22996@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 11 Apr 2016, Kirill A. Shutemov wrote:
> On Tue, Apr 05, 2016 at 02:24:23PM -0700, Hugh Dickins wrote:
> > 
> > That itself is not a problem on x86_64, but there's plenty more:
> > how about those places which use pte_offset_map_lock() - if that
> > spinlock is in the struct page of a pagetable, which has been
> > deposited and might be withdrawn and freed at any moment (being
> > on a list unattached to the allocating pmd in the case of x86),
> > taking the spinlock might corrupt someone else's struct page.
> > 
> > Because THP has departed from the earlier rules (when pagetable
> > was only freed under exclusive mmap_sem, or at exit_mmap, after
> > removing all affected vmas from the rmap list): zap_huge_pmd()
> > does pte_free() even when serving MADV_DONTNEED under down_read
> > of mmap_sem.
> 
> Emm.. The pte table freed from zap_huge_pmd() is from deposit. It wasn't
> linked into process' page table tree. So I don't see how THP has departed
> from the rules.

That's true at the time that it is freed: but my point was, that we
don't know the past history of that pagetable, which might have been
linked in and contained visible ptes very recently, without sufficient
barriers in between.  And in the x86 case (perhaps any non-powerpc
case), there's no logical association between the pagetable freed
and the place that it's freed from.

Now, I've certainly not paged back in all the anxieties I had, and
avenues I'd gone down, at the time that I first wrote that comment:
it's quite possible that they were self-inflicted issues, and
perhaps remnants of earlier ways in which I'd tried ordering it.
I'm sure that I never reached any "hey, anon THP has got this wrong"
conclusion, merely doubts, and surprise that it could free a
pagetable there.

But it looks as if all these ruminations here will vanish with the
revert of the patch.  Though one day I'll probably be worrying
about it again, when I try to remove the need for mmap_sem
protection around recovery's remap_team_by_pmd().

> > do_fault_around() presents one last problem: it wants pagetable to
> > have been allocated, but was being called by do_read_fault() before
> > __do_fault().  I see no disadvantage to moving it after, allowing huge
> > pmd to be chosen first; but Kirill reports additional radix-tree lookup
> > in hot pagecache case when he implemented faultaround: needs further
> > investigation.
> 
> In my implementation faultaround can establish PMD mappings. So there's no
> disadvantage to call faultaround first.
> 
> And if faultaround happened to solve the page fault we don't need to do
> usual ->fault lookup.

Sounds good, though not something I'll be looking to add in myself:
feel free to add it, but maybe it fits easier with compound pages.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

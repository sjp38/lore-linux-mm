Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7435183292
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:53:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h21so39074768pfk.13
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:53:41 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 1si2204411plj.69.2017.06.16.07.53.39
        for <linux-mm@kvack.org>;
        Fri, 16 Jun 2017 07:53:40 -0700 (PDT)
Date: Fri, 16 Jun 2017 23:53:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv2 3/3] mm: Use updated pmdp_invalidate() inteface to
 track dirty/accessed bits
Message-ID: <20170616145333.GA29802@bbox>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-4-kirill.shutemov@linux.intel.com>
 <20170616030250.GA27637@bbox>
 <20170616131908.3rxtm2w73gdfex4a@node.shutemov.name>
 <20170616135209.GA29542@bbox>
 <20170616142720.GH11676@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616142720.GH11676@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrea,

On Fri, Jun 16, 2017 at 04:27:20PM +0200, Andrea Arcangeli wrote:
> Hello Minchan,
> 
> On Fri, Jun 16, 2017 at 10:52:09PM +0900, Minchan Kim wrote:
> > > > > @@ -1995,8 +1984,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> > > > >  			if (soft_dirty)
> > > > >  				entry = pte_mksoft_dirty(entry);
> > > > >  		}
> > > > > -		if (dirty)
> > > > > -			SetPageDirty(page + i);
> > > > >  		pte = pte_offset_map(&_pmd, addr);
> [..]
> > 
> > split_huge_page set PG_dirty to all subpages unconditionally?
> > If it's true, yes, it doesn't break MADV_FREE. However, I didn't spot
> > that piece of code. What I found one is just __split_huge_page_tail
> > which set PG_dirty to subpage if head page is dirty. IOW, if the head
> > page is not dirty, tail page will be clean, too.
> > Could you point out what routine set PG_dirty to all subpages unconditionally?
> 
> On a side note the snippet deleted above was useless, as long as
> there's one left hugepmd to split, the physical page has to be still
> compound and huge and as long as that's the case the tail pages
> PG_dirty bit is meaningless (even if set, it's going to be clobbered
> during the physical split).

I got it during reviewing this patch. That's why I didn't argue
this patch would break MADV_FREE by deleting routine which propagate
dirty to pte of subpages. However, although it's useless, I prefer
not removing the transfer of dirty bit. Because it would help MADV_FREE
users who want to use smaps to know how many of pages are not freeable
(i.e, dirtied) since MADV_FREE although it is not 100% correct.

> 
> In short PG_dirty is only meaningful in the head as long as it's
> compound. The physical split in __split_huge_page_tail transfer the
> head value to the tails like you mentioned, that's all as far as I can
> tell.

Thanks for the comment. Then, this patch is to fix MADV_FREE's bug
which has lost dirty bit by transferring dirty bit too early.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

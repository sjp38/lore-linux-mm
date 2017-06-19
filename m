Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8FC6B03C6
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 10:03:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b19so11755953wmb.8
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 07:03:28 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id l14si11132548wrc.369.2017.06.19.07.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 07:03:26 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id d17so16585684wme.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 07:03:26 -0700 (PDT)
Date: Mon, 19 Jun 2017 17:03:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 3/3] mm: Use updated pmdp_invalidate() inteface to
 track dirty/accessed bits
Message-ID: <20170619140322.iszk7sbhxblusygo@node.shutemov.name>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-4-kirill.shutemov@linux.intel.com>
 <20170616030250.GA27637@bbox>
 <20170616131908.3rxtm2w73gdfex4a@node.shutemov.name>
 <20170616135209.GA29542@bbox>
 <20170616142720.GH11676@redhat.com>
 <20170616145333.GA29802@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616145333.GA29802@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 16, 2017 at 11:53:33PM +0900, Minchan Kim wrote:
> Hi Andrea,
> 
> On Fri, Jun 16, 2017 at 04:27:20PM +0200, Andrea Arcangeli wrote:
> > Hello Minchan,
> > 
> > On Fri, Jun 16, 2017 at 10:52:09PM +0900, Minchan Kim wrote:
> > > > > > @@ -1995,8 +1984,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> > > > > >  			if (soft_dirty)
> > > > > >  				entry = pte_mksoft_dirty(entry);
> > > > > >  		}
> > > > > > -		if (dirty)
> > > > > > -			SetPageDirty(page + i);
> > > > > >  		pte = pte_offset_map(&_pmd, addr);
> > [..]
> > > 
> > > split_huge_page set PG_dirty to all subpages unconditionally?
> > > If it's true, yes, it doesn't break MADV_FREE. However, I didn't spot
> > > that piece of code. What I found one is just __split_huge_page_tail
> > > which set PG_dirty to subpage if head page is dirty. IOW, if the head
> > > page is not dirty, tail page will be clean, too.
> > > Could you point out what routine set PG_dirty to all subpages unconditionally?

When I wrote this code, I considered that we may want to track dirty
status on per-4k basis for file-backed THPs.

> > On a side note the snippet deleted above was useless, as long as
> > there's one left hugepmd to split, the physical page has to be still
> > compound and huge and as long as that's the case the tail pages
> > PG_dirty bit is meaningless (even if set, it's going to be clobbered
> > during the physical split).
> 
> I got it during reviewing this patch. That's why I didn't argue
> this patch would break MADV_FREE by deleting routine which propagate
> dirty to pte of subpages. However, although it's useless, I prefer
> not removing the transfer of dirty bit. Because it would help MADV_FREE
> users who want to use smaps to know how many of pages are not freeable
> (i.e, dirtied) since MADV_FREE although it is not 100% correct.
> 
> > 
> > In short PG_dirty is only meaningful in the head as long as it's
> > compound. The physical split in __split_huge_page_tail transfer the
> > head value to the tails like you mentioned, that's all as far as I can
> > tell.
> 
> Thanks for the comment. Then, this patch is to fix MADV_FREE's bug
> which has lost dirty bit by transferring dirty bit too early.

Erghh. I've misread splitting code. Yes, it's not unconditional. So we fix
actual bug.

But I'm not sure it's subject for -stable. I haven't seen any bug reports
that can be attributed to the bug.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

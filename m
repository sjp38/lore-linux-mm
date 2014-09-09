Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 288F26B009F
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 15:05:03 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so9506962pde.5
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 12:05:02 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id ag3si16930240pbc.61.2014.09.09.12.05.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 12:05:02 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so6637657pdj.2
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 12:05:01 -0700 (PDT)
Date: Tue, 9 Sep 2014 12:03:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 2/6] mm/hugetlb: take page table lock in
 follow_huge_(addr|pmd|pud)()
In-Reply-To: <20140908213741.GA6866@nhori.bos.redhat.com>
Message-ID: <alpine.LSU.2.11.1409091142330.8184@eggly.anvils>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1409276340-7054-3-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.LSU.2.11.1409031243420.9023@eggly.anvils> <20140905052751.GA6883@nhori.redhat.com> <alpine.LSU.2.11.1409072307430.1298@eggly.anvils>
 <20140908213741.GA6866@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, 8 Sep 2014, Naoya Horiguchi wrote:
> On Mon, Sep 08, 2014 at 12:13:16AM -0700, Hugh Dickins wrote:
> > On Fri, 5 Sep 2014, Naoya Horiguchi wrote:
> > > On Wed, Sep 03, 2014 at 02:17:41PM -0700, Hugh Dickins wrote:
> > > 
> > > > One subtlety to take care over: it's a long time since I've had to
> > > > worry about pmd folding and pud folding (what happens when you only
> > > > have 2 or 3 levels of page table instead of the full 4): macros get
> > > > defined to each other, and levels get optimized out (perhaps
> > > > differently on different architectures).
> > > > 
> > > > So although at first sight the lock to take in follow_huge_pud()
> > > > would seem to be mm->page_table_lock, I am not at this point certain
> > > > that that's necessarily so - sometimes pud_huge might be pmd_huge,
> > > > and the size PMD_SIZE, and pmd_lockptr appropriate at what appears
> > > > to be the pud level.  Maybe: needs checking through the architectures
> > > > and their configs, not obvious to me.
> > > 
> > > I think that every architecture uses mm->page_table_lock for pud-level
> > > locking at least for now, but that could be changed in the future,
> > > for example when 1GB hugepages or pud-based hugepages become common and
> > > someone are interested in splitting lock for pud level.
> > 
> > I'm not convinced by your answer, that you understand the (perhaps
> > imaginary!) issue I'm referring to.  Try grep for __PAGETABLE_P.D_FOLDED.
> > 
> > Our infrastructure allows for 4 levels of pagetable, pgd pud pmd pte,
> > but many architectures/configurations support only 2 or 3 levels.
> > What pud functions and pmd functions work out to be in those
> > configs is confusing, and varies from architecture to architecture.
> > 
> > In particular, pud and pmd may be different expressions of the same
> > thing (with 1 pmd per pud, instead of say 512).  In that case PUD_SIZE
> > will equal PMD_SIZE: and then at the pud level huge_pte_lockptr()
> > will be using split locking instead of mm->page_table_lock.
> 
> Is it a possible problem? It seems to me that in such system no one
> can create pud-based hugepages and care about pud level locking.

Maybe it is not a possible problem, I already said I'm not certain.
(Maybe I just need to try a couple of x86_32 builds with printks,
to find that it is a real problem; but I haven't tried, and x86_32
would not disprove it for the other architectures.)

But again, your answer does not convince me that you begin to understand
the issue: please read again what I wrote.  I am not talking about
pud-based hugepages, I'm talking about pmd-based hugepages when the
pud level is identical to the pmd level.

Hopefully, you're seeing the issue from a different viewpoint than I am,
and from your good viewpoint the answer is obvious, whereas from my
muddled viewpoint it is not; but you're not making that clear to me.

What is certain is that we do not need to worry about this in a
patch fixing follow_huge_pmd() alone: it only becomes an issue in a
patch extending properly locked FOLL_GET support to follow_huge_pud(),
which I think you've decided to set aside for now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

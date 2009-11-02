Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 344BA6B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 18:45:50 -0500 (EST)
Date: Mon, 2 Nov 2009 23:45:44 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Filtering bits in set_pte_at()
In-Reply-To: <1257200367.7907.50.camel@pasglop>
Message-ID: <Pine.LNX.4.64.0911022342070.30581@sister.anvils>
References: <1256957081.6372.344.camel@pasglop>  <Pine.LNX.4.64.0911021256330.32400@sister.anvils>
 <1257200367.7907.50.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009, Benjamin Herrenschmidt wrote:
> On Mon, 2009-11-02 at 13:27 +0000, Hugh Dickins wrote:
> 
> > You're being a very good citizen to want to bring this so forcefully
> > to the attention of any user of set_pte_at(); but given how few care,
> > and the other such functions you'd want to change too, am I being
> > disgracefully lazy to suggest that you simply change the occasional
> > 
> > 		update_mmu_cache(vma, address, pte);
> > to
> > 		/* powerpc's set_pte_at might have adjusted the pte */
> > 		update_mmu_cache(vma, address, *ptep);
> > 
> > ?  Which would make no difference to those architectures whose
> > update_mmu_cache() is an empty macro.  And fix the mm/hugetlb.c
> > instance in a similar way?
> 
> That would do fine. In fact, I've always been slightly annoyed by
> set_pte_at() not taking the PTE pointer for other reasons such as on
> 64-K pages, we have a "hidden" part of the PTE that is at PTE address +
> 32K, or we may want to get to the PTE page for some reason (some arch
> store things there) etc...
> 
> IE. update_mmu_cache() would be more generally useful if it took the
> ptep instead of the pte. Of course, I'm sure some embedded archs are
> going to cry for the added load here ... 
> 
> I like your idea. I'll look into doing a patch converting it and will
> post it here.

Well, I wasn't proposing

		update_mmu_cache(vma, address, ptep);
but
		update_mmu_cache(vma, address, *ptep);

which may not meet your future idea, but is much less churn for now
i.e. no change to any of the arch's update_mmu_cache(),
just a change to some of its callsites.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

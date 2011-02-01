Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EC85E8D0041
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 11:10:01 -0500 (EST)
Date: Tue, 1 Feb 2011 17:09:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 5/6] teach smaps_pte_range() about THP pmds
Message-ID: <20110201160932.GY16981@random.random>
References: <20110201003357.D6F0BE0D@kernel>
 <20110201003403.736A24DF@kernel>
 <20110201101111.GK19534@cmpxchg.org>
 <1296572550.27022.2862.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296572550.27022.2862.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 01, 2011 at 07:02:30AM -0800, Dave Hansen wrote:
> On Tue, 2011-02-01 at 11:11 +0100, Johannes Weiner wrote:
> > On Mon, Jan 31, 2011 at 04:34:03PM -0800, Dave Hansen wrote:
> > > +	if (pmd_trans_huge(*pmd)) {
> > > +		if (pmd_trans_splitting(*pmd)) {
> > > +			spin_unlock(&walk->mm->page_table_lock);
> > > +			wait_split_huge_page(vma->anon_vma, pmd);
> > > +			spin_lock(&walk->mm->page_table_lock);
> > > +			goto normal_ptes;
> > > +		}
> > > +		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_SIZE, walk);
> > > +		return 0;
> > > +	}
> > > +normal_ptes:
> > >  	split_huge_page_pmd(walk->mm, pmd);
> > 
> > This line can go away now...?
> 
> I did this because I was unsure what keeps khugepaged away from the
> newly-split ptes between the wait_split_huge_page() and the
> reacquisition of the mm->page_table_lock.  mmap_sem, perhaps?

Any of mmap_sem read mode, PG_lock and anon_vma_lock keeps khugepaged
away.

> Looking at follow_page() and some of the other wait_split_huge_page(),
> it looks like this is unnecessary.  

When wait_split_huge_page returns after the pmd was splitting, the pmd
can't return huge under you as long as you hold any of the above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBBE8D0041
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 10:02:38 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p11EpKeW007513
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 07:51:20 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p11F2WiR244284
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 08:02:32 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p11F2Wce013335
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 08:02:32 -0700
Subject: Re: [RFC][PATCH 5/6] teach smaps_pte_range() about THP pmds
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110201101111.GK19534@cmpxchg.org>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201003403.736A24DF@kernel>  <20110201101111.GK19534@cmpxchg.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 01 Feb 2011 07:02:30 -0800
Message-ID: <1296572550.27022.2862.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2011-02-01 at 11:11 +0100, Johannes Weiner wrote:
> On Mon, Jan 31, 2011 at 04:34:03PM -0800, Dave Hansen wrote:
> > +	if (pmd_trans_huge(*pmd)) {
> > +		if (pmd_trans_splitting(*pmd)) {
> > +			spin_unlock(&walk->mm->page_table_lock);
> > +			wait_split_huge_page(vma->anon_vma, pmd);
> > +			spin_lock(&walk->mm->page_table_lock);
> > +			goto normal_ptes;
> > +		}
> > +		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_SIZE, walk);
> > +		return 0;
> > +	}
> > +normal_ptes:
> >  	split_huge_page_pmd(walk->mm, pmd);
> 
> This line can go away now...?

I did this because I was unsure what keeps khugepaged away from the
newly-split ptes between the wait_split_huge_page() and the
reacquisition of the mm->page_table_lock.  mmap_sem, perhaps?

Looking at follow_page() and some of the other wait_split_huge_page(),
it looks like this is unnecessary.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

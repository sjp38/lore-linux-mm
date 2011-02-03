Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2543F8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:40:30 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p13LL9Si027025
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 16:22:02 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 56F41728067
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:40:27 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p13LeQIQ120560
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 16:40:27 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p13LeQZ0025423
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 19:40:26 -0200
Subject: Re: [RFC][PATCH 3/6] break out smaps_pte_entry() from
 smaps_pte_range()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1102031315080.1307@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201003401.95CFBFA6@kernel>
	 <alpine.DEB.2.00.1102031315080.1307@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 03 Feb 2011 13:40:23 -0800
Message-ID: <1296769223.8299.1658.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 2011-02-03 at 13:22 -0800, David Rientjes wrote:
> On Mon, 31 Jan 2011, Dave Hansen wrote:
> > We will use smaps_pte_entry() in a moment to handle both small
> > and transparent large pages.  But, we must break it out of
> > smaps_pte_range() first.
> 
> The extraction from smaps_pte_range() looks good.  What's the performance 
> impact on very frequent consumers of /proc/pid/smaps, though, as the 
> result of the calls throughout the iteration if smaps_pte_entry() doesn't 
> get inlined (supposedly because you'll be reusing the extracted function 
> again elsewhere)?

We could try and coerce it in to always inlining it, I guess.  I just
can't imagine this changes the cost _that_ much.  Unless I have some
specific concers, I tend to leave this up to the compiler, and none of
the users look particularly fastpathy or performance sensitive to me.

...
> > -	}
> > +	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > +	for (; addr != end; pte++, addr += PAGE_SIZE)
> > +		smaps_pte_entry(*pte, addr, walk);
> >  	pte_unmap_unlock(pte - 1, ptl);
> >  	cond_resched();
> >  	return 0;
> > diff -puN mm/huge_memory.c~break-out-smaps_pte_entry mm/huge_memory.c
> > _
> 
> Is there a missing change to mm/huge_memory.c?

Nope, it was just more of those empty diffs like in the last patch.
It's cruft from patch-scripts and some code that I use to ensure I don't
miss file edits when making patches.  I'll pull them out.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

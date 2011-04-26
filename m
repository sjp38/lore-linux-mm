Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1516D9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:57:48 -0400 (EDT)
Date: Tue, 26 Apr 2011 15:57:43 +0100
From: Matt Fleming <matt@console-pimps.org>
Subject: Re: [RFC][PATCH 2/3] track numbers of pagetable pages
Message-ID: <20110426155743.2e76282d@mfleming-mobl1.ger.corp.intel.com>
In-Reply-To: <1303138924.9615.2487.camel@nimitz>
References: <20110415173821.62660715@kernel>
	<20110415173823.EA7A7473@kernel>
	<20110416104456.3915b7de@mfleming-mobl1.ger.corp.intel.com>
	<1303138924.9615.2487.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

[Added Hugh Dickins to the CC list]

Sorry it's taken me so long to reply Dave.

On Mon, 18 Apr 2011 08:02:04 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Sat, 2011-04-16 at 10:44 +0100, Matt Fleming wrote:
> > >  static inline void pgtable_page_dtor(struct mm_struct *mm, struct page *page)
> > >  {
> > >  	pte_lock_deinit(page);
> > > +	dec_mm_counter(mm, MM_PTEPAGES);
> > >  	dec_zone_page_state(page, NR_PAGETABLE);
> > >  }
> > 
> > I'm probably missing something really obvious but...
> > 
> > Is this safe in the non-USE_SPLIT_PTLOCKS case? If we're not using
> > split-ptlocks then inc/dec_mm_counter() are only safe when done under
> > mm->page_table_lock, right? But it looks to me like we can end up doing,
> > 
> >   __pte_alloc()
> >       pte_alloc_one()
> >           pgtable_page_ctor()
> > 
> > before acquiring mm->page_table_lock in __pte_alloc().
> 
> No, it's probably not safe.  We'll have to come up with something a bit
> different in that case.  Either that, or just kill the non-atomic case.
> Surely there's some percpu magic counter somewhere in the kernel that is
> optimized for fast (unlocked?) updates and rare, slow reads.

It seems it was Hugh that added these atomics in f412ac08c986 ("[PATCH]
mm: fix rss and mmlist locking").

Hugh, what was the reason that you left the old counters around (the
ones protected by page_table_lock)? It seems to me that we could
delete those and just have the single case that uses the atomic_t
operations.

Would anyone object to a patch that removed the non-atomic case?

-- 
Matt Fleming, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

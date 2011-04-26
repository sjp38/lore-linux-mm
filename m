Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6549000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:26:05 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p3QJQ2Zi028055
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:26:02 -0700
Received: from iwn2 (iwn2.prod.google.com [10.241.68.66])
	by wpaz9.hot.corp.google.com with ESMTP id p3QJQ1GH023600
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:26:01 -0700
Received: by iwn2 with SMTP id 2so1014025iwn.40
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:26:01 -0700 (PDT)
Date: Tue, 26 Apr 2011 12:26:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC][PATCH 2/3] track numbers of pagetable pages
In-Reply-To: <20110426155743.2e76282d@mfleming-mobl1.ger.corp.intel.com>
Message-ID: <alpine.LSU.2.00.1104261217430.9334@sister.anvils>
References: <20110415173821.62660715@kernel> <20110415173823.EA7A7473@kernel> <20110416104456.3915b7de@mfleming-mobl1.ger.corp.intel.com> <1303138924.9615.2487.camel@nimitz> <20110426155743.2e76282d@mfleming-mobl1.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@console-pimps.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 26 Apr 2011, Matt Fleming wrote:

> [Added Hugh Dickins to the CC list]
> 
> Sorry it's taken me so long to reply Dave.
> 
> On Mon, 18 Apr 2011 08:02:04 -0700
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
> > On Sat, 2011-04-16 at 10:44 +0100, Matt Fleming wrote:
> > > >  static inline void pgtable_page_dtor(struct mm_struct *mm, struct page *page)
> > > >  {
> > > >  	pte_lock_deinit(page);
> > > > +	dec_mm_counter(mm, MM_PTEPAGES);
> > > >  	dec_zone_page_state(page, NR_PAGETABLE);
> > > >  }
> > > 
> > > I'm probably missing something really obvious but...
> > > 
> > > Is this safe in the non-USE_SPLIT_PTLOCKS case? If we're not using
> > > split-ptlocks then inc/dec_mm_counter() are only safe when done under
> > > mm->page_table_lock, right? But it looks to me like we can end up doing,
> > > 
> > >   __pte_alloc()
> > >       pte_alloc_one()
> > >           pgtable_page_ctor()
> > > 
> > > before acquiring mm->page_table_lock in __pte_alloc().
> > 
> > No, it's probably not safe.  We'll have to come up with something a bit
> > different in that case.  Either that, or just kill the non-atomic case.
> > Surely there's some percpu magic counter somewhere in the kernel that is
> > optimized for fast (unlocked?) updates and rare, slow reads.
> 
> It seems it was Hugh that added these atomics in f412ac08c986 ("[PATCH]
> mm: fix rss and mmlist locking").
> 
> Hugh, what was the reason that you left the old counters around (the
> ones protected by page_table_lock)? It seems to me that we could
> delete those and just have the single case that uses the atomic_t
> operations.

The only reason was to avoid adding costly atomic operations into a
configuration that had no need for them there: the page_table_lock
sufficed.

Certainly it would be simpler just to delete the non-atomic variant.

And I think it's fair to say that any configuration on which we're
measuring performance to that degree (rather than "does it boot fast?"
type measurements), would already be going the split ptlocks route.

> 
> Would anyone object to a patch that removed the non-atomic case?

Not I.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

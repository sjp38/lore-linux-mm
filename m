Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ACE5A6B00A8
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 01:23:51 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id o2B6NluB025746
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 06:23:48 GMT
Received: from gyh20 (gyh20.prod.google.com [10.243.50.212])
	by spaceape10.eur.corp.google.com with ESMTP id o2B6Nj6R030330
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 22:23:46 -0800
Received: by gyh20 with SMTP id 20so2554357gyh.16
        for <linux-mm@kvack.org>; Wed, 10 Mar 2010 22:23:45 -0800 (PST)
Date: Thu, 11 Mar 2010 06:23:33 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: mm/ksm.c seems to be doing an unneeded _notify.
In-Reply-To: <20100310221903.GC5967@random.random>
Message-ID: <alpine.LSU.2.00.1003110617540.29040@sister.anvils>
References: <20100310191842.GL5677@sgi.com> <4B97FED5.2030007@redhat.com> <20100310221903.GC5967@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Robin Holt <holt@sgi.com>, Chris Wright <chrisw@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Mar 2010, Andrea Arcangeli wrote:
> On Wed, Mar 10, 2010 at 10:19:33PM +0200, Izik Eidus wrote:
> > On 03/10/2010 09:18 PM, Robin Holt wrote:
> > > While reviewing ksm.c, I noticed that ksm.c does:
> > >
> > >          if (pte_write(*ptep)) {
> > >                  pte_t entry;
> > >
> > >                  swapped = PageSwapCache(page);
> > >                  flush_cache_page(vma, addr, page_to_pfn(page));
> > >                  /*
> > >                   * Ok this is tricky, when get_user_pages_fast() run it doesnt
> > >                   * take any lock, therefore the check that we are going to make
> > >                   * with the pagecount against the mapcount is racey and
> > >                   * O_DIRECT can happen right after the check.
> > >                   * So we clear the pte and flush the tlb before the check
> > >                   * this assure us that no O_DIRECT can happen after the check
> > >                   * or in the middle of the check.
> > >                   */
> > >                  entry = ptep_clear_flush(vma, addr, ptep);
> > >                  /*
> > >                   * Check that no O_DIRECT or similar I/O is in progress on the
> > >                   * page
> > >                   */
> > >                  if (page_mapcount(page) + 1 + swapped != page_count(page)) {
> > >                          set_pte_at_notify(mm, addr, ptep, entry);
> > >                          goto out_unlock;
> > >                  }
> > >                  entry = pte_wrprotect(entry);
> > >                  set_pte_at_notify(mm, addr, ptep, entry);
> > >
> > >
> > > I would think the error case (where the page has an elevated page_count)
> > > should not be using set_pte_at_notify.  In that event, you are simply
> > > restoring the previous value.  Have I missed something or is this an
> > > extraneous _notify?
> > >    
> > 
> > Yes, I think you are right set_pte_at(mm, addr, ptep, entry);  would be
> > enough here.
> > 
> > I can`t remember or think any reason why I have used the _notify...
> > 
> > Lets just get ACK from Andrea and Hugh that they agree it isn't needed
> 
> _notify it's needed, we're downgrading permissions here.

Robin is not questioning that it's needed in the success case;
but in the case where we back out because the counts don't match,
and just put back the original entry, he's suggesting that then
the _notify isn't needed.

(I'm guessing that Robin is not making a significant improvement to KSM,
but rather trying to clarify his understanding of set_pte_at_notify.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

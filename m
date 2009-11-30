Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3CB600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 16:27:12 -0500 (EST)
Subject: Re: [PATCH 1/9] ksm: fix mlockfreed to munlocked
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0911301200060.24660@sister.anvils>
References: <20091126162011.GG13095@csn.ul.ie>
	 <Pine.LNX.4.64.0911271214040.4167@sister.anvils>
	 <20091130143915.5BD1.A69D9226@jp.fujitsu.com>
	 <Pine.LNX.4.64.0911301200060.24660@sister.anvils>
Content-Type: text/plain
Date: Mon, 30 Nov 2009 16:27:01 -0500
Message-Id: <1259616421.4663.205.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-30 at 12:26 +0000, Hugh Dickins wrote:
> On Mon, 30 Nov 2009, KOSAKI Motohiro wrote:
> > > 
> > > But please clarify: that patch was for mmotm and hopefully 2.6.33,
> > > but the vmstat issue (minus warning message) is there in 2.6.32-rc.
> > > Should I
> > > 
> > > (a) forget it for 2.6.32
> > > (b) rush Linus a patch for 2.6.32 final
> > > (c) send a patch for 2.6.32.stable later on
> > 
> > I personally prefer (3). though I don't know ksm so detail.
> 
> Thanks, I think that would be my preference by now too.
> 
> > > There's a remark in munlock_vma_page(), apropos a different issue,
> > > 			/*
> > > 			 * We lost the race.  let try_to_unmap() deal
> > > 			 * with it.  At least we get the page state and
> > > 			 * mlock stats right.  However, page is still on
> > > 			 * the noreclaim list.  We'll fix that up when
> > > 			 * the page is eventually freed or we scan the
> > > 			 * noreclaim list.
> > > 			 */
> > > which implies that sometimes we scan the unevictable list and resolve
> > > such cases.  But I wonder if that's nowadays the case?
> > 
> > We don't scan unevictable list at all. munlock_vma_page() logic is.
> > 
> >   1) clear PG_mlock always anyway
> >   2) isolate page
> >   3) scan related vma and remark PG_mlock if necessary
> > 
> > So, as far as I understand, the above comment describe the case when (2) is
> > failed. it mean another task already isolated the page. it makes the task
> > putback the page to evictable list and vmscan's try_to_unmap() move 
> > the page to unevictable list again.
> 
> That is the case it's addressing, yes; but both references to
> "the noreclaim list" are untrue and misleading (now: they may well
> have been accurate when the comment went in).  I'd like to correct
> it, but cannot do so without spending the time to make sure that
> what I'm saying instead isn't equally misleading...
> 
> Even "We lost the race" is worrying: which race? there might be several.

I agree that this is likely a stale comment.  At the time I wrote it,
putback_lru_page() didn't recheck whether the page was reclaimable [now
"evictable"].  isolate_lru_page() preserves the lru state flags Active
and Unevictable; at that time putback' just put the page back to the
list indicated.  

"The race" referred to the "isolation race" discussed in the comment
block on munlock_vma_page().

Had we been munlock()ing or munmap()ing the last VMA holding the page
locked, we should take it off the unevictable list.  But, we need to
isolate the page to move it between lists or even to call
try_to_unlock() to check whether there are other vmas holding the page
mlocked.  If we were unable to isolate the page in munlock_vma_page()
and it were "putback" by whatever was holding it [page migration
maybe?], it would go back onto the unevictable list where it would be
stranded. 

Now that we recheck the page state in putback_lru_page(), this shouldn't
be an issue.  We've already cleared the Mlock page flag, so that
condition won't force it onto the unevictable list.

Even the part about try_to_unmap() dealing with it is stale.  Now,
vmscan detects VM_LOCKED pages in page_referenced() before it gets to
try_to_unmap().  The function comment block needs updating as well.  If
no one beats me to it, I'll post a cleanup patch for consideration
shortly.

Lee


> 
> Hugh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

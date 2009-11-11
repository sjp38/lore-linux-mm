Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B5D5A6B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 06:36:19 -0500 (EST)
Date: Wed, 11 Nov 2009 11:36:15 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <20091111102400.FD36.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0911111048170.12126@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
 <Pine.LNX.4.64.0911102151500.2816@sister.anvils> <20091111102400.FD36.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009, KOSAKI Motohiro wrote:

Though it doesn't quite answer your question,
I'll just reinsert the last paragraph of my description here...

> > try_to_unmap_file()'s TTU_MUNLOCK nonlinear handling was particularly
> > amusing: once unravelled, it turns out to have been choosing between
> > two different ways of doing the same nothing.  Ah, no, one way was
> > actually returning SWAP_FAIL when it meant to return SWAP_SUCCESS.

... 
> > @@ -1081,45 +1053,23 @@ static int try_to_unmap_file(struct page
...
> >
> > -	if (list_empty(&mapping->i_mmap_nonlinear))
> > +	/* We don't bother to try to find the munlocked page in nonlinears */
> > +	if (MLOCK_PAGES && TTU_ACTION(flags) == TTU_MUNLOCK)
> >  		goto out;
> 
> I have dumb question.
> Does this shortcut exiting code makes any behavior change?

Not dumb.  My intention was to make no behaviour change with any of
this patch; but in checking back before completing the description,
I suddenly realized that that shortcut intentionally avoids the

	if (max_nl_size == 0) {	/* all nonlinears locked or reserved ? */
		ret = SWAP_FAIL;
		goto out;
	}

(which doesn't show up in the patch: you'll have to look at rmap.c),
which used to have the effect of try_to_munlock() returning SWAP_FAIL
in the case when there were one or more VM_NONLINEAR vmas of the file,
but none of them (and none of the covering linear vmas) VM_LOCKED.

That should have been a SWAP_SUCCESS case, or with my changes
another SWAP_AGAIN, either of which would make munlock_vma_page()
				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
which would be correct; but the SWAP_FAIL meant that count was not
incremented in this case.

Actually, I've double-fixed that, because I also changed
munlock_vma_page() to increment the count whenever ret != SWAP_MLOCK;
which seemed more appropriate, but would have been a no-op if
try_to_munlock() only returned SWAP_SUCCESS or SWAP_AGAIN or SWAP_MLOCK
as it claimed.

But I wasn't very inclined to boast of fixing that bug, since my testing
didn't give confidence that those /proc/vmstat unevictable_pgs_*lock*
counts are being properly maintained anyway - when I locked the same
pages in two vmas then unlocked them in both, I ended up with mlocked
bigger than munlocked (with or without my 2/6 patch); which I suspect
is wrong, but rather off my present course towards KSM swapping...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

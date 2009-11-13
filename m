Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7F2B96B006A
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 03:26:23 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD8QKBj027979
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Nov 2009 17:26:21 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C431345DE4F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 17:26:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9049245DE4E
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 17:26:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DD9BE38002
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 17:26:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C95DC1DB803B
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 17:26:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <20091113143930.33BF.A69D9226@jp.fujitsu.com>
References: <Pine.LNX.4.64.0911111048170.12126@sister.anvils> <20091113143930.33BF.A69D9226@jp.fujitsu.com>
Message-Id: <20091113172453.33CB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Nov 2009 17:26:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > On Wed, 11 Nov 2009, KOSAKI Motohiro wrote:
> > 
> > Though it doesn't quite answer your question,
> > I'll just reinsert the last paragraph of my description here...
> > 
> > > > try_to_unmap_file()'s TTU_MUNLOCK nonlinear handling was particularly
> > > > amusing: once unravelled, it turns out to have been choosing between
> > > > two different ways of doing the same nothing.  Ah, no, one way was
> > > > actually returning SWAP_FAIL when it meant to return SWAP_SUCCESS.
> > 
> > ... 
> > > > @@ -1081,45 +1053,23 @@ static int try_to_unmap_file(struct page
> > ...
> > > >
> > > > -	if (list_empty(&mapping->i_mmap_nonlinear))
> > > > +	/* We don't bother to try to find the munlocked page in nonlinears */
> > > > +	if (MLOCK_PAGES && TTU_ACTION(flags) == TTU_MUNLOCK)
> > > >  		goto out;
> > > 
> > > I have dumb question.
> > > Does this shortcut exiting code makes any behavior change?
> > 
> > Not dumb.  My intention was to make no behaviour change with any of
> > this patch; but in checking back before completing the description,
> > I suddenly realized that that shortcut intentionally avoids the
> > 
> > 	if (max_nl_size == 0) {	/* all nonlinears locked or reserved ? */
> > 		ret = SWAP_FAIL;
> > 		goto out;
> > 	}
> > 
> > (which doesn't show up in the patch: you'll have to look at rmap.c),
> > which used to have the effect of try_to_munlock() returning SWAP_FAIL
> > in the case when there were one or more VM_NONLINEAR vmas of the file,
> > but none of them (and none of the covering linear vmas) VM_LOCKED.
> > 
> > That should have been a SWAP_SUCCESS case, or with my changes
> > another SWAP_AGAIN, either of which would make munlock_vma_page()
> > 				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
> > which would be correct; but the SWAP_FAIL meant that count was not
> > incremented in this case.
> 
> Ah, correct.
> Then, we lost the capability unevictability of non linear mapping pages, right.
> if so, following additional patch makes more consistent?

[indistinct muttering]

Probably we can remove VM_NONLINEAR perfectly. I've never seen real user of it.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

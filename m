Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF6968D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 20:45:13 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id oAG1j9Mv018994
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 17:45:10 -0800
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by wpaz17.hot.corp.google.com with ESMTP id oAG1j7Ew012972
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 17:45:08 -0800
Received: by pzk28 with SMTP id 28so22586pzk.33
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 17:45:07 -0800 (PST)
Date: Mon, 15 Nov 2010 17:44:56 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: RFC: reviving mlock isolation dead code
In-Reply-To: <20101112142038.E002.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1011151717130.10920@tigran.mtv.corp.google.com>
References: <20101109115540.BC3F.A69D9226@jp.fujitsu.com> <AANLkTinrtXrwgwUXNOaM_AGin2iEMqN2wWciMzJUPUyB@mail.gmail.com> <20101112142038.E002.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:
> Michel Lespinasse <walken@google.com> wrote:
> > ...
> > The other mlock related issue I have is that it marks pages as dirty
> > (if they are in a writable VMA), and causes writeback to work on them,
> > even though the pages have not actually been modified. This looks like
> > it would be solvable with a new get_user_pages flag for mlock use
> > (breaking cow etc, but not writing to the pages just yet).
> 
> To be honest, I haven't understand why current code does so. I dislike it too. but
> I'm not sure such change is safe or not. I hope another developer comment you ;-)

It's been that way for years, and the primary purpose is to do the COWs
in advance, so we won't need to allocate new pages later to the locked
area: the pages that may be needed are already locked down.

That justifies it for the private mapping case, but what of shared maps?
There the justification is that the underlying file might be sparse, and
we want to allocate blocks upfront for the locked area.

Do we?  I dislike it also, as you both do.  It seems crazy to mark a
vast number of pages as dirty when they're not.

It makes sense to mark pte_dirty when we have a real write fault to a
page, to save the mmu from making that pagetable transaction immediately
after; but it does not make sense when the write (if any) may come
minutes later - we'll just do a pointless write and clear dirty meanwhile.

A new __get_user_pages flag (for use by make_pages_present) might make a
good saving there, but I've not thought it through.  Tell page_mkwrite
that we're doing a write (to do allocation in those FSes that care),
but avoid marking the pte as dirty?  I'm not sure, and you might need
to be careful with the dirty balancing too.

If it does work out, I think you'd need to be passing the flag down to
follow_page too: I have a patch or patches to merge the FOLL_flags with
the FAULT_FLAGs - Linus wanted that a year ago, and I recently met a
need for it with shmem - I'd better accelerate sending those in.

Here's a link to the last(?) time mlock dirtying was discussed,
http://lkml.org/lkml/2007/7/26/457
worth reading; we could Cc the guys from that thread, though I haven't.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EC0348D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 07:48:27 -0400 (EDT)
Date: Tue, 22 Mar 2011 20:47:56 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [BUG?] shmem: memory leak on NO-MMU arch
Message-ID: <20110322114756.GI25925@linux-sh.org>
References: <1299575863-7069-1-git-send-email-lliubbo@gmail.com> <alpine.LSU.2.00.1103201258280.3776@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1103201258280.3776@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, David Howells <dhowells@redhat.com>, Magnus Damm <magnus.damm@gmail.com>

On Sun, Mar 20, 2011 at 01:35:50PM -0700, Hugh Dickins wrote:
> On Tue, 8 Mar 2011, Bob Liu wrote:
> > Hi, folks
> 
> Of course I agree with Al and Andrew about your other patch,
> I don't know of any shmem inode leak in the MMU case.
> 
> I'm afraid we MM folks tend to be very ignorant of the NOMMU case.
> I've sometimes wished we had a NOMMU variant of the x86 architecture,
> that we could at least build and test changes on.
> 
NOMMU folks tend to be very ignorant of the MM cases, so it all balances
out :-)

> Let's Cc David, Paul and Magnus: they do understand NOMMU.
> 
> > root:/> ./shmem 
> > run ok...
> > root:/> free 
> >               total         used         free       shared      buffers
> >   Mem:        60528        19904        40624            0            0
> > root:/> ./shmem 
> > run ok...
> > root:/> free 
> >               total         used         free       shared      buffers
> >   Mem:        60528        21104        39424            0            0
> > root:/>
> > 
> > It seems the shmem didn't free it's memory after using shmctl(IPC_RMID) to rm
> > it.
> 
> There does indeed appear to be a leak there.  But I'm feeling very
> stupid, the leak of ~1200kB per run looks a lot more than the ~20kB
> that each run of your test program would lose if the bug is as you say.
> Maybe I can't count today.
> 
Your 1200 figure looks accurate, I came up with the same figure. In any
event, it would be interesting to know what page size is being used. It's
not uncommon to see a 64kB PAGE_SIZE on a system with 64M of memory, but
that still wouldn't account for that level of discrepancy.

My initial thought was that perhaps we were missing a
truncate_pagecache() for a caller of ramfs_nommu_expand_for_mapping() on
an existing inode with an established size (which assumes that one is
always expanding from 0 up, and so doesn't bother with truncating), but
the shmem user in this case is fetching a new inode on each iteration so
this seems improbable, and the same 1200kB discrepancy is visible even
after the initial shmget. I'm likely overlooking something obvious.

> Yet it does look to me that you're right that ramfs_nommu_expand_for_mapping
> forgets to release a reference to its pages; though it's hard to believe
> that could go unnoticed for so long - more likely we're both overlooking
> something.
> 
page refcounting on nommu has a rather tenuous relationship with reality
at the best of times; surprise was indeed not the first thought that came
to mind.

My guess is that this used to be caught by virtue of the __put_page()
hack we used to have in __free_pages_ok() for the nommu case, prior to
the conversion to compound pages.

> Here's my own suggestion for a patch; but I've not even tried to
> compile it, let alone test it, so I'm certainly not signing it.
> 
This definitely looks like an improvement, but I wonder if it's not
easier to simply use alloc_pages_exact() and throw out the bulk of the
function entirely (a __GFP_ZERO would further simplify things, too)?

> @@ -114,11 +110,14 @@ int ramfs_nommu_expand_for_mapping(struc
>  		unlock_page(page);
>  	}
>  
> -	return 0;
> +	/*
> +	 * release our reference to the pages now added to cache,
> +	 * and trim off any pages we don't actually require.
> +	 * truncate inode back to 0 if not all pages could be added??
> +	 */
> +	for (loop = 0; loop < xpages; loop++)
> +		put_page(pages + loop);
>  
Unless you have some callchain in mind that I'm not aware of, an error is
handed back when add_to_page_cache_lru() fails and the inode is destroyed
by the caller in each case. As such, we should make it down to
truncate_inode_pages(..., 0) via natural iput() eviction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

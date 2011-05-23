Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C3ACB6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 17:11:17 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p4NLB7Zd022507
	for <linux-mm@kvack.org>; Mon, 23 May 2011 14:11:14 -0700
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by kpbe14.cbf.corp.google.com with ESMTP id p4NLAt8n017842
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 14:10:55 -0700
Received: by pvh11 with SMTP id 11so4127500pvh.22
        for <linux-mm@kvack.org>; Mon, 23 May 2011 14:10:52 -0700 (PDT)
Date: Mon, 23 May 2011 14:10:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Consistency of loops in mm/truncate.c?
In-Reply-To: <20110523134439.22582eee.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1105231357080.25080@sister.anvils>
References: <alpine.LSU.2.00.1105221526020.17400@sister.anvils> <20110523134439.22582eee.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 23 May 2011, Andrew Morton wrote:
> On Sun, 22 May 2011 15:27:41 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> > 
> > The advancement of index is hard to follow: we rely upon page->index
> > of an unlocked page persisting, yet we're ashamed of doing so, sometimes
> > reading it again once locked.  invalidate_mapping_pages() apologizes for
> > this, but I think we should now just document that page->index is not
> > modified until the page is freed.
> 
> That should be true under i_mutex and perhaps other external locking. 
> We could put some debug checks in there to catch any situation where
> ->index changed after the page was locked.

Okay, I'll look into doing that; and adding a comment in the
"page->mapping = NULL;" places in mm/filemap.c, explaining that
we do need to leave page->index untouched.

> 
> > invalidate_inode_pages2_range() has two sophistications not seen
> > elsewhere, which 7afadfdc says were folded in by akpm (along with
> > a page->index one):
> > 
> > - Don't look up more pages than we're going to use:
> >   seems a good thing for me to fold into truncate_inode_pages_range()
> >   and invalidate_mapping_pages() too.
> 
> I guess so.  I doubt if it makes a measurable performance difference
> (except maybe in the case of small direct-io's?) but consistency is
> good.

I guess it occasionally saves the radix_tree lookup from accessing a
few unnecessary cachelines; not a big win, but I think better to add
it where it's missing than remove it from the place you thought of it.

> 
> > - Check for the cursor wrapping at the end of the mapping:
> >   but with
> > 
> > #if BITS_PER_LONG==32
> > #define MAX_LFS_FILESIZE (((u64)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1) 
> > #elif BITS_PER_LONG==64
> > #define MAX_LFS_FILESIZE 0x7fffffffffffffffUL
> > #endif
> > 
> >   I don't see how page->index + 1 would ever be 0, even if one or
> >   other of those "-1"s went away; so may I delete the "wrapped" case?
> 
> err yes, that seems bogus now and was bogus at the time.  I never
> trusted that s_maxbytes thing :)

Right, I was wondering this morning whether we can always rely upon
s_maxbytes: I was taking the SHMEM_MAX_INDEX check out of shmem_getpage(),
but maybe some cases need it to stay.  I'll do some more checking,
but hope to remove those wrapped checks.

Thanks for the confirmations,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

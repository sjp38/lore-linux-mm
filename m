Date: Wed, 4 Feb 2004 13:04:40 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/5] mm improvements
Message-Id: <20040204130440.71d4be3c.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0402042047040.4021-100000@localhost.localdomain>
References: <20040204103307.7a288ce3.akpm@osdl.org>
	<Pine.LNX.4.44.0402042047040.4021-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nikita@Namesys.COM, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> On Wed, 4 Feb 2004, Andrew Morton wrote:
> > Hugh Dickins <hugh@veritas.com> wrote:
> > >
> > >  Sorry, that BUG_ON is there for very good reason.  It's no disgrace
> > >  that your testing didn't notice the effect of passing a mapped page
> > >  down to shmem_writepage, but it is a serious breakage of tmpfs.
> > 
> > hm.  Can't I force writepage-of-a-mapped-page with msync()?
> 
> I hope not, __filemap_fdatawrite still starts off with:
> 
> 	if (mapping->backing_dev_info->memory_backed)
> 		return 0;

Sigh.  ->memory_backed is a crock.  It is excessively overloaded and needs
to be split up into several things which really mean something.

> Once upon a time you did have vmscan.c calling ->writepages, rather
> the effect that Nikita is trying for.  It was that writepages which
> led me to insert the BUG_ON and give tmpfs a dummy writepages.
> Later on you dropped the ->writepages from vmscan.c:
> do you remember why? would be useful info for Nikita.

I'd need to troll the changelogs to remember the exact reason.  I had the
standalone a_ops->vm_writeback thing in there, which was able to do
writearound against the targetted page.  iirc it was causing some difficulties and
as a big effort was underway to minimise the amount of writeout via vmscan
_anyway_, I decided to toss it all out, stick with page-at-a-time writepage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

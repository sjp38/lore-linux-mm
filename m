Date: Mon, 8 Nov 2004 14:28:37 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] ignore referenced pages on reclaim when OOM
Message-Id: <20041108142837.307029fc.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0411081655410.8589-100000@chimarrao.boston.redhat.com>
References: <16783.59834.7179.464876@thebsh.namesys.com>
	<Pine.LNX.4.44.0411081655410.8589-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: nikita@clusterfs.com, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> wrote:
>
> On Tue, 9 Nov 2004, Nikita Danilov wrote:
> 
> >  > Speeds up extreme load performance on Rik's tests.
> > 
> > I recently tested quite similar thing, the only dfference being that in
> > my case references bit started being ignored when scanning priority
> > reached 2 rather than 0.
> > 
> > I found that it _degrades_ performance in the loads when there is a lot
> > of file system write-back going from tail of the inactive list (like
> > dirtying huge file through mmap in a loop).
> 
> Well yeah, when you reach priority 2, you've only scanned
> 1/4 of memory.  On the other hand, when you reach priority
> 0, you've already scanned all pages once - beyond that point
> the referenced bit really doesn't buy you much any more.
> 

But we have to scan active, referenced pages two times to move them onto
the inactive list.  A bit more, really, because nowadays
refill_inactive_zone() doesn't even run page_referenced() until it starts
to reach higher scanning priorities.

So it could be that we're just not scanning enough.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

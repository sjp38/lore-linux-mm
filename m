Date: Wed, 7 Nov 2007 13:16:27 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 0/10] split anon and file LRUs
Message-ID: <20071107131627.57e8f666@bree.surriel.com>
In-Reply-To: <20071107095945.c9b870fc.akpm@linux-foundation.org>
References: <20071103184229.3f20e2f0@bree.surriel.com>
	<Pine.LNX.4.64.0711061808460.5249@schroedinger.engr.sgi.com>
	<20071106212305.6aa3a4fe@bree.surriel.com>
	<Pine.LNX.4.64.0711061834340.5424@schroedinger.engr.sgi.com>
	<20071106215127.29e90ecd@bree.surriel.com>
	<20071107095945.c9b870fc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Nov 2007 09:59:45 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > On Tue, 6 Nov 2007 21:51:27 -0500 Rik van Riel <riel@redhat.com> wrote:

> > Which is why we need to greatly reduce the number of pages
> > scanned to free a page.  In all workloads.
> 
> It strikes me that splitting one list into two lists will not provide
> sufficient improvement in search efficiency to do that. 

Well, if you look at the typical problem systems today, you
will see that most of the pages being allocated and evicted
are in the page cache, while most of the pages in memory are
actually anonymous pages.

Not having to scan over that 80% of memory that contains
anonymous pages and shared memory segments to get at the
20% page cache pages is much more than a factor two
improvement.

> I mean, a naive guess would be that it will, on average, halve the amount
> of work which needs to be done.
> 
> But we need multiple-orders-of-magnitude improvements to address the
> pathological worst-cases which you're looking at there.  Where is this
> coming from?

Replacing page cache pages is easy.  If they were referenced
once (typical), we can just evict the page the first time we
scan it.

Anonymous pages have a similar optimization: every anonymous
page starts out referenced, so moving referenced pages back
to the front of the active list is unneeded work.

However, we cannot just place referenced anonymous pages onto
an inactive list that is shared with page cache pages, because
of the difference in replacement cost and relative importance
of both types of pages!

> Or is the problem which you're seeing due to scanning of mapped pages
> at low "distress" levels?
> 
> Would be interested in seeing more details on all of this, please.

http://linux-mm.org/PageReplacementDesign

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

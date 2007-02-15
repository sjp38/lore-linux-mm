Date: Thu, 15 Feb 2007 15:19:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Message-Id: <20070215151954.4def8c27.akpm@linux-foundation.org>
In-Reply-To: <45D4E3B6.8050009@redhat.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	<45D4DF28.7070409@redhat.com>
	<Pine.LNX.4.64.0702151439520.32026@schroedinger.engr.sgi.com>
	<45D4E3B6.8050009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007 17:50:30 -0500
Rik van Riel <riel@redhat.com> wrote:

> Christoph Lameter wrote:
> > On Thu, 15 Feb 2007, Rik van Riel wrote:
> > 
> >> Running out of swap is a temporary condition.
> >> You need to have some way for those pages to
> >> make it back onto the LRU list when swap
> >> becomes available.
> > 
> > Yup any ideas how?
> 
> Not really.

I guess we could be less ambitious.

Obviously, CONFIG_SWAP=n is a no-brainer.

And perhaps it's OK to treat no-swap-online as CONFIG_SWAP=n.  So any pages
which we _tried_ to swap out before any swap was online get treated as
locked memory.  Well, that's just bad luck.  Perhaps we could do some
stupid little manual thing based on the smaps walker:

	echo 1 > /proc/pid/add-your-anon-pages-back-to-the-lru

ug.

Which leaves us wondering what to do about the temporary out-of-swap
problem.  That''ll be hard - we don't want to do a full virtual scan of all
the mm's each time free swap goes from 0kb to 4kb.  I'd suggest that for
now we forget about this case and just put up with the additional scanning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

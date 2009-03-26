Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C84576B003D
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 19:19:47 -0400 (EDT)
Date: Thu, 26 Mar 2009 01:01:00 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] mm: keep pages from unevictable mappings off the LRU lists
Message-ID: <20090326000100.GA5404@cmpxchg.org>
References: <1237752784-1989-3-git-send-email-hannes@cmpxchg.org> <20090321102044.GA3427@cmpxchg.org> <12135.1237805607@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12135.1237805607@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, MinChan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 23, 2009 at 10:53:27AM +0000, David Howells wrote:
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > -		if (page_is_file_cache(page))
> > +		if (mapping_unevictable(mapping))
> > +			add_page_to_unevictable_list(page);
> > +		else if (page_is_file_cache(page))
> 
> It would be nice to avoid adding an extra test and branch in here.  This
> function is used a lot, and quite often we know the answer to the first test
> before we even get here.

Yes, I thought about that too.  So I mounted a tmpfs and dd'd
/dev/zero to a file on it until it ran out of space (around 900M,
without swapping), deleted the file again.  I did this in a tight loop
and profiled it.

I couldn't think of a way that would excercise add_to_page_cache_lru()
more, I hope I didn't overlook anything, please correct if I am wrong.

If I was not, than the extra checking for unevictable mappings doesn't
make a measurable difference.  The function on the vanilla kernel had
a share of 0.2033%, on the patched kernel 0.1953%.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

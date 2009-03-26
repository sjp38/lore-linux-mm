Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 348256B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 04:06:08 -0400 (EDT)
Date: Thu, 26 Mar 2009 17:56:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/3] mm: keep pages from unevictable mappings off the LRU lists
In-Reply-To: <20090326000100.GA5404@cmpxchg.org>
References: <12135.1237805607@redhat.com> <20090326000100.GA5404@cmpxchg.org>
Message-Id: <20090326175314.68F7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, MinChan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> On Mon, Mar 23, 2009 at 10:53:27AM +0000, David Howells wrote:
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > -		if (page_is_file_cache(page))
> > > +		if (mapping_unevictable(mapping))
> > > +			add_page_to_unevictable_list(page);
> > > +		else if (page_is_file_cache(page))
> > 
> > It would be nice to avoid adding an extra test and branch in here.  This
> > function is used a lot, and quite often we know the answer to the first test
> > before we even get here.
> 
> Yes, I thought about that too.  So I mounted a tmpfs and dd'd
> /dev/zero to a file on it until it ran out of space (around 900M,
> without swapping), deleted the file again.  I did this in a tight loop
> and profiled it.
> 
> I couldn't think of a way that would excercise add_to_page_cache_lru()
> more, I hope I didn't overlook anything, please correct if I am wrong.
> 
> If I was not, than the extra checking for unevictable mappings doesn't
> make a measurable difference.  The function on the vanilla kernel had
> a share of 0.2033%, on the patched kernel 0.1953%.

May I ask the number of the cpu of your test box.
In general, lock contention possibility depend on #ofCPUs.

So, I and lee mainly talked about large box.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA25830
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 12:24:40 -0500
Subject: Re: [PATCH] swapin readahead
References: <Pine.LNX.3.96.981201173030.2458A-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
Mime-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 01 Dec 1998 18:20:49 +0100
In-Reply-To: Rik van Riel's message of "Tue, 1 Dec 1998 17:42:08 +0100 (CET)"
Message-ID: <87vhjvkccu.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> In my experience allocations aren't the big problem but
> deallocations. I guess we lose some memory there :(

Yes. something like that. Since nobody asked pages to swap in (we
decided to swap them in) it looks like nobody frees them. :)
So we should free them somewhere, probably.

> > Also, looking at the patch source, it looks like the comment there is
> > completely misleading, as the for() loop is not doing anything, at
> > all. The patch can be shortened to do offset++, if() and only ONE
> > read_swap_cache_async, if I'm understanding it correctly. Sorry, I'm
> > not including it here, have some other things to do fast.
> 
> You have to read each entry separately; you want all of
> them to have an entry in the swap cache...

+
+	/*
+	 * Primitive swap readahead code. We simply read the
+	 * next 16 entries in the swap area. The break below
+	 * is needed or else the request queue will explode :)
+	 */
+	for (i = 1; i++ < 16;) {
+		offset++;
+		if (!swapdev->swap_map[offset] || offset >= swapdev->max
+				|| atomic_read(&nr_async_pages) >
+				pager_daemon.swap_cluster / 2)
+			break;
+		read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset),
+0);
+			break;
+	}               ^^^^^^

Last break in the for() loop, exits the loop after the very first
pass. Why don't you get get rid of the loop, then:

	offset++;
	if (swapdev->swap_map[offset] && offset < swapdev->max
			&& atomic_read(&nr_async_pages) <=
			pager_daemon.swap_cluster / 2)
		read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);

Functionality is exactly the same, and code is much more readable.
Do you see my point now?

I wish you luck with the swapin readahed. I'm also very interested in
the impact it could made, since my tests revealed that swapping in
adjacent pages from swap is quite common operation, so in some
workloads it could be a big win (hogmem, for instance, would probably
be much faster :)).

Good luck!
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	      Black holes are where God divided by zero.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

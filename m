Received: from mail.ccr.net (root@alogconduit1ar.ccr.net [208.130.159.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA09235
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 19:46:10 -0500
Subject: Re: Removing swap lockmap...
References: <87iue47gy4.fsf@atlas.CARNet.hr>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 18 Jan 1999 18:34:50 -0600
In-Reply-To: Zlatko Calusic's message of "18 Jan 1999 16:12:51 +0100"
Message-ID: <m11zksyuad.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

>>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:


ZC> I removed swap lockmap all together and, to my surprise, I can't
ZC> produce any ill behaviour on my system, not even under very heavy
ZC> swapping (in low memory condition).

ZC> I remember there were some issues when swap lockmap was removed in
ZC> 2.1.89, so it was reintroduced later (processes were dying randomly).


ZC> Question is, why is everything running so smoothly now, even without
ZC> swap lockmap?

For this patch to be safe we need to 
A) Fix sysv shm to use the swap cache.
B) garantee that shrink_mmap is the only place that
   removes a page from the swap cache, and that it never removes
   a page while I/O is in progress, (as Stephen said).

This means a lot of the current cases like delete_from_swap_cache,
and free_page_and_swap_cache need to be removed.

And we need to be very carefull when we break down the swap cache,
and make it an unshared page.

The change to normally remove pages with shrink_mmap is what makes it
mostly safe now.

For 2.3 it should go.  For 2.2 it should stay.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA24876
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 10:13:31 -0500
Date: Tue, 1 Dec 1998 15:13:22 GMT
Message-Id: <199812011513.PAA18172@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead
In-Reply-To: <Pine.LNX.3.96.981127001214.445A-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.981127001214.445A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Rik,

In article <Pine.LNX.3.96.981127001214.445A-100000@mirkwood.dummy.home>,
Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> here is a very first primitive version of as swapin
> readahead patch. It seems to give much increased
> throughput to swap and the desktop switch time has
> decreased noticably.

> The checks are all needed. The first two checks are there
> to avoid annoying messages from swap_state.c :)) 

There's a third check needed, I think, which probably accounts for the
swap_duplicate errors people have been noting.  You need to skip pages
which are marked as locked in the swap_lockmap, or the async page read
may block (you might be trying to read in a page which is still being
written to swap).  In this case, by the time you have slept, the swap
entry is not necessarily still in use, so you may end up reading an
unused swap entry.  That would certainly lead to swap_duplicate
warnings, although I think they should be benign.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA27002
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 09:46:51 -0500
Date: Wed, 25 Nov 1998 14:46:38 GMT
Message-Id: <199811251446.OAA01094@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <Pine.LNX.3.96.981125140245.8544A-100000@mirkwood.dummy.home>
References: <199811251227.MAA00808@dax.scot.redhat.com>
	<Pine.LNX.3.96.981125140245.8544A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, jfm2@club-internet.fr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 25 Nov 1998 14:08:47 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Wed, 25 Nov 1998, Stephen C. Tweedie wrote:
>> Rick, get real: when will you work out how the VM works?  We can
>> safely implement RSS limits *today*, and have been able to since
>> 2.1.89.  <grin> 

> If we tried to implement RSS limits now, it would mean that
> the large task(s) we limited would be continuously thrashing
> and keep the I/O subsystem busy -- this impacts the rest of
> the system a lot.

WRONG.  We can very very easily unlink pages from a process's pte (hence
reducing the process's RSS) without removing that page from memory.
It's trivial.  We do it all the time.  We can do it both for
memory-mapped files and for anonymous pages.  In the latest 2.1.130
prepatch, this is in fact the *preferred* way of swapping.  This
mechanism is fundamental to the way we maintain page sharing of swapped
COW pages.

The only thing we cannot do is unlink dirty pages (for swap, that means
pages which have been modified since we last paged the swap back into
memory).  We have to write them back before we unlink.  That does not
mean that we have to throw the data away: as long as the copy on disk is
uptodate, we can have as much of a process's address space as we want in
the page cache or swap cache without it being mapped in the process'
address space and without it counting as task RSS.

Today, such an RSS limit would NOT thrash the IO: it would just cause
minor page faults as we relink the cached page back into the page
tables.  All of that functionality exists today.

Rik, you should probably try to work out how try_to_swap_out() actually
works one of these days.  You'll find it does a lot of neat stuff you
seem to be unaware of!  We are really a lot closer to having a proper
unified page handling mechanism than you think.  The handling of dirty
pages is pretty much the only missing part of the mechanism right now.
Even that is not necessarily a bad thing: there are good performance
reasons why we might want the swap cache to contain only clean pages:
for example, it makes it easier to guarantee that those pages can be
reclaimed for another use at short notice.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

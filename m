Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA07583
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 16:47:56 -0500
Date: Mon, 18 Jan 1999 21:46:40 GMT
Message-Id: <199901182146.VAA09942@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Removing swap lockmap...
In-Reply-To: <87iue47gy4.fsf@atlas.CARNet.hr>
References: <87iue47gy4.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

In article <87iue47gy4.fsf@atlas.CARNet.hr>, Zlatko Calusic
<Zlatko.Calusic@CARNet.hr> writes:

> I removed swap lockmap all together and, to my surprise, I can't
> produce any ill behaviour on my system, not even under very heavy
> swapping (in low memory condition).

Just because you can't reproduce it doesn't mean it works perfectly.
There was a very good reason why the swap lock map was still required
until recently.  The race condition it fixed wass an obscure one but
still important.  However, very recent VM changes make me wonder if it
is still absolutely necessary.  

The problem was that if we swapped out a page, we might sometimes remove
the swap cache for the page before the IO was complete.  If we can
_guarantee_ that the swap cache will persist until after the IO is
complete, then any future attempt to use that swap page will find that
the page is locked and will wait for the IO to complete.

However, if in fact the swap cache for the page _ever_ gets removed
before the IO completes, then a future read in of the page might start
before the current write had completed.  This has been observed in
practice.  The swap lock protects against this.

Now that we always keep the swap cache intact in mm/vmscan.c and only
reclaim it in mm/filemap.c, we might in fact be safe omiting the swap
lock.  I'd be nervous about it without a _thorough_ audit of the code,
though, as this particular race is hard to reproduce.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

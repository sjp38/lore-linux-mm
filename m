Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA06248
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 18:06:03 -0500
Date: Mon, 16 Nov 1998 23:05:56 GMT
Message-Id: <199811162305.XAA07996@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: unexpected paging during large file reads in 2.1.127
In-Reply-To: <Pine.LNX.3.96.981116214348.26465A-100000@mirkwood.dummy.home>
References: <199811161959.TAA07259@dax.scot.redhat.com>
	<Pine.LNX.3.96.981116214348.26465A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "David J. Fred" <djf@ic.net>, linux-kernel@vger.rutgers.edu, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 16 Nov 1998 21:48:35 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Mon, 16 Nov 1998, Stephen C. Tweedie wrote:
>> The real cure is to disable page aging in the page cache completely.
>> Now that we have disabled it for swap, it makes absolutely no sense at
>> all to keep it in the page cache.

> This is not entirely true. There is a major difference
> between pages in the page cache and pages that can go
> into swap. The latter kind will always be mapped inside
> the address space of a program (where it gets proper
> aging and stuff)

No it doesn't, that's what I'm saying.  Linus removed swap page aging in
the recent kernels.  That throws the balance between swap and cache
completely out of the window: removing the page cache aging is necessary
to restore balance.  There are many many reports of massive cache growth
on the latest kernels as a result of this.

> Now we can get severe problems with readahead when we
> are evicting just read-in data because it isn't mapped,

No, we don't.  We don't evict just-read-in data, because we mark such
pages as PG_Referenced.  It takes two complete shrink_mmap() passes
before we can evict such pages.

> resulting in us having to read it again and doing double
> I/O with a badly performing program.

The reason why this used to happen was because the readahead failed to
mark the new page as PG_Referenced.  I've been saying for _months_ that
the right fix was to mark them referenced rather than to do page aging
(and all of my benchmarks, without exception, back this up).  

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

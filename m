Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA32377
	for <linux-mm@kvack.org>; Wed, 2 Dec 1998 12:35:38 -0500
Date: Wed, 2 Dec 1998 17:35:26 GMT
Message-Id: <199812021735.RAA04489@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] swapin readahead
In-Reply-To: <Pine.LNX.3.96.981201192554.4046A-100000@mirkwood.dummy.home>
References: <87vhjvkccu.fsf@atlas.CARNet.hr>
	<Pine.LNX.3.96.981201192554.4046A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 1 Dec 1998 19:32:52 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> I took the bet that shrink_mmap() would take care of that, but
> aperrantly not always :(

shrink_mmap() only gets rid of otherwise unused pages (pages whose count
is one).  After read_swap_cache_async(), the page count will be three:
once for the swap cache, once for the io in progress, once for the
reference returned by read_swap_cache_async().  You need to free that
last reference explicitly after doing the readahead call.  The io
reference will be returned once IO completes, and shrink_mmap() will
take care of the final swap cache reference.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

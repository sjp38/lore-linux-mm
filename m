Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 56FB36B01F1
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 16:10:08 -0400 (EDT)
Date: Mon, 15 Mar 2010 13:09:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
 pressure
Message-Id: <20100315130935.f8b0a2d7.akpm@linux-foundation.org>
In-Reply-To: <4B9E296A.2010605@linux.vnet.ibm.com>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
	<20100311154124.e1e23900.akpm@linux-foundation.org>
	<4B99E19E.6070301@linux.vnet.ibm.com>
	<20100312020526.d424f2a8.akpm@linux-foundation.org>
	<20100312104712.GB18274@csn.ul.ie>
	<4B9A3049.7010602@linux.vnet.ibm.com>
	<20100312093755.b2393b33.akpm@linux-foundation.org>
	<4B9E296A.2010605@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 2010 13:34:50 +0100
Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:

> c) If direct reclaim did reasonable progress in try_to_free but did not
> get a page, AND there is no write in flight at all then let it try again
> to free up something.
> This could be extended by some kind of max retry to avoid some weird
> looping cases as well.
> 
> d) Another way might be as easy as letting congestion_wait return
> immediately if there are no outstanding writes - this would keep the 
> behavior for cases with write and avoid the "running always in full 
> timeout" issue without writes.

They're pretty much equivalent and would work.  But there are two
things I still don't understand:

1: Why is direct reclaim calling congestion_wait() at all?  If no
writes are going on there's lots of clean pagecache around so reclaim
should trivially succeed.  What's preventing it from doing so?

2: This is, I think, new behaviour.  A regression.  What caused it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id AB5A36B0005
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 00:12:00 -0500 (EST)
Received: by mail-da0-f46.google.com with SMTP id p5so2480699dak.5
        for <linux-mm@kvack.org>; Sun, 03 Feb 2013 21:11:59 -0800 (PST)
Date: Sun, 3 Feb 2013 21:12:05 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: boot warnings due to swap: make each swap partition have one
 address_space
In-Reply-To: <20130130095944.GA11457@kernel.org>
Message-ID: <alpine.LNX.2.00.1302032056550.4662@eggly.anvils>
References: <5101FFF5.6030503@oracle.com> <20130125042512.GA32017@kernel.org> <alpine.LNX.2.00.1301261754530.7300@eggly.anvils> <20130127141253.GA27019@kernel.org> <alpine.LNX.2.00.1301271321500.16981@eggly.anvils> <20130130095944.GA11457@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 30 Jan 2013, Shaohua Li wrote:
> On Sun, Jan 27, 2013 at 01:40:40PM -0800, Hugh Dickins wrote:
> > 
> > I'm glad Minchan has now pointed you to Rik's posting of two years ago:
> > I think there are more important changes to be made in that direction.
> 
> Not sure how others use multiple swaps, but current lock contention forces us
> to use multiple swaps. I haven't carefully think about Rik's posting, but looks
> it doesn't solve the lock contention problem.

Nobody had reported any swap lock contention problem before your patch,
so no, Rik's posting wasn't directed at that.  I always thought swap
writing patterns a much bigger problem.

But if lock contention there is, then I think it can be implemented
with reducing that in mind.  There are two levels of allocation: one
to allocate the tokens which we will insert in page tables, and one
to allocate the final diskspace to which those tokens will point.

(I may be using totally different language from Rik,
it's the principles that I have in mind, not his actual posting.)

Allocating the tokens can very well be done with per-cpu batches,
perhaps of SWAP_CLUSTER_MAX 32 to match vmscan.c's batching: there
is no significance to their ordering.  And allocating the diskspace
would want to be done in batches, to maximize contiguous writing.

That may not solve all the swap_info_get() contention which you saw,
but should help some.

I'm thinking that we go with your per-swapper-space locking for now;
but I wouldn't mind taking it out again later, if we arrive at a
better solution which benefits even those with a single swap area.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

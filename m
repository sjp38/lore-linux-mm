Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id ACBA86B006C
	for <linux-mm@kvack.org>; Tue,  1 Jan 2013 12:52:29 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 1 Jan 2013 12:52:28 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 32ACC6E803A
	for <linux-mm@kvack.org>; Tue,  1 Jan 2013 12:52:23 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r01HqNdF30867472
	for <linux-mm@kvack.org>; Tue, 1 Jan 2013 12:52:23 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r01HqNon028829
	for <linux-mm@kvack.org>; Tue, 1 Jan 2013 12:52:23 -0500
Message-ID: <50E32255.60901@linux.vnet.ibm.com>
Date: Tue, 01 Jan 2013 11:52:21 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>> <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>> <0e91c1e5-7a62-4b89-9473-09fff384a334@default>
In-Reply-To: <0e91c1e5-7a62-4b89-9473-09fff384a334@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 12/31/2012 05:06 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: [PATCH 7/8] zswap: add to mm/
>>
>> zswap is a thin compression backend for frontswap. It receives
>> pages from frontswap and attempts to store them in a compressed
>> memory pool, resulting in an effective partial memory reclaim and
>> dramatically reduced swap device I/O.
> 
> Hi Seth --
> 
> Happy (almost) New Year!

You too :)  Thanks for taking a look at the code.

> I am eagerly studying one of the details of your zswap "flush"
> code in this patch to see how you solved a problem or two that
> I was struggling with for the similar mechanism RFC'ed for zcache
> (see https://lkml.org/lkml/2012/10/3/558).  I like the way
> that you force the newly-uncompressed to-be-flushed page immediately
> into a swap bio in zswap_flush_entry via the call to swap_writepage,
> though I'm not entirely convinced that there aren't some race
> conditions there.  However, won't swap_writepage simply call
> frontswap_store instead and re-compress the page back into zswap?

I break part of swap_writepage() into a bottom half called
__swap_writepage() that doesn't include the call to frontswap_store().
__swap_writepage() is what is called from zswap_flush_entry().  That
is how I avoid flushed pages recycling back into zswap and the
potential recursion mentioned.

> A second related issue that concerns me is that, although you
> are now, like zcache2, using an LRU queue for compressed pages
> (aka "zpages"), there is no relationship between that queue and
> physical pageframes.  In other words, you may free up 100 zpages
> out of zswap via zswap_flush_entries, but not free up a single
> pageframe.  This seems like a significant design issue.  Or am
> I misunderstanding the code?

You understand correctly.  There is room for optimization here and it
is something I'm working on right now.

What I'm looking to do is give zswap a little insight into zsmalloc
internals, namely the ability figure out what class size a particular
allocation is in and, in the event the store can't be satisfied, flush
an entry from that exact class size so that we can be assured the
store will succeed with minimal flushing work.  In this solution,
there would be an LRU list per zsmalloc class size tracked in zswap.
The result is LRU-ish flushing overall with class size being the first
flush selection criteria and LRU as the second.

> A third concern is about scalability... the locking seems very
> coarse-grained.  In zcache, you personally observed and fixed
> hashbucket contention (see https://lkml.org/lkml/2011/9/29/215).
> Doesn't zswap's tree_lock essentially use a single tree (per
> swaptype), i.e. no scalability?

The reason the coarse lock isn't a problem for zswap like the hash
bucket locks where in zcache is that the lock is not held for long
periods time as it is in zcache.  It is only held while operating on
the tree, not during compression/decompression and larger memory
operations.

Also, I've done some lockstat checks and the zswap tree lock is way
down on the list contributing <1% of the lock contention wait time on
a 4-core system.  The anon_vma lock is the primary bottleneck.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

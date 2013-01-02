Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id AF4FB6B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 10:56:42 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 2 Jan 2013 10:56:41 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id CCC4AC9003C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 10:56:30 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r02FuT3p234894
	for <linux-mm@kvack.org>; Wed, 2 Jan 2013 10:56:30 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r02Fu7TS022531
	for <linux-mm@kvack.org>; Wed, 2 Jan 2013 13:56:08 -0200
Message-ID: <50E4588E.6080001@linux.vnet.ibm.com>
Date: Wed, 02 Jan 2013 07:55:58 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>> <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>> <0e91c1e5-7a62-4b89-9473-09fff384a334@default> <50E32255.60901@linux.vnet.ibm.com>
In-Reply-To: <50E32255.60901@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/01/2013 09:52 AM, Seth Jennings wrote:
> On 12/31/2012 05:06 PM, Dan Magenheimer wrote:
>> A second related issue that concerns me is that, although you
>> are now, like zcache2, using an LRU queue for compressed pages
>> (aka "zpages"), there is no relationship between that queue and
>> physical pageframes.  In other words, you may free up 100 zpages
>> out of zswap via zswap_flush_entries, but not free up a single
>> pageframe.  This seems like a significant design issue.  Or am
>> I misunderstanding the code?
> 
> You understand correctly.  There is room for optimization here and it
> is something I'm working on right now.

It's the same "design issue" that the slab shrinkers have, and they are
likely to have some substantially consistently smaller object sizes.

>> A third concern is about scalability... the locking seems very
>> coarse-grained.  In zcache, you personally observed and fixed
>> hashbucket contention (see https://lkml.org/lkml/2011/9/29/215).
>> Doesn't zswap's tree_lock essentially use a single tree (per
>> swaptype), i.e. no scalability?
> 
> The reason the coarse lock isn't a problem for zswap like the hash
> bucket locks where in zcache is that the lock is not held for long
> periods time as it is in zcache.  It is only held while operating on
> the tree, not during compression/decompression and larger memory
> operations.

Lock hold times don't often dominate lock cost these days.  The limiting
factor tends to be the cost of atomic operations to bring the cacheline
over to the CPUs acquiring the lock.

> Also, I've done some lockstat checks and the zswap tree lock is way
> down on the list contributing <1% of the lock contention wait time on
> a 4-core system.  The anon_vma lock is the primary bottleneck.

4 cores these days is awfully small.  Some of our fellow colleagues at
IBM might be a _bit_ concerned if we told them that we were using a
4-core non-NUMA system and extrapolating lock contention from there. :)

It's curious that you chose the anon_vma lock, though.  It can only
possibly show _contention_ when you've got a bunch of CPUs beating on
the related VMAs.  That contention disappears in workloads that aren't
threaded, so it seems at least a bit imprecise to say anon_vma lock is
the primary bottleneck.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

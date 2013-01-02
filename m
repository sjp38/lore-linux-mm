Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 97DED6B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 18:25:53 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 2 Jan 2013 18:25:52 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8795938C801C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 18:25:49 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r02NPnZI330204
	for <linux-mm@kvack.org>; Wed, 2 Jan 2013 18:25:49 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r02NPmHZ025689
	for <linux-mm@kvack.org>; Wed, 2 Jan 2013 21:25:48 -0200
Message-ID: <50E4C1FA.4070701@linux.vnet.ibm.com>
Date: Wed, 02 Jan 2013 17:25:46 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>> <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>> <0e91c1e5-7a62-4b89-9473-09fff384a334@default> <50E32255.60901@linux.vnet.ibm.com> <26bb76b3-308e-404f-b2bf-3d19b28b393a@default>
In-Reply-To: <26bb76b3-308e-404f-b2bf-3d19b28b393a@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Dave Hansen <dave@linux.vnet.ibm.com>

On 01/02/2013 11:08 AM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: Re: [PATCH 7/8] zswap: add to mm/
>>
>>> I am eagerly studying one of the details of your zswap "flush"
>>> code in this patch to see how you solved a problem or two that
>>> I was struggling with for the similar mechanism RFC'ed for zcache
>>> (see https://lkml.org/lkml/2012/10/3/558).  I like the way
>>> that you force the newly-uncompressed to-be-flushed page immediately
>>> into a swap bio in zswap_flush_entry via the call to swap_writepage,
>>> though I'm not entirely convinced that there aren't some race
>>> conditions there.  However, won't swap_writepage simply call
>>> frontswap_store instead and re-compress the page back into zswap?
>>
>> I break part of swap_writepage() into a bottom half called
>> __swap_writepage() that doesn't include the call to frontswap_store().
>> __swap_writepage() is what is called from zswap_flush_entry().  That
>> is how I avoid flushed pages recycling back into zswap and the
>> potential recursion mentioned.
> 
> OK, I missed that.  Nice.  I will see if I can use the
> same with zcache and, if so, would be happy to support
> the change to swap_writepage.
> 
> In your next version, maybe you could break out that chunk
> into a separate distinct patch so it can be pulled separately
> into Andrew's tree?

Sure.

>>> A second related issue that concerns me is that, although you
>>> are now, like zcache2, using an LRU queue for compressed pages
>>> (aka "zpages"), there is no relationship between that queue and
>>> physical pageframes.  In other words, you may free up 100 zpages
>>> out of zswap via zswap_flush_entries, but not free up a single
>>> pageframe.  This seems like a significant design issue.  Or am
>>> I misunderstanding the code?
>>
>> You understand correctly.  There is room for optimization here and it
>> is something I'm working on right now.
>>
>> What I'm looking to do is give zswap a little insight into zsmalloc
>> internals,
> 
> Not to be at all snide, but had you been as eager to break
> the zsmalloc abstraction last spring, a lot of unpleasantness
> and extra work might have been avoided. :v(

Well _some_ of it could have been avoided.

I'm putting at lot of thought into how to do it cleanly, while
maintaining the generic nature of zsmalloc.  I did a PoC already, but
I wasn't comfortable with how much had to be exposed to achieve it.
So I'm still working on it.

>> namely the ability figure out what class size a particular
>> allocation is in and, in the event the store can't be satisfied, flush
>> an entry from that exact class size so that we can be assured the
>> store will succeed with minimal flushing work.  In this solution,
>> there would be an LRU list per zsmalloc class size tracked in zswap.
>> The result is LRU-ish flushing overall with class size being the first
>> flush selection criteria and LRU as the second.
> 
> Clever and definitely useful, though I think there are two related
> problems and IIUC this solves only one of them.  The problem it _does_
> solve is (A) where to put a new zpage: Move a zpage from the same
> class to real-swap-disk and then fill its slot with the new zpage.
> The problem it _doesn't_ solve is (B) how to shrink the total number
> of pageframes used by zswap, even by a single page.  I believe
> (though cannot prove right now) that this latter problem will
> need to be solved to implement any suitable MM policy for balancing
> pages-used-for-compression vs pages-not-used-for-compression.
>
> I fear that problem (B) is the fundamental concern with
> using a high-density storage allocator such as zsmalloc, which
> is why I abandoned zsmalloc in favor of a more-predictable-but-
> less-dense allocator (zbud).  However, if you have a solution
> for (B) as well, I would gladly abandon zbud in zcache (for _both_
> cleancache and frontswap pages) and our respective in-kernel
> compression efforts would be more easy to merge into one solution
> in the future.

The only difference afaict between zbud and zsmalloc wrt vacating a
page frame is that zbud will only ever need to write back two pages to
swap where zsmalloc might have to write back more to free up the
zspage that contains the page frame to be vacated.  This is doable
with zsmalloc.  The question that remains for me is how cleanly can it
be done (for either approach).

>>> A third concern is about scalability... the locking seems very
>>> coarse-grained.  In zcache, you personally observed and fixed
>>> hashbucket contention (see https://lkml.org/lkml/2011/9/29/215).
>>> Doesn't zswap's tree_lock essentially use a single tree (per
>>> swaptype), i.e. no scalability?
>>
>> The reason the coarse lock isn't a problem for zswap like the hash
>> bucket locks where in zcache is that the lock is not held for long
>> periods time as it is in zcache.  It is only held while operating on
>> the tree, not during compression/decompression and larger memory
>> operations.
> 
> Hmmm... IIRC, to avoid races in zcache, it was necessary to
> update both the data (zpage) and meta-data ("tree" in zswap,
> and tmem-data-structure in zcache) atomically.  I will need
> to study your code more to understand how zswap avoids this
> requirement.  Or if it is obvious to you, I would be grateful
> if you would point it out to me.

Without the flushing mechanism, a simple lock guarding the tree was
enough in zswap.  The per-entry serialization of the
store/load/invalidate paths are all handled at a higher level.  For
example, we never get a load and invalidate concurrently on the same
swap entry.

However, once the flushing code was introduced and could free an entry
from the zswap_fs_store() path, it became necessary to add a per-entry
refcount to make sure that the entry isn't freed while another code
path was operating on it.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

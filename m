Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5E76B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 02:42:48 -0500 (EST)
Date: Wed, 27 Jan 2010 23:42:35 -0800 (PST)
From: Steve VanDeBogart <vandebo-lkml@NerdBox.Net>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
In-Reply-To: <20100126141229.e1a81b29.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.00.1001272319530.2909@abydos.NerdBox.Net>
References: <20100120215712.GO27212@frostnet.net> <20100126141229.e1a81b29.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Frost <frost@cs.ucla.edu>, Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 2010, Andrew Morton wrote:

> On Wed, 20 Jan 2010 13:57:12 -0800
> Chris Frost <frost@cs.ucla.edu> wrote:
>
>> In this patch find_get_page() is called for each page, which in turn
>> calls rcu_read_lock(), for each page. We have found that amortizing
>> these RCU calls, e.g., by introducing a variant of find_get_pages_contig()
>> that does not skip missing pages, can speedup the above microbenchmark
>> by 260x when querying many pages per system call. But we have not observed
>> noticeable improvements to our macrobenchmarks. I'd be happy to also post
>> this change or look further into it, but this seems like a reasonable
>> first patch, at least.
>
> I must say, the syscall appeals to my inner geek.  Lot of applications
> are leaving a lot of time on the floor due to bad disk access patterns.
> A really smart library which uses this facility could help all over
> the place.
>
> Is it likely that these changes to SQLite and Gimp would be merged into
> the upstream applications?

Changes to the GIMP fit nicely into the code structure, so it's feasible
to push this kind of optimization upstream.  The changes in SQLite are
a bit more focused on the benchmark, but a more general approach is not
conceptually difficult.  SQLite may not want the added complexity, but
other database may be interested in the performance improvement.

Of course, these kernel changes are needed before any application can
optimize its IO as we did with libprefetch.

>> +	if (pgoff >= file_npages || pgend > file_npages) {
>> +		retval = -EINVAL;
>> +		goto done;
>> +	}
>
> Should this return -EINVAL, or should it just return "0": nothing there?
>
> Bear in mind that this code is racy against truncate (I think?), and
> this is "by design".  If that race does occur, we want to return
> something graceful to userspace and I suggest that "nope, nothing
> there" is a more graceful result that "erk, you screwed up".  Because
> the application _didn't_ screw up: the pages were there when the
> syscall was first performed.

That's a good point.  Not in core seems like the right answer for 
pgoff >= file_npages.

--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

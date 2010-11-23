Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC406B008C
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 11:19:54 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oANG1nP8001323
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 11:02:13 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3F33572804D
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 11:19:45 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oANGJiBa015140
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 11:19:44 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oANGJinp026714
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 11:19:44 -0500
Subject: Re: Sudden and massive page cache eviction
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com>
	 <20101122161158.02699d10.akpm@linux-foundation.org>
	 <1290501502.2390.7029.camel@nimitz>
	 <AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 23 Nov 2010 08:19:31 -0800
Message-ID: <1290529171.2390.7994.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Peter =?ISO-8859-1?Q?Sch=FCller?= <scode@spotify.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-11-23 at 10:44 +0100, Peter Schuller wrote:
> > You don't have anybody messing with /proc/sys/vm/drop_caches, do you?
> 
> Highly unlikely given that (1) evictions, while often very
> significant, are usually not *complete* (although the first graph
> example I provided had a more or less complete eviction) and (2) the
> evictions are not obviously periodic indicating some kind of cron job,
> and (3) we see the evictions happening across a wide variety of
> machines.
> 
> So yes, I feel confident that we are not accidentally doing that.

Yeah, drop_caches doesn't seem very likely.

Your postgres data looks the cleanest and is probably the easiest to
analyze.  Might as well start there:

	http://files.spotify.com/memcut/postgresql_weekly.png

As you said, it might not be the same as the others, but it's a decent
place to start.  If someone used drop_caches or if someone was randomly
truncating files, we'd expect to see the active/inactive lines both drop
by relatively equivalent amounts, and see them happen at _exactly_ the
same time as the cache eviction.  The eviction about 1/3 of the way
through Wednesday in the above graph kinda looks this way, but it's the
exception.

Just eyeballing it, _most_ of the evictions seem to happen after some
movement in the active/inactive lists.  We see an "inactive" uptick as
we start to launder pages, and the page activation doesn't keep up with
it.  This is a _bit_ weird since we don't see any slab cache or other
users coming to fill the new space.  Something _wanted_ the memory, so
why isn't it being used?

Do you have any large page (hugetlbfs) or other multi-order (> 1 page)
allocations happening in the kernel?  

If you could start recording /proc/{vmstat,buddystat,meminfo,slabinfo},
it would be immensely useful.  The munin graphs are really great, but
they don't have the detail which you can get from stuff like vmstat.

> Further, we have observed the kernel's unwillingness to retain data in
> page cache under interesting circumstances:
> 
> (1) page cache eviction happens
> (2) we warm up our BDB files by cat:ing them (simple but effective)
> (3) within a matter of minutes, while there is still several GB of
> free (truly free, not page cached), these are evicted (as evidenced by
> re-cat:ing them a little while later)
>
> This latest observation we understand may be due to NUMA related
> allocation issues, and we should probably try to use numactl to ask
> for a more even allocation. We have not yet tried this. However, it is
> not clear how any issues having to do with that would cause sudden
> eviction of data already *in* the page cache (on whichever node)..

For a page-cache-heavy workload where you care a lot more about things
being _in_ cache rather than having good NUMA locality, you probably
want "zone_reclaim_mode" set to 0:

	http://www.kernel.org/doc/Documentation/sysctl/vm.txt

That'll be a bit more comprehensive than messing with numactl.  It
really is the best thing if you just don't care about NUMA latencies all
that much.  What kind of hardware is this, btw?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

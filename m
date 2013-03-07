Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 6E1FB6B0005
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 10:43:18 -0500 (EST)
Date: Thu, 7 Mar 2013 16:43:12 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: mmap vs fs cache
Message-ID: <20130307154312.GG6723@quack.suse.cz>
References: <5136320E.8030109@symas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5136320E.8030109@symas.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Howard Chu <hyc@symas.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

  Added mm list to CC.

On Tue 05-03-13 09:57:34, Howard Chu wrote:
> I'm testing our memory-mapped database code on a small VM. The
> machine has 32GB of RAM and the size of the DB on disk is ~44GB. The
> database library mmaps the entire file as a single region and starts
> accessing it as a tree of B+trees. Running on an Ubuntu 3.5.0-23
> kernel, XFS on a local disk.
> 
> If I start running read-only queries against the DB with a freshly
> started server, I see that my process (OpenLDAP slapd) quickly grows
> to an RSS of about 16GB in tandem with the FS cache. (I.e., "top"
> shows 16GB cached, and slapd is 16GB.)
> If I confine my queries to the first 20% of the data then it all
> fits in RAM and queries are nice and fast.
> 
> if I extend the query range to cover more of the data, approaching
> the size of physical RAM, I see something strange - the FS cache
> keeps growing, but the slapd process size grows at a slower rate.
> This is rather puzzling to me since the only thing triggering reads
> is accesses through the mmap region. Eventually the FS cache grows
> to basically all of the 32GB of RAM (+/- some text/data space...)
> but the slapd process only reaches 25GB, at which point it actually
> starts to shrink - apparently the FS cache is now stealing pages
> from it. I find that a bit puzzling; if the pages are present in
> memory, and the only reason they were paged in was to satisfy an
> mmap reference, why aren't they simply assigned to the slapd
> process?
> 
> The current behavior gets even more aggravating: I can run a test
> that spans exactly 30GB of the data. One would expect that the slapd
> process should simply grow to 30GB in size, and then remain static
> for the remainder of the test. Instead, the server grows to 25GB,
> the FS cache grows to 32GB, and starts stealing pages from the
> server, shrinking it back down to 19GB or so.
> 
> If I do an "echo 1 > /proc/sys/vm/drop_caches" at the onset of this
> condition, the FS cache shrinks back to 25GB, matching the slapd
> process size.
> This then frees up enough RAM for slapd to grow further. If I don't
> do this, the test is constantly paging in data from disk. Even so,
> the FS cache continues to grow faster than the slapd process size,
> so the system may run out of free RAM again, and I have to drop
> caches multiple times before slapd finally grows to the full 30GB.
> Once it gets to that size the test runs entirely from RAM with zero
> I/Os, but it doesn't get there without a lot of babysitting.
> 
> 2 questions:
>   why is there data in the FS cache that isn't owned by (the mmap
> of) the process that caused it to be paged in in the first place?
>   is there a tunable knob to discourage the page cache from stealing
> from the process?
> 
> -- 
>   -- Howard Chu
>   CTO, Symas Corp.           http://www.symas.com
>   Director, Highland Sun     http://highlandsun.com/hyc/
>   Chief Architect, OpenLDAP  http://www.openldap.org/project/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

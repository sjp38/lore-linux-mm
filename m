Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 7CB4E6B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 16:10:39 -0500 (EST)
Date: Wed, 11 Jan 2012 22:10:31 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 -mm] make swapin readahead skip over holes
Message-ID: <20120111205041.GE24386@cmpxchg.org>
References: <20120111143044.3c538d46@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120111143044.3c538d46@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, minchan.kim@gmail.com

On Wed, Jan 11, 2012 at 02:30:44PM -0500, Rik van Riel wrote:
> Ever since abandoning the virtual scan of processes, for scalability
> reasons, swap space has been a little more fragmented than before.
> This can lead to the situation where a large memory user is killed,
> swap space ends up full of "holes" and swapin readahead is totally
> ineffective.
> 
> On my home system, after killing a leaky firefox it took over an
> hour to page just under 2GB of memory back in, slowing the virtual
> machines down to a crawl.
> 
> This patch makes swapin readahead simply skip over holes, instead
> of stopping at them.  This allows the system to swap things back in
> at rates of several MB/second, instead of a few hundred kB/second.
> 
> The checks done in valid_swaphandles are already done in 
> read_swap_cache_async as well, allowing us to remove a fair amount
> of code.

__swap_duplicate() also checks for whether the offset is within the
swap device range.  Do you think we could remove get_swap_cluster()
altogether and just try reading the aligned page_cluster range?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

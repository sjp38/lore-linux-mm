Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6C57B6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 18:08:38 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so7702427pad.14
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:08:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tq5si22220566pac.8.2014.02.03.15.08.37
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 15:08:37 -0800 (PST)
Date: Mon, 3 Feb 2014 15:08:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/zswap: add writethrough option
Message-Id: <20140203150835.f55fd427d0ebb0c2943f266b@linux-foundation.org>
In-Reply-To: <1390831279-5525-1-git-send-email-ddstreet@ieee.org>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
	<1390831279-5525-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

On Mon, 27 Jan 2014 09:01:19 -0500 Dan Streetman <ddstreet@ieee.org> wrote:

> Currently, zswap is writeback cache; stored pages are not sent
> to swap disk, and when zswap wants to evict old pages it must
> first write them back to swap cache/disk manually.  This avoids
> swap out disk I/O up front, but only moves that disk I/O to
> the writeback case (for pages that are evicted), and adds the
> overhead of having to uncompress the evicted pages and the
> need for an additional free page (to store the uncompressed page).
> 
> This optionally changes zswap to writethrough cache by enabling
> frontswap_writethrough() before registering, so that any
> successful page store will also be written to swap disk.  The
> default remains writeback.  To enable writethrough, the param
> zswap.writethrough=1 must be used at boot.
> 
> Whether writeback or writethrough will provide better performance
> depends on many factors including disk I/O speed/throughput,
> CPU speed(s), system load, etc.  In most cases it is likely
> that writeback has better performance than writethrough before
> zswap is full, but after zswap fills up writethrough has
> better performance than writeback.
> 
> The reason to add this option now is, first to allow any zswap
> user to be able to test using writethrough to determine if they
> get better performance than using writeback, and second to allow
> future updates to zswap, such as the possibility of dynamically
> switching between writeback and writethrough.
> 
> ...
>
> Based on specjbb testing on my laptop, the results for both writeback
> and writethrough are better than not using zswap at all, but writeback
> does seem to be better than writethrough while zswap isn't full.  Once
> it fills up, performance for writethrough is essentially close to not
> using zswap, while writeback seems to be worse than not using zswap.
> However, I think more testing on a wider span of systems and conditions
> is needed.  Additionally, I'm not sure that specjbb is measuring true
> performance under fully loaded cpu conditions, so additional cpu load
> might need to be added or specjbb parameters modified (I took the
> values from the 4 "warehouses" test run).
> 
> In any case though, I think having writethrough as an option is still
> useful.  More changes could be made, such as changing from writeback
> to writethrough based on the zswap % full.  And the patch doesn't
> change default behavior - writethrough must be specifically enabled.
> 
> The %-ized numbers I got from specjbb on average, using the default
> 20% max_pool_percent and varying the amount of heap used as shown:
> 
> ram | no zswap | writeback | writethrough
> 75     93.08     100         96.90
> 87     96.58     95.58       96.72
> 100    92.29     89.73       86.75
> 112    63.80     38.66       19.66
> 125    4.79      29.90       15.75
> 137    4.99      4.50        4.75
> 150    4.28      4.62        5.01
> 162    5.20      2.94        4.66
> 175    5.71      2.11        4.84

Changelog is very useful, thanks for taking the time.

It does sound like the feature is of marginal benefit.  Is "zswap
filled up" an interesting or useful case to optimize?

otoh the addition is pretty simple and we can later withdraw the whole
thing without breaking anyone's systems.

What do people think?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

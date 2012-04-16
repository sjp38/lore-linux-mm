Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D79C16B0105
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 14:22:12 -0400 (EDT)
Received: by lagz14 with SMTP id z14so5428464lag.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 11:22:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201204111557.14153.arnd@arndb.de>
References: <201203301744.16762.arnd@arndb.de>
	<201204100832.52093.arnd@arndb.de>
	<20120411095418.GA2228@barrios>
	<201204111557.14153.arnd@arndb.de>
Date: Mon, 16 Apr 2012 12:22:10 -0600
Message-ID: <CAKL-ytsXbe4=u94PjqvhZo=ZLiChQ0FmZC84GNrFHa0N1mDjFw@mail.gmail.com>
Subject: Re: swap on eMMC and other flash
From: Stephan Uphoff <ups@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Minchan Kim <minchan@kernel.org>, linaro-kernel@lists.linaro.org, android-kernel@googlegroups.com, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>

I really like where this is going and would like to use the
opportunity to plant a few ideas.

In contrast to rotational disks read/write operation overhead and
costs are not symmetric.
While random reads are much faster on flash - the number of write
operations is limited by wearout and garbage collection overhead.
To further improve swapping on eMMC or similar flash media I believe
that the following issues need to be addressed:

1) Limit average write bandwidth to eMMC to a configurable level to
guarantee a minimum device lifetime
2) Aim for a low write amplification factor to maximize useable write bandwidth
3) Strongly favor read over write operations

Lowering write amplification (2) has been discussed in this email
thread - and the only observation I would like to add is that
over-provisioning the internal swap space compared to the exported
swap space significantly can guarantee a lower write amplification
factor with the indirection and GC techniques discussed.

I believe the swap functionality is currently optimized for storage
media where read and write costs are nearly identical.
As this is not the case on flash I propose splitting the anonymous
inactive queue (at least conceptually) - keeping clean anonymous pages
with swap slots on a separate queue as the cost of swapping them
out/in is only an inexpensive read operation. A variable similar to
swapiness (or a more dynamic algorithmn) could determine the
preference for swapping out clean pages or dirty pages. ( A similar
argument could be made for splitting up the file inactive queue )

The problem of limiting the average write bandwidth reminds me of
enforcing cpu utilization limits on interactive workloads.
Just as with cpu workloads - using the resources to the limit produces
poor interactivity.
When interactivity suffers too much I believe the only sane response
for an interactive device is to limit usage of the swap device and
transition into a low memory situation - and if needed - either
allowing userspace to reduce memory usage or invoking the OOM killer.
As a result low memory situations could not only be encountered on new
memory allocations but also on workload changes that increase the
number of dirty pages.

A wild idea to avoid some writes altogether is to see if
de-duplication techniques can be used to (partially?) match pages
previously written so swap.
In case of unencrypted swap  (or encrypted swap with a static key)
swap pages on eMMC could even be re-used across multiple reboots.
A simple version would just compare dirty pages with data in their
swap slots as I suspect (but really don't know) that some user space
algorithms (garbage collection?) dirty a page just temporarily -
eventually reverting it to the previous content.

Stephan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

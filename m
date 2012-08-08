Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 1F5E26B005A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 12:35:46 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 8 Aug 2012 12:35:06 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 322A538C81AD
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 12:29:42 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q78GTY1p148900
	for <linux-mm@kvack.org>; Wed, 8 Aug 2012 12:29:36 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q78GUfO3005420
	for <linux-mm@kvack.org>; Wed, 8 Aug 2012 10:30:41 -0600
Message-ID: <502293E2.8010505@linux.vnet.ibm.com>
Date: Wed, 08 Aug 2012 11:29:22 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com> <5021795A.5000509@linux.vnet.ibm.com> <3f8dfac9-2b92-442c-800a-f0bfef8a90cb@default>
In-Reply-To: <3f8dfac9-2b92-442c-800a-f0bfef8a90cb@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Kurt Hackel <kurt.hackel@oracle.com>

On 08/07/2012 04:47 PM, Dan Magenheimer wrote:
> I notice your original published benchmarks [1] include
> N=24, N=28, and N=32, but these updated results do not.  Are you planning
> on completing the runs?  Second, I now see the numbers I originally
> published for what I thought was the same benchmark as yours are actually
> an order of magnitude larger (in sec) than yours.  I didn't notice
> this in March because we were focused on the percent improvement, not
> the raw measurements.  Since the hardware is highly similar, I suspect
> it is not a hardware difference but instead that you are compiling
> a much smaller kernel.  In other words, your test case is much
> smaller, and so exercises zcache much less.  My test case compiles
> a full enterprise kernel... what is yours doing?

I am doing a minimal kernel build for my local hardware
configuration.

With the reduction in RAM, 1GB to 512MB, I didn't need to do
test runs with >20 threads to find the peak of the benefit
curve at 16 threads.  Past that, zcache is saturated and I'd
just be burning up my disk.  I'm already swapping out about
500MB (i.e. RAM size) in the 20 thread non-zcache case.

Also, I provide the magnitude numbers (pages, seconds) just
to show my source data.  The %change numbers are the real
results as they remove build size as a factor.

> At LSFMM, Andrea
> Arcangeli pointed out that zcache, for frontswap pages, has no "writeback"
> capabilities and, when it is full, it simply rejects further attempts
> to put data in its cache.  He said this is unacceptable for KVM and I
> agreed that it was a flaw that needed to be fixed before zcache should
> be promoted.

KVM (in-tree) is not a current user of zcache.  While the
use cases of possible future zcache users should be
considered, I don't think they can be used to prevent promotion.

> A second flaw is that the "demo" zcache has no concept of LRU for
> either cleancache or frontswap pages, or ability to reclaim pageframes
> at all for frontswap pages.
...
> 
> A third flaw is that the "demo" version has a very poor policy to
> determine what pages are "admitted".
...
> 
> I can add more issues to the list, but will stop here.

All of the flaws you list do not prevent zcache from being
beneficial right now, as my results demonstrate.  Therefore,
the flaws listed are really potential improvements and can
be done in mainline after promotion.  Even if large changes
are required to make these improvements, they can be made in
mainline in an incremental and public way.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

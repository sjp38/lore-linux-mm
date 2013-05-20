Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 1228F6B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 17:55:53 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 20 May 2013 17:55:51 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AEE8E6E8028
	for <linux-mm@kvack.org>; Mon, 20 May 2013 17:55:44 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4KLtlgV332120
	for <linux-mm@kvack.org>; Mon, 20 May 2013 17:55:47 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4KLtk2f025724
	for <linux-mm@kvack.org>; Mon, 20 May 2013 15:55:46 -0600
Date: Mon, 20 May 2013 16:55:42 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFCv2][PATCH 0/5] mm: Batch page reclamation under
 shink_page_list
Message-ID: <20130520215542.GC25536@cerebellum>
References: <20130516203427.E3386936@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130516203427.E3386936@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Thu, May 16, 2013 at 01:34:27PM -0700, Dave Hansen wrote:
> These are an update of Tim Chen's earlier work:
> 
> 	http://lkml.kernel.org/r/1347293960.9977.70.camel@schen9-DESK
> 
> I broke the patches up a bit more, and tried to incorporate some
> changes based on some feedback from Mel and Andrew.
> 
> Changes for v2:
>  * use page_mapping() accessor instead of direct access
>    to page->mapping (could cause crashes when running in
>    to swap cache pages.
>  * group the batch function's introduction patch with
>    its first use
>  * rename a few functions as suggested by Mel
>  * Ran some single-threaded tests to look for regressions
>    caused by the batching.  If there is overhead, it is only
>    in the worst-case scenarios, and then only in hundreths of
>    a percent of CPU time.
> 
> If you're curious how effective the batching is, I have a quick
> and dirty patch to keep some stats:
> 
> 	https://www.sr71.net/~dave/intel/rmb-stats-only.patch
>

Didn't do any performance comparison but did a kernel build with 2 make threads
per core in a memory constrained situation w/ zswap add got an average batch
size of 6.6 pages with the batch being empty on ~10% of calls.

rmb call:   423464
rmb pages:   2790332
rmb empty:   41408

The WARN_ONCE only gave me one stack for the first empty batch and, for what
it's worth, it was from kswapd.

Tested-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

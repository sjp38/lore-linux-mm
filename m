Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A25B86B0006
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:39:52 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Feb 2013 12:39:51 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 8CFECC9001B
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:39:47 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1PHdiPX25952418
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:39:45 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1PHbvc9001613
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 10:37:57 -0700
Message-ID: <512BA147.2090308@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2013 11:37:11 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 7/8] zswap: add swap page writeback support
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-8-git-send-email-sjenning@linux.vnet.ibm.com> <20130225025403.GB6498@blaptop>
In-Reply-To: <20130225025403.GB6498@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/24/2013 08:54 PM, Minchan Kim wrote:
> Hi Seth,
> 
> On Wed, Feb 13, 2013 at 12:38:50PM -0600, Seth Jennings wrote:
>> This patch adds support for evicting swap pages that are currently
>> compressed in zswap to the swap device.  This functionality is very
>> important and make zswap a true cache in that, once the cache is full
>> or can't grow due to memory pressure, the oldest pages can be moved
>> out of zswap to the swap device so newer pages can be compressed and
>> stored in zswap.
>>
>> This introduces a good amount of new code to guarantee coherency.
>> Most notably, and LRU list is added to the zswap_tree structure,
>> and refcounts are added to each entry to ensure that one code path
>> doesn't free then entry while another code path is operating on it.
>>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> In this time, I didn't review the code in detail yet but it seems
> resolve of all review point in previous interation. Thanks!
> But unfortunately, I couldn't find anything related to tmppage handling
> so I'd like to ask.
> 
> The reason of tmppage is temporal buffer to keep compressed data during
> writeback to avoid unnecessary compressing again when we retry?

Yes.

> Is it really critical about performance?

It's hard to measure.  There is no guarantee that
zswap_flush_entries() has made room for the allocation so if we fail
again, we've compressed the page twice and still fail

So my motivation was to prevent the second compression.  It does add
significant complexity though without a completely clear (i.e.
measurable) benefit.


What's the wrong if we remove
> tmppage handling?
> 
> zswap_frontswap_store
> retry:
>         get_cpu_var(zswap_dstmem);
>         zswap_com_op(COMPRESS)
>         zs_malloc()
>         if (!handle) {
>                 put_cpu_var(zswap_dstmem);
>                 if (retry > MAX_RETRY)
>                         goto error_nomem;
>                 zswap_flush_entries()
>                 goto retry;
>         }

I dislike "jump up" labels, but yes, something like this could be done.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

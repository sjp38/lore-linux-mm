Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C7BA56B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 21:54:05 -0500 (EST)
Date: Mon, 25 Feb 2013 11:54:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv5 7/8] zswap: add swap page writeback support
Message-ID: <20130225025403.GB6498@blaptop>
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1360780731-11708-8-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1360780731-11708-8-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Seth,

On Wed, Feb 13, 2013 at 12:38:50PM -0600, Seth Jennings wrote:
> This patch adds support for evicting swap pages that are currently
> compressed in zswap to the swap device.  This functionality is very
> important and make zswap a true cache in that, once the cache is full
> or can't grow due to memory pressure, the oldest pages can be moved
> out of zswap to the swap device so newer pages can be compressed and
> stored in zswap.
> 
> This introduces a good amount of new code to guarantee coherency.
> Most notably, and LRU list is added to the zswap_tree structure,
> and refcounts are added to each entry to ensure that one code path
> doesn't free then entry while another code path is operating on it.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

In this time, I didn't review the code in detail yet but it seems
resolve of all review point in previous interation. Thanks!
But unfortunately, I couldn't find anything related to tmppage handling
so I'd like to ask.

The reason of tmppage is temporal buffer to keep compressed data during
writeback to avoid unnecessary compressing again when we retry?
Is it really critical about performance? What's the wrong if we remove
tmppage handling?

zswap_frontswap_store
retry:
        get_cpu_var(zswap_dstmem);
        zswap_com_op(COMPRESS)
        zs_malloc()
        if (!handle) {
                put_cpu_var(zswap_dstmem);
                if (retry > MAX_RETRY)
                        goto error_nomem;
                zswap_flush_entries()
                goto retry;
        }


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 087B76B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 19:43:05 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wm4so5607451obc.38
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 16:43:05 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id sy1si18122765obc.12.2013.11.20.16.43.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 16:43:04 -0800 (PST)
Message-ID: <528D570D.3020006@oracle.com>
Date: Thu, 21 Nov 2013 08:42:53 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/zswap: change zswap to writethrough cache
References: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

Hi Dan,

On 11/21/2013 03:49 AM, Dan Streetman wrote:
> Currently, zswap is writeback cache; stored pages are not sent
> to swap disk, and when zswap wants to evict old pages it must
> first write them back to swap cache/disk manually.  This avoids
> swap out disk I/O up front, but only moves that disk I/O to
> the writeback case (for pages that are evicted), and adds the
> overhead of having to uncompress the evicted pages, and adds the
> need for an additional free page (to store the uncompressed page)
> at a time of likely high memory pressure.  Additionally, being
> writeback adds complexity to zswap by having to perform the
> writeback on page eviction.
> 

Good work!

> This changes zswap to writethrough cache by enabling
> frontswap_writethrough() before registering, so that any
> successful page store will also be written to swap disk.  All the
> writeback code is removed since it is no longer needed, and the
> only operation during a page eviction is now to remove the entry
> from the tree and free it.
> 

Could you do some testing using eg. SPECjbb? And compare the result with
original zswap.

Thanks,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

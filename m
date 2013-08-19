Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 7A6706B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 13:00:00 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Mon, 19 Aug 2013 17:59:59 +0100
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 264FB6E8048
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 12:59:50 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7JGxtLc208638
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 12:59:55 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7JGxrIa022804
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 12:59:55 -0400
Date: Mon, 19 Aug 2013 11:59:48 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] mm: zswap: add supporting for zsmalloc
Message-ID: <20130819165948.GA5703@variantweb.net>
References: <1376815249-6611-1-git-send-email-bob.liu@oracle.com>
 <1376815249-6611-4-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376815249-6611-4-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, eternaleye@gmail.com, minchan@kernel.org, mgorman@suse.de, gregkh@linuxfoundation.org, akpm@linux-foundation.org, axboe@kernel.dk, ngupta@vflare.org, semenzato@google.com, penberg@iki.fi, sonnyrao@google.com, smbarber@google.com, konrad.wilk@oracle.com, riel@redhat.com, kmpark@infradead.org, Bob Liu <bob.liu@oracle.com>

On Sun, Aug 18, 2013 at 04:40:48PM +0800, Bob Liu wrote:
> Make zswap can use zsmalloc as its allocater.
> But note that zsmalloc don't reclaim any zswap pool pages mandatory, if zswap
> pool gets full, frontswap_store will be refused unless frontswap_get happened
> and freed some space.
> 
> The reason of don't implement reclaiming zsmalloc pages from zswap pool is there
> is no requiremnet currently.
> If we want to do mandatory reclaim, we have to write those pages to real backend
> swap devices. But most of current users of zsmalloc are from embeded world,
> there is even no real backend swap device.
> This action is also the same as privous zram!
> 
> For several area, zsmalloc has unpredictable performance characteristics when
> reclaiming a single page, then CONFIG_ZBUD are suggested.

Looking at this patch on its own, it does show how simple it could be
for zswap to support zsmalloc.  So thanks!

However, I don't like all the ifdefs scattered everywhere.  I'd like to
have a ops structure (e.g. struct zswap_alloc_ops) instead and just
switch ops based on the CONFIG flag.  Or better yet, have it boot-time
selectable instead of build-time.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

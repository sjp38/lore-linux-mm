Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 57C446B0035
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 00:34:27 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id e14so3913788iej.39
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 21:34:27 -0700 (PDT)
Received: from psmtp.com ([74.125.245.115])
        by mx.google.com with SMTP id x1si5885228igr.37.2013.10.30.21.34.26
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 21:34:26 -0700 (PDT)
Date: Wed, 30 Oct 2013 21:35:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: __rmqueue_fallback() should respect pageblock type
Message-Id: <20131030213537.f346d751.akpm@linux-foundation.org>
In-Reply-To: <1383193489-27331-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1383193489-27331-1-git-send-email-kosaki.motohiro@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>

On Thu, 31 Oct 2013 00:24:49 -0400 kosaki.motohiro@gmail.com wrote:

> When __rmqueue_fallback() don't find out a free block with the same size
> of required, it splits a larger page and puts back rest peiece of the page
> to free list.
> 
> But it has one serious mistake. When putting back, __rmqueue_fallback()
> always use start_migratetype if type is not CMA. However, __rmqueue_fallback()
> is only called when all of start_migratetype queue are empty. That said,
> __rmqueue_fallback always put back memory to wrong queue except
> try_to_steal_freepages() changed pageblock type (i.e. requested size is
> smaller than half of page block). Finally, antifragmentation framework
> increase fragmenation instead of decrease.
> 
> Mel's original anti fragmentation do the right thing. But commit 47118af076
> (mm: mmzone: MIGRATE_CMA migration type added) broke it.
> 
> This patch restores sane and old behavior.

What are the user-visible runtime effects of this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

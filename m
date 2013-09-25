Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id DD6C76B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 04:09:07 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so5797563pdi.27
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 01:09:07 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id u16so10338518iet.11
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 01:09:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130821074939.GE3022@bbox>
References: <CAL1ERfOiT7QV4UUoKi8+gwbHc9an4rUWriufpOJOUdnTYHHEAw@mail.gmail.com>
	<52118042.30101@oracle.com>
	<20130819054742.GA28062@bbox>
	<CAL1ERfN3AUYwWTctGBjVcgb-mwAmc15-FayLz48P1d0GzogncA@mail.gmail.com>
	<20130821074939.GE3022@bbox>
Date: Wed, 25 Sep 2013 16:09:04 +0800
Message-ID: <CAL1ERfP70oz=tbVEAfDhgNzgLsvnpbWeOCPOMBpmKTUn0v_Lfg@mail.gmail.com>
Subject: Re: [BUG REPORT] ZSWAP: theoretical race condition issues
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Bob Liu <bob.liu@oracle.com>, sjenning@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I think I find a new issue, for integrity of this mail thread, I reply
to this mail.

It is a concurrence issue either, when duplicate store and reclaim
concurrentlly.

zswap entry x with offset A is already stored in zswap backend.
Consider the following scenario:

thread 0: reclaim entry x (get refcount, but not call zswap_get_swap_cache_page)

thread 1: store new page with the same offset A, alloc a new zswap entry y.
  store finished. shrink_page_list() call __remove_mapping(), and now
it is not in swap_cache

thread 0: zswap_get_swap_cache_page called. old page data is added to swap_cache

Now, swap cache has old data rather than new data for offset A.
error will happen If do_swap_page() get page from swap_cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

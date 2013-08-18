Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id B3EC66B0032
	for <linux-mm@kvack.org>; Sun, 18 Aug 2013 12:14:46 -0400 (EDT)
Received: by mail-ob0-f193.google.com with SMTP id dn14so1614045obc.8
        for <linux-mm@kvack.org>; Sun, 18 Aug 2013 09:14:45 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 19 Aug 2013 00:14:45 +0800
Message-ID: <CAL1ERfOiT7QV4UUoKi8+gwbHc9an4rUWriufpOJOUdnTYHHEAw@mail.gmail.com>
Subject: [BUG REPORT] ZSWAP: theoretical race condition issues
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.magenheimer@oracle.com, bob.liu@oracle.com

I found a few bugs in zswap when I review Linux-3.11-rc5, and I have
also some questions about it, described as following:

BUG:
1. A race condition when reclaim a page
when a handle alloced from zbud, zbud considers this handle is used
validly by upper(zswap) and can be a candidate for reclaim.
But zswap has to initialize it such as setting swapentry and addding
it to rbtree. so there is a race condition, such as:
thread 0: obtain handle x from zbud_alloc
thread 1: zbud_reclaim_page is called
thread 1: callback zswap_writeback_entry to reclaim handle x
thread 1: get swpentry from handle x (it is random value now)
thread 1: bad thing may happen
thread 0: initialize handle x with swapentry
Of course, this situation almost never happen, it is a "theoretical
race condition" issue.

2. Pollute swapcache data by add a pre-invalided swap page
when a swap_entry is invalidated, it will be reused by other anon
page. At the same time, zswap is reclaiming old page, pollute
swapcache of new page as a result, because old page and new page use
the same swap_entry, such as:
thread 1: zswap reclaim entry x
thread 0: zswap_frontswap_invalidate_page entry x
thread 0: entry x reused by other anon page
thread 1: add old data to swapcache of entry x
thread 0: swapcache of entry x is polluted
Of course, this situation almost never happen, it is another
"theoretical race condition" issue.

3. Frontswap uses frontswap_map bitmap to track page in "backend"
implementation, when zswap reclaim a
page, the corresponding bitmap record is not cleared.

4. zswap_tree is not freed when swapoff, and it got re-kzalloc in
swapon, memory leak occurs.

questions:
1. How about SetPageReclaim befor __swap_writepage, so that move it to
the tail of the inactive list?
2. zswap uses GFP_KERNEL flag to alloc things in store and reclaim
function, does this lead to these function called recursively?
3. for reclaiming one zbud page which contains two buddies, zswap
needs to alloc two pages. Does this reclaim cost-efficient?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

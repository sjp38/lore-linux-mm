Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id BD2D26B0034
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 13:56:03 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Fri, 23 Aug 2013 11:56:02 -0600
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id EAA85C90044
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 13:55:57 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7NHtxuS28639406
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 17:55:59 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7NHtx4e007052
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 13:55:59 -0400
Date: Fri, 23 Aug 2013 10:22:29 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] zswap bugfix: memory leaks and other problem
Message-ID: <20130823152229.GA5439@variantweb.net>
References: <CAL1ERfON5p1t_KskkQc_7u78Qk=kmy6nNyqsnDwriesTi2ubLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL1ERfON5p1t_KskkQc_7u78Qk=kmy6nNyqsnDwriesTi2ubLA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, weijie.yang@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 23, 2013 at 07:26:01PM +0800, Weijie Yang wrote:
> This patch series fix a few bugs in zswap based on Linux-3.11-rc6.
> 
> Corresponding mail thread see: lkml.org/lkml/2013/8/18/59 .
> 
> These issues fixed are:
>  1. memory leaks when re-swapon
>  2. potential problem which store and reclaim functions is called recursively
>  3. memory leaks when invalidate and reclaim occur simultaneously
>  4. unnecessary page scanning

Thanks for the patches!

Patches 2-4 have whitespace corruption (line wrapping) probably caused
by your mail agent.  You might check Documentation/email-clients.txt on
how to prevent this.

Seth

> 
> Issues discussed in that mail thread NOT fixed as it happens rarely or
> not a big problem:
>  1. a "theoretical race condition" when reclaim page
>  when a handle alloced from zbud, zbud considers this handle is used
> validly by upper(zswap) and can be a candidate for reclaim.
>  But zswap has to initialize it such as setting swapentry and adding
> it to rbtree. so there is a race condition, such as:
>  thread 0: obtain handle x from zbud_alloc
>  thread 1: zbud_reclaim_page is called
>  thread 1: callback zswap_writeback_entry to reclaim handle x
>  thread 1: get swpentry from handle x (it is random value now)
>  thread 1: bad thing may happen
>  thread 0: initialize handle x with swapentry
> 
> 2. frontswap_map bitmap not cleared after zswap reclaim
>  Frontswap uses frontswap_map bitmap to track page in "backend" implementation,
>  when zswap reclaim a page, the corresponding bitmap record is not cleared.
> 
> mm/zswap.c |   35 ++++++++++++++++++++++++-----------
>   1 files changed, 24 insertions(+), 11 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

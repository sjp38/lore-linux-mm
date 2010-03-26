Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C6E3F6B01AC
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 23:07:06 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2Q374K9031134
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 26 Mar 2010 12:07:04 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 33CF045DE57
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 12:07:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 105BF45DE50
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 12:07:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BE11DEF8004
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 12:07:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BA79E08006
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 12:07:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped anonymous pages
In-Reply-To: <20100325133936.GR2024@csn.ul.ie>
References: <20100325191229.8e3d2ba1.kamezawa.hiroyu@jp.fujitsu.com> <20100325133936.GR2024@csn.ul.ie>
Message-Id: <20100326120429.6C98.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 26 Mar 2010 12:07:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

very small nit

> There were minor changes in how the rcu_read_lock is taken and released
> based on other comments. With your suggestion, the block now looks like;
> 
>         if (PageAnon(page)) {
>                 rcu_read_lock();
>                 rcu_locked = 1;
> 
>                 /*
>                  * If the page has no mappings any more, just bail. An
>                  * unmapped anon page is likely to be freed soon but
>                  * worse,
>                  * it's possible its anon_vma disappeared between when
>                  * the page was isolated and when we reached here while
>                  * the RCU lock was not held
>                  */
>                 if (!page_mapcount(page) && !PageSwapCache(page))

                        page_mapped?

>                         goto rcu_unlock;
> 
>                 anon_vma = page_anon_vma(page);
>                 atomic_inc(&anon_vma->external_refcount);
>         }



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

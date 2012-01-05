Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A9E966B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 02:24:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DA4883EE0C1
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:24:23 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE0F245DE69
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:24:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A445A45DE61
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:24:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 94B7C1DB803C
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:24:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E1461DB802C
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 16:24:23 +0900 (JST)
Date: Thu, 5 Jan 2012 16:23:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: MAP_NOZERO revisited
Message-Id: <20120105162311.09dac4b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F04F0B9.5040401@fb.com>
References: <4F04F0B9.5040401@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: linux-mm@kvack.org, Davide Libenzi <davidel@xmailserver.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Wed, 4 Jan 2012 16:37:13 -0800
Arun Sharma <asharma@fb.com> wrote:

> 
> A few years ago, Davide posted patches to address clear_page() showing 
> up high in the kernel profiles.
> 
> http://thread.gmane.org/gmane.linux.kernel/548928
> 
> With malloc implementations that try to conserve the RSS by madvising 
> away unused pages that are dirty (i.e. faulted in), we pay a high cost 
> in clear_page() if that page is needed later by the same process.
> 
> Now that we have memcgs with their own LRU lists, I was thinking of a 
> MAP_NOZERO implementation that tries to avoid zero'ing the page if it's 
> coming from the same memcg.
> 
> This will probably need an extra PCG_* flag maintaining state about 
> whether the page was moved between memcgs since last use.
> 
When pages are freed, it goes back to global page allocator.
memcg has no page allocator hooks for alloc/free.
We, memcg guys, tries to reduce size of page_cgroup remove page_cgroup->flags.
And finally want to integrate it to struct 'page'. 
So, I don't like your idea very much.
please find another way.

> Security implications: this is not as good as the UID based checks in 
> Davide's implementation, so should probably be an opt-in instead of 
> being enabled by default.
> 

I think you need an another page allocator as hugetlb.c does and need to
maintain 'page pool'.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

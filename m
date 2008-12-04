Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB40WX8G028106
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Dec 2008 09:32:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AFD1945DE4F
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 09:32:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8688345DE53
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 09:32:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C8A81DB8041
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 09:32:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A2DA1DB8038
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 09:32:33 +0900 (JST)
Date: Thu, 4 Dec 2008 09:31:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory hotplug: run lru_add_drain_all() on each cpu
Message-Id: <20081204093143.390afa9f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1228342567.13111.11.camel@nimitz>
References: <1228339524.6598.11.camel@t60p>
	<1228342567.13111.11.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: gerald.schaefer@de.ibm.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, y-goto@jp.fujitsu.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 03 Dec 2008 14:16:07 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > This let us run
> > into the BUG_ON(!PageBuddy(page)) in __offline_isolated_pages() during
> > memory hotplug stress test on s390. The page in question was still on the
> > pcp list, because of a race with lru_add_drain_all() and drain_all_pages()
> > on different cpus.
> > 
> > This is fixed with this patch by adding CONFIG_MEMORY_HOTREMOVE to the
> > lru_add_drain_all() #ifdef, to let it run on each cpu.
> 
> This doesn't seem right to me.  CONFIG_MEMORY_HOTREMOVE doesn't change
> the layout of the LRUs, unlike NUMA or UNEVICTABLE_LRU.  So, I think
> this bug is more due to the hotremove code mis-expecting behavior out of
> lru_add_drain_all().
> 
How about 

#ifdef CONFIG_SMP

#else..

#endif

rather than

-#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU)
+#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU) || \
+    defined(CONFIG_MEMORY_HOTREMOVE)
...

thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

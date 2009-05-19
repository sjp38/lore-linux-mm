Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E565E6B0055
	for <linux-mm@kvack.org>; Tue, 19 May 2009 04:28:09 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4J8SYnV003693
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 19 May 2009 17:28:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 517B245DE3E
	for <linux-mm@kvack.org>; Tue, 19 May 2009 17:28:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3190C45DE3A
	for <linux-mm@kvack.org>; Tue, 19 May 2009 17:28:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 162E61DB8038
	for <linux-mm@kvack.org>; Tue, 19 May 2009 17:28:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 84A55E0800B
	for <linux-mm@kvack.org>; Tue, 19 May 2009 17:28:30 +0900 (JST)
Message-ID: <8c90ea703295420e2fac0a2744d1816a.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090519105028.8ce4f8da.nishimura@mxp.nes.nec.co.jp>
References: <20090515190027.e7d48d7a.kamezawa.hiroyu@jp.fujitsu.com>
    <20090519105028.8ce4f8da.nishimura@mxp.nes.nec.co.jp>
Date: Tue, 19 May 2009 17:28:30 +0900 (JST)
Subject: Re: [PATCH] memcg: handle accounting race in swapin-readahead and
 zap_pte
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, hannes@cmpxchg.org, "mingo@elte.hu" <mingo@elte.hu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> On Fri, 15 May 2009 19:00:27 +0900, KAMEZAWA Hiroyuki
>-------------------------------------+-------------------------------------
>                                        |  trylock_page()
>                                        |    try_to_free_swap()
>                                        |      page_swapcount() -> true &
> return
>      swap_info_get()                   |
>        swap_entry_free() == 1          |
>        find_get_page() -> found        |
>        trylock_page() -> fail & return |
>                                        |    unlock_page()
>
> I don't think it happens in practice(unlock_page() would be called soon
> after
> try_to_free_swap() returns), and this patch seems to work well actually.
> I'm not sure whether we should handle this case more strictly or not, but
> I think
> it it would be better to add some comments about it at least.
>
Hmm, ok. maybe trylock in free_swap_and_cache() is the worst thing as
Andrew pointed out...

> And I have a question.
>
> If the size of swap device(or the number of used swap entries not on
> SwapCache)
> is small enough not to hit "if (memcg_swapin_buffer.nr >
> ENOUGH_LARGE_SWAPIN_BUFFER)"
> in mem_cgroup_add_swapin_buffer(), those pages in swapin buffer
> are left and unfreed by swapoff(although swap entries are freed) ?
> Isn't it better to call directly mem_cgroup_drain_swapin_buffer() at the
> end of swapoff ?
>
Hmm, maybe necessary.

> I prefer your v4(remembering only stale swap entries) to be honest,
> but I don't oppose strongly to this direction.
>
I can't believe I can handle complex race with "rememebering only stale".
I'll try to remove trylock in free_swap_and_cache...

Thank you for testing.
-Kmae

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

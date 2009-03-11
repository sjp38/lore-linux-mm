Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA0F06B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 20:47:00 -0400 (EDT)
Message-id: <isapiwc.d14e3c29.6b18.49b7092b.9bc73.52@mail.jp.nec.com>
In-Reply-To: <20090311085326.403a211d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
 <20090310160856.77deb5c3.akpm@linux-foundation.org>
 <20090311085326.403a211d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 11 Mar 2009 09:43:23 +0900
From: nishimura@mxp.nes.nec.co.jp
Subject: Re: [BUGFIX][PATCH] memcg: charge swapcache to proper memcg
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

> On Tue, 10 Mar 2009 16:08:56 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> On Tue, 10 Mar 2009 10:07:07 +0900
>> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
>> 
>> > --- a/mm/memcontrol.c
>> > +++ b/mm/memcontrol.c
>> > @@ -909,13 +909,24 @@ nomem:
>> >  static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>> >  {
>> >  	struct mem_cgroup *mem;
>> > +	struct page_cgroup *pc;
>> >  	swp_entry_t ent;
>> >  
>> > +	VM_BUG_ON(!PageLocked(page));
>> > +
>> >  	if (!PageSwapCache(page))
>> >  		return NULL;
>> >  
>> > -	ent.val = page_private(page);
>> > -	mem = lookup_swap_cgroup(ent);
>> > +	pc = lookup_page_cgroup(page);
>> > +	/*
>> > +	 * Used bit of swapcache is solid under page lock.
>> > +	 */
>> > +	if (PageCgroupUsed(pc))
>> > +		mem = pc->mem_cgroup;
>> > +	else {
>> > +		ent.val = page_private(page);
>> > +		mem = lookup_swap_cgroup(ent);
>> > +	}
>> >  	if (!mem)
>> >  		return NULL;
>> >  	if (!css_tryget(&mem->css))
>> 
>> This patch made rather a mess of
>> use-css-id-in-swap_cgroup-for-saving-memory-v4.patch.
>> 
Ah.. I found this bug while testing rc6, so I made this patch
based on rc6 and forgot to rebase it on mmotm.

>> I temporarily dropped
>> use-css-id-in-swap_cgroup-for-saving-memory-v4.patch.  Could I have a
>> fixed version please?
> Okay.
> 
I'm sorry for bothering you.


Daisuke Nishimura.

>> 
>> Do we think that this patch
>> (memcg-charge-swapcache-to-proper-memcg.patch) shouild be in 2.6.29?
>> 
> please.
> 
> Thanks,
> -Kame
> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

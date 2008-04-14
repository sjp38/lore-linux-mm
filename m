Message-ID: <48031775.10008@mtf.biglobe.ne.jp>
Date: Mon, 14 Apr 2008 17:36:05 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Reply-To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/3] account swapcache
References: <20080408190734.70ab55b0.kamezawa.hiroyu@jp.fujitsu.com>	<20080408191311.73b167bb.kamezawa.hiroyu@jp.fujitsu.com>	<47FF57A7.5000704@mxp.nes.nec.co.jp>	<20080414094709.fb9c3745.kamezawa.hiroyu@jp.fujitsu.com>	<48030FE9.1040401@mtf.biglobe.ne.jp> <20080414172321.b97c4eb9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080414172321.b97c4eb9.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 14 Apr 2008 17:03:53 +0900
> Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:
> 
>> I was thinking the case below.
>> Assume some anonymous pages(mapped, referenced, !SwapCache)
>> are being reclaimed.
>>
> 
> Numbering for below.
> 
> (1) > shrink_page_list()
> (2)> 	-> add_to_swap() <- makes the page dirty.
> (3)> 	->  try_to_unmap() <- uncharged from memcg and removed from mz->lru.
> (4)> 	-> PageDirty() == true
> (5)> 		sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced
> (6)> 			goto keep_locked
> (7)> 	-> unlocks the page and will work on other pages on page_list.
>> And, if on other CPU the process that owns those pages is exiting
>> at the timing of my example above, those pages remain only on
>> global lru, and are never charged(mapped) because the process exits.
>>
>> I said "never" because once they are removed from mz->lru,
>> mem_cgroup_isolate_pages() doesn't select those pages
>> unless they are charged(mapped) again.
>>
> I'm sorry if I don't catch your points.
> 
> Because of (1), it's marked as SwapCache.
> At (2) , page is not removed from mz->lru because it's SwapCache. (see my patch)
> page is still on mz->lru after (7).
> 
> After a process exits, this page will be reclaimed when page-recalim for
> page_cgroup find this.
> 
> Thanks,
> -Kame
> 
I was saying the case when swapcaches are not charged.
I showed one of the problems if they are not charged.

Sorry for confusing you.

I agree that your patch handles this case :-)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

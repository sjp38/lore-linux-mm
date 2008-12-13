Return-Path: <linux-kernel-owner+w=401wt.eu-S1757308AbYLMKir@vger.kernel.org>
Message-ID: <6678.10.75.179.62.1229164715.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0812130935220.3611@blonde.anvils>
References: <20081212172930.282caa38.kamezawa.hiroyu@jp.fujitsu.com><20081212184341.b62903a7.nishimura@mxp.nes.nec.co.jp><46730.10.75.179.61.1229080565.squirrel@webmail-b.css.fujitsu.com><20081213160310.e9501cd9.kamezawa.hiroyu@jp.fujitsu.com>
    <Pine.LNX.4.64.0812130935220.3611@blonde.anvils>
Date: Sat, 13 Dec 2008 19:38:35 +0900 (JST)
Subject: Re: [BUGFIX][PATCH mmotm] memcg fix swap accounting leak (v2)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins said:
> On Sat, 13 Dec 2008, KAMEZAWA Hiroyuki wrote:
>> --- mmotm-2.6.28-Dec12.orig/mm/memory.c
>> +++ mmotm-2.6.28-Dec12/mm/memory.c
>>
>> -	mem_cgroup_commit_charge_swapin(page, ptr);
>>  	inc_mm_counter(mm, anon_rss);
>>  	pte = mk_pte(page, vma->vm_page_prot);
>>  	if (write_access && reuse_swap_page(page)) {
>>  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
>>  		write_access = 0;
>>  	}
>> -
>>  	flush_icache_page(vma, page);
>>  	set_pte_at(mm, address, page_table, pte);
>>  	page_add_anon_rmap(page, vma, address);
>> +	/* It's better to call commit-charge after rmap is established */
>> +	mem_cgroup_commit_charge_swapin(page, ptr);
>>
>>  	swap_free(entry);
>>  	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) ||
>> PageMlocked(page))
>
> That ordering is back to how it was before I adjusted it
> for reuse_swap_page()'s delete_from_swap_cache(), isn't it?
>
> So I don't understand how you've fixed the bug I hit (not an
> accounting imbalance but an oops or BUG, I forget) with this
> ordering, without making some other change elsewhere.
>
Ah, this is a fix for the new bug by this order.
==
    try_charge()
    commit_charge()
    reuse_swap_page()
         -> delete_from_swapcache() -> uncharge_swapcache().
    increase mapcount here.
==
Because ucharge_swapcache() assumes following
  a. if mapcount==0, this swap cache is of no use and will be discarded.
  b. if mapcount >0, this swap cache is in use.
A charge commited by commit_charge() is discarded by reuse_swap_page().

By delaying commit (means checking flag of page_cgroup).
==
  try_charge()
  reuse_swap_page()
  commit_charge()
==
the leak of charge doesn't happen.
(reuse_swap_page() may drop page from swap-cache, but it's no probelm to
 commit. But as you say, this has swp_entry==0 bug.)

> mem_cgroup_commit_charge_swapin calls swap_cgroup_record with
> bogus swp_entry_t 0, which appears to belong to swp_offset 0 of
> swp_type 0, but the ctrl->map for type 0 may have been freed
> ages ago (we do always start from 0, but maybe we swapped on
> type 1 and swapped off type 0 meanwhile).  I'm guessing that
> by looking at the code, not by retesting it, so I may have the
> details wrong; but I didn't reorder your code just for fun.
>
> Perhaps your restored ordering works if you check PageSwapCache
> in mem_cgroup_commit_charge_swapin or check 0 in swap_cgroup_record,
> but I don't see that in yesterday's mmotm, nor in this patch.
>
Ahhhh, sorry. ok, swp_entry==0 is valid...Sigh...
I'll revisit this and check how commit_charge() works.
I think checking PageSwapCache() is enough but if not, do somehing other.
(Maybe Nishimura's suggestion to pass swp_entry directly to commit_charge()
 is one way.)

> (And I should admit, I've not even attempted to follow your
> accounting justification: I'll leave that to you memcg guys.)
>
Sorry for complication ;(

> An alternative could be not to clear page->private when deleting
> from swap cache, that's only done for tidiness and to force notice
> of races like this; but I'd want a much stronger reason to change that.
>
It seems that it  will add another complex or unexpected behavior..
I think I can do something workaround.

> Or am I making this up?  As I say, I've not tested it this time around.
>
I'll ask you if I found I can't do anything ;(

Thank you for pointing out!
I'll revisit this on Monday.

-Kame

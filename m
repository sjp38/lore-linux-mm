Return-Path: <linux-kernel-owner+w=401wt.eu-S1757884AbYLLLQS@vger.kernel.org>
Message-ID: <46730.10.75.179.61.1229080565.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081212184341.b62903a7.nishimura@mxp.nes.nec.co.jp>
References: <20081212172930.282caa38.kamezawa.hiroyu@jp.fujitsu.com>
    <20081212184341.b62903a7.nishimura@mxp.nes.nec.co.jp>
Date: Fri, 12 Dec 2008 20:16:05 +0900 (JST)
Subject: Re: [BUGFIX][PATCH mmotm] memcg fix swap accounting leak
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
>
>         /*
>          * The page isn't present yet, go ahead with the fault.
>          *
>          * Be careful about the sequence of operations here.
>          * To get its accounting right, reuse_swap_page() must be called
>          * while the page is counted on swap but not yet in mapcount i.e.
>          * before page_add_anon_rmap() and swap_free(); try_to_free_swap()
>          * must be called after the swap_free(), or it will never succeed.
>          * And mem_cgroup_commit_charge_swapin(), which uses the swp_entry
>          * in page->private, must be called before reuse_swap_page(),
>          * which may delete_from_swap_cache().
>          */
>
> Hmm.. should we save page->private before calling reuse_swap_page and pass
> it
> to mem_cgroup_commit_charge_swapin(I think it cannot be changed because
> the page
> is locked)?
>
seems not necessary (see below).  I'll fix comment if I uses my pc tomorrow..

Considering 2 cases,
 A. the SwapCache is already chareged before try_charge_swapin()
 B. the SwapCache is very new and not charged before try_charge_swapin()

Case A.
   0. We have charge of PAGE_SIZE to this page before reach here.
   1. try_charge_swapin() is called and charge += PAGE_SIZE
   2. reuse_swap_page() is called.
          when delete_from_swap_cache() is called..
          2-a. if already mapped, no change in charges.
          2-b. if not mapped, charge-=PAGE_SIZE. PCG_USED bit is cleared.
               and charge-record is written into swap_cgroup
          not called.
          2-c. no changes in charge.
   3. commit_charge is called.
          3-a. PCG_USED bit is set, so charge -= PAGE_SIZE.
          3-b. PCG_USED bit is cleared and so we set PCG_USED bit and no
               changes in charge.
          3-c. no changes in charge.
   4-b. swap_free() will clear record in swap_cgroup.

   Then, finally we have PAGE_SIZE of charge to this page.

Case B.
   0. We have no charges to this page.
   1. try_charge_swapin() is called and charge += PAGE_SIZE.
   2. reuse_swap_page() is called.
         2-a if delete_from_swap_cache() is called.
         the page is not mapped. but PCG_USED bit is not set.
         so, no change in charges finally. (just recorded in swap_cgroup)
         2-b. not called ... no changes in charge.
   3. commit_charge() is called and set PCG_USED bit. no changes in charnge.
   4. swap_free() is called and clear record in swap_cgroup.

   Then, finally we have PAGE_SIZE of charge to this page.



Thanks,
-Kame

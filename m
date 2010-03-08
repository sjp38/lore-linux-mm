Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E21796B0047
	for <linux-mm@kvack.org>; Sun,  7 Mar 2010 21:40:56 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o282es0r019199
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 8 Mar 2010 11:40:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F7EC45DE7E
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:40:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 62D7945DE6F
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:40:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E1391DB8037
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:40:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B756F1DB803A
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:40:53 +0900 (JST)
Date: Mon, 8 Mar 2010 11:37:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure
Message-Id: <20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
References: <1267995474-9117-1-git-send-email-arighi@develer.com>
	<1267995474-9117-4-git-send-email-arighi@develer.com>
	<20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
	<20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Mar 2010 11:17:24 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > But IIRC, clear_writeback is done under treelock.... No ?
> > 
> The place where NR_WRITEBACK is updated is out of tree_lock.
> 
>    1311 int test_clear_page_writeback(struct page *page)
>    1312 {
>    1313         struct address_space *mapping = page_mapping(page);
>    1314         int ret;
>    1315
>    1316         if (mapping) {
>    1317                 struct backing_dev_info *bdi = mapping->backing_dev_info;
>    1318                 unsigned long flags;
>    1319
>    1320                 spin_lock_irqsave(&mapping->tree_lock, flags);
>    1321                 ret = TestClearPageWriteback(page);
>    1322                 if (ret) {
>    1323                         radix_tree_tag_clear(&mapping->page_tree,
>    1324                                                 page_index(page),
>    1325                                                 PAGECACHE_TAG_WRITEBACK);
>    1326                         if (bdi_cap_account_writeback(bdi)) {
>    1327                                 __dec_bdi_stat(bdi, BDI_WRITEBACK);
>    1328                                 __bdi_writeout_inc(bdi);
>    1329                         }
>    1330                 }
>    1331                 spin_unlock_irqrestore(&mapping->tree_lock, flags);
>    1332         } else {
>    1333                 ret = TestClearPageWriteback(page);
>    1334         }
>    1335         if (ret)
>    1336                 dec_zone_page_state(page, NR_WRITEBACK);
>    1337         return ret;
>    1338 }

We can move this up to under tree_lock. Considering memcg, all our target has "mapping".

If we newly account bounce-buffers (for NILFS, FUSE, etc..), which has no ->mapping,
we need much more complex new charge/uncharge theory.

But yes, adding new lock scheme seems complicated. (Sorry Andrea.)
My concerns is performance. We may need somehing new re-implementation of
locks/migrate/charge/uncharge.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

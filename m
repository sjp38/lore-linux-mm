Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DA2A46B0092
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 23:19:39 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2H3JbvN017518
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Mar 2010 12:19:37 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EC37C45DE51
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:19:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C83B845DE4E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:19:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AC93BE18006
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:19:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 545EAE18003
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:19:36 +0900 (JST)
Date: Wed, 17 Mar 2010 12:15:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
Message-Id: <20100317121551.b619f55b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361003162000w34cc13ecnbd32840a0df80f95@mail.gmail.com>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	<1268412087-13536-3-git-send-email-mel@csn.ul.ie>
	<28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	<20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100315112829.GI18274@csn.ul.ie>
	<1268657329.1889.4.camel@barrios-desktop>
	<20100315142124.GL18274@csn.ul.ie>
	<20100316084934.3798576c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100317111234.d224f3fd.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361003162000w34cc13ecnbd32840a0df80f95@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Mar 2010 12:00:15 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Mar 17, 2010 at 11:12 AM, KAMEZAWA Hiroyuki
> > BTW, I doubt freeing anon_vma can happen even when we check mapcount.
> >
> > "unmap" is 2-stage operation.
> > A  A  A  A 1. unmap_vmas() => modify ptes, free pages, etc.
> > A  A  A  A 2. free_pgtables() => free pgtables, unlink vma and free it.
> >
> > Then, if migration is enough slow.
> >
> > A  A  A  A Migration(): A  A  A  A  A  A  A  A  A  A  A  A  A  A Exit():
> > A  A  A  A check mapcount
> > A  A  A  A rcu_read_lock
> > A  A  A  A pte_lock
> > A  A  A  A replace pte with migration pte
> > A  A  A  A pte_unlock
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A pte_lock
> > A  A  A  A copy page etc... A  A  A  A  A  A  A  A  A  A  A  A zap pte (clear pte)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A pte_unlock
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A free_pgtables
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A ->free vma
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A ->free anon_vma
> > A  A  A  A pte_lock
> > A  A  A  A remap pte with new pfn(fail)
> > A  A  A  A pte_unlock
> >
> > A  A  A  A lock anon_vma->lock A  A  A  A  A  A  # modification after free.
> > A  A  A  A check list is empty
> 
> check list is empty?
> Do you mean anon_vma->head?
> 
yes.

> If it is, is it possible that that list isn't empty since anon_vma is
> used by others due to
> SLAB_DESTROY_BY_RCU?
> 
There are 4 cases.
	A) anon_vma->list is not empty because anon_vma is not freed.
	B) anon_vma->list is empty because it's freed.
	C) anon_vma->list is empty but it's reused.
	D) anon_vma->list is not empty but it's reused.
 
> but such case is handled by page_check_address, vma_address, I think.
> 
yes. Then, this corrupt nothing, as I wrote. We just modify anon_vma->lock
and it's safe because of SLAB_DESTROY_BY_RCU.


> > A  A  A  A unlock anon_vma->lock
> > A  A  A  A free anon_vma
> > A  A  A  A rcu_read_unlock
> >
> >
> > Hmm. IIUC, anon_vma is allocated as SLAB_DESTROY_BY_RCU. Then, while
> > rcu_read_lock() is taken, anon_vma is anon_vma even if freed. But it
> > may reused as anon_vma for someone else.
> > (IOW, it may be reused but never pushed back to general purpose memory
> > A until RCU grace period.)
> > Then, touching anon_vma->lock never cause any corruption.
> >
> > Does use-after-free check for SLAB_DESTROY_BY_RCU correct behavior ?
> 
> Could you elaborate your point?
> 

Ah, my point is "how use-after-free is detected ?"

If use-after-free is detected by free_pages() (DEBUG_PGALLOC), it seems
strange because DESTROY_BY_RCU guarantee that never happens.

So, I assume use-after-free is detected in SLAB layer. If so,
in above B), C), D) case, it seems there is use-after free in slab's point
of view but it works as expected, no corruption.

Then, my question is
"Does use-after-free check for SLAB_DESTROY_BY_RCU work correctly ?"

and implies we need this patch ?
(But this will prevent unnecessary page copy etc. by easy check.)

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

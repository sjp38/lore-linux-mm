Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 739786B004D
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 00:23:07 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2H4N35O010966
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Mar 2010 13:23:03 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CD8045DE7C
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 13:23:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1610645DE6E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 13:23:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFB071DB8040
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 13:23:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 79BFBE18001
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 13:23:02 +0900 (JST)
Date: Wed, 17 Mar 2010 13:19:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
Message-Id: <20100317131912.0712e6b0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361003162115k79e3d40fka6e1def6472823ef@mail.gmail.com>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	<28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	<20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100315112829.GI18274@csn.ul.ie>
	<1268657329.1889.4.camel@barrios-desktop>
	<20100315142124.GL18274@csn.ul.ie>
	<20100316084934.3798576c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100317111234.d224f3fd.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361003162000w34cc13ecnbd32840a0df80f95@mail.gmail.com>
	<20100317121551.b619f55b.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361003162115k79e3d40fka6e1def6472823ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Mar 2010 13:15:14 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Mar 17, 2010 at 12:15 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 17 Mar 2010 12:00:15 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> On Wed, Mar 17, 2010 at 11:12 AM, KAMEZAWA Hiroyuki
> >> > BTW, I doubt freeing anon_vma can happen even when we check mapcount.
> >> >
> >> > "unmap" is 2-stage operation.
> >> > A  A  A  A 1. unmap_vmas() => modify ptes, free pages, etc.
> >> > A  A  A  A 2. free_pgtables() => free pgtables, unlink vma and free it.
> >> >
> >> > Then, if migration is enough slow.
> >> >
> >> > A  A  A  A Migration(): A  A  A  A  A  A  A  A  A  A  A  A  A  A Exit():
> >> > A  A  A  A check mapcount
> >> > A  A  A  A rcu_read_lock
> >> > A  A  A  A pte_lock
> >> > A  A  A  A replace pte with migration pte
> >> > A  A  A  A pte_unlock
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A pte_lock
> >> > A  A  A  A copy page etc... A  A  A  A  A  A  A  A  A  A  A  A zap pte (clear pte)
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A pte_unlock
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A free_pgtables
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A ->free vma
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A ->free anon_vma
> >> > A  A  A  A pte_lock
> >> > A  A  A  A remap pte with new pfn(fail)
> >> > A  A  A  A pte_unlock
> >> >
> >> > A  A  A  A lock anon_vma->lock A  A  A  A  A  A  # modification after free.
> >> > A  A  A  A check list is empty
> >>
> >> check list is empty?
> >> Do you mean anon_vma->head?
> >>
> > yes.
> >
> >> If it is, is it possible that that list isn't empty since anon_vma is
> >> used by others due to
> >> SLAB_DESTROY_BY_RCU?
> >>
> > There are 4 cases.
> > A  A  A  A A) anon_vma->list is not empty because anon_vma is not freed.
> > A  A  A  A B) anon_vma->list is empty because it's freed.
> > A  A  A  A C) anon_vma->list is empty but it's reused.
> > A  A  A  A D) anon_vma->list is not empty but it's reused.
> 
> E) anon_vma is used for other object.
> 
> That's because we don't hold rcu_read_lock.
> I think Mel met this E) situation.
> 
Hmm. 

> AFAIU, even slab page of SLAB_BY_RCU can be freed after grace period.
> Do I miss something?
> 
I miss something. Sorry for noise.

Maybe we need check page_mapped() before calling try_to_unmap() as
vmscan does. Thank you for your help.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

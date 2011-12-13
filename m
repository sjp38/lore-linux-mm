Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 2CE3A6B0204
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 23:26:54 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F05C93EE0AE
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:26:51 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D85A745DE4E
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:26:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B86F845DE4D
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:26:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ACDE11DB802F
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:26:51 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 60454E08001
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:26:51 +0900 (JST)
Date: Tue, 13 Dec 2011 13:25:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: simplify find_vma_prev
Message-Id: <20111213132541.86d1461f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4EE61E6D.4070401@gmail.com>
References: <1323466526.27746.29.camel@joe2Laptop>
	<1323470921-12931-1-git-send-email-kosaki.motohiro@gmail.com>
	<20111212094930.9d4716e1.kamezawa.hiroyu@jp.fujitsu.com>
	<20111212182711.3a072358.kamezawa.hiroyu@jp.fujitsu.com>
	<4EE61E6D.4070401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Andrew Morton (commit_signer:15/23=65%)" <akpm@linux-foundation.org>, "Hugh Dickins (commit_signer:7/23=30%)" <hughd@google.com>, "Peter Zijlstra (commit_signer:4/23=17%)" <a.p.zijlstra@chello.nl>, "Shaohua Li (commit_signer:3/23=13%)" <shaohua.li@intel.com>

On Mon, 12 Dec 2011 10:31:57 -0500
KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> (12/12/11 4:27 AM), KAMEZAWA Hiroyuki wrote:
> > On Mon, 12 Dec 2011 09:49:30 +0900
> > KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>  wrote:
> >
> >> On Fri,  9 Dec 2011 17:48:40 -0500
> >> kosaki.motohiro@gmail.com wrote:
> >>
> >>> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> >>>
> >>> commit 297c5eee37 (mm: make the vma list be doubly linked) added
> >>> vm_prev member into vm_area_struct. Therefore we can simplify
> >>> find_vma_prev() by using it. Also, this change help to improve
> >>> page fault performance because it has strong locality of reference.
> >>>
> >>> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> >>
> >> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >
> > Hmm, your work remind me of a patch I tried in past.
> > Here is a refleshed one...how do you think ?
> >
> > ==
> >  From c0261936fc01322d06425731d33f38b2021e8067 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Mon, 12 Dec 2011 18:31:19 +0900
> > Subject: [PATCH] per thread vma cache.
> >
> > This is a toy patch. How do you think ?
> >
> > This is a patch for per-thread mmap_cache without heavy atomic ops.
> >
> > I'm sure overhead of find_vma() is pretty small in usual application
> > and this will not show good improvement. But I think, if we need
> > to have cache of vma, it should be per thread rather than per mm.
> 
> Agreed. per-thread is better.
> 
> 
> > This patch adds thread->mmap_cache, a pointer for vm_area_struct
> > and update it appropriately. Because we have no refcnt on vm_area_struct,
> > thread->mmap_cache may be a stale pointer. This patch detects stale
> > pointer by checking
> >
> >      - thread->mmap_cache is one of SLABs in vm_area_cachep.
> >      - thread->mmap_cache->vm_mm == mm.
> >
> > vma->vm_mm will be cleared before kmem_cache_free() by this patch.
> 
> Do you mean the cache can make mishit with unrelated vma when freed vma 
> was reused?

yes.

> If so, it is most tricky part of this patch, I strongly hope you write
> a comment more.
> 

Sure.
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

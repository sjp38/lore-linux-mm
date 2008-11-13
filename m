Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAD6C7wP009908
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 15:12:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C3A345DD81
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 15:12:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 528E345DD7B
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 15:12:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A7CFE08004
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 15:12:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67F66E08014
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 15:12:06 +0900 (JST)
Date: Thu, 13 Nov 2008 15:11:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
Message-Id: <20081113151129.35c17962.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <491AB9D0.7060802@qumranet.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	<1226409701-14831-2-git-send-email-ieidus@redhat.com>
	<1226409701-14831-3-git-send-email-ieidus@redhat.com>
	<20081111114555.eb808843.akpm@linux-foundation.org>
	<4919F1C0.2050009@redhat.com>
	<Pine.LNX.4.64.0811111520590.27767@quilx.com>
	<4919F7EE.3070501@redhat.com>
	<Pine.LNX.4.64.0811111527500.27767@quilx.com>
	<20081111222421.GL10818@random.random>
	<20081112111931.0e40c27d.kamezawa.hiroyu@jp.fujitsu.com>
	<491AAA84.5040801@redhat.com>
	<491AB9D0.7060802@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izik@qumranet.com>
Cc: Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

Thank you for answers.

On Wed, 12 Nov 2008 13:11:12 +0200
Izik Eidus <izik@qumranet.com> wrote:

> Avi Kivity wrote:
> > KAMEZAWA Hiroyuki wrote:
> >> Can I make a question ? (I'm working for memory cgroup.)
> >>
> >> Now, we do charge to anonymous page when
> >>   - charge(+1) when it's mapped firstly (mapcount 0->1)
> >>   - uncharge(-1) it's fully unmapped (mapcount 1->0) vir 
> >> page_remove_rmap().
> >>
> >> My quesion is
> >>  - PageKSM pages are not necessary to be tracked by memory cgroup ?
> When we reaplacing page using page_replace() we have:
> oldpage - > anonymous page that is going to be replaced by newpage
> newpage -> kernel allocated page (KsmPage)
> so about oldpage we are calling page_remove_rmap() that will notify cgroup
> and about newpage it wont be count inside cgroup beacuse it is file rmap 
> page
> (we are calling to page_add_file_rmap), so right now PageKSM wont ever 
> be tracked by cgroup.
> 
If not in radix-tree, it's not tracked.
(But we don't want to track non-LRU pages which are not freeable.)


> >>  - Can we know that "the page is just replaced and we don't necessary 
> >> to do
> >>    charge/uncharge".
> 
> The caller of page_replace does know it, the only problem is that 
> page_remove_rmap()
> automaticly change the cgroup for anonymous pages,
> if we want it not to change the cgroup, we can:
> increase the cgroup count before page_remove (but in that case what 
> happen if we reach to the limit???)
> give parameter to page_remove_rmap() that we dont want the cgroup to be 
> changed.

Hmm, current mem cgroup works via page_cgroup struct to track pages.

   page <-> page_cgroup has one-to-one relation ship.

So, "exchanging page" itself causes trouble. But I may be able to provide
necessary hooks to you as I did in page migraiton.

> 
> >>  - annonymous page from KSM is worth to be tracked by memory cgroup ?
> >>    (IOW, it's on LRU and can be swapped-out ?)
> 
> KSM have no anonymous pages (it share anonymous pages into KsmPAGE -> 
> kernel allocated page without mapping)
> so it isnt in LRU and it cannt be swapped, only when KsmPAGEs will be 
> break by do_wp_page() the duplication will be able to swap.
> 
Ok, thank you for confirmation.

> >>   
> >
> > My feeling is that shared pages should be accounted as if they were 
> > not shared; that is, a share page should be accounted for each process 
> > that shares it.  Perhaps sharing within a cgroup should be counted as 
> > 1 page for all the ptes pointing to it.
> >
> >

If KSM pages are on radix-tree, it will be accounted automatically.
Now, we have "Unevictable" LRU and mlocked() pages are smartly isolated into its
own LRU. So, just doing

 - inode's radix-tree
 - make all pages mlocked.
 - provide special page fault handler for your purpose

is simple one. But ok, whatever implementation you'll do, I have to check it
and consider whether it should be tracked or not. Then, add codes to memcg to
track it or ignore it or comments on your patches ;)

It's helpful to add me to CC: when you post this set again.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

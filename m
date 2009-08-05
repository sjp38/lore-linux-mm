Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0FC5F6B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 00:15:38 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n754FfWB004014
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 5 Aug 2009 13:15:42 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B749145DE51
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 13:15:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 91F8345DE4D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 13:15:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C6B4E1800A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 13:15:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 33ED1E18009
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 13:15:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
In-Reply-To: <20090805024058.GA8886@localhost>
References: <20090805024058.GA8886@localhost>
Message-Id: <20090805130936.5BAD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  5 Aug 2009 13:15:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> Greetings,
> 
> Jeff Dike found that many KVM pages are being refaulted in 2.6.29:
> 
> "Lots of pages between discarded due to memory pressure only to be
> faulted back in soon after. These pages are nearly all stack pages.
> This is not consistent - sometimes there are relatively few such pages
> and they are spread out between processes."

I suprise this result really.

  - Why this issue happened only on kvm?
  - Why shrink_inactive_list() can't find pte young bit?
    Is this really unused stack?

> 
> The refaults can be drastically reduced by the following patch, which
> respects the referenced bit of all anonymous pages (including the KVM
> pages).
> 
> However it risks reintroducing the problem addressed by commit 7e9cd4842
> (fix reclaim scalability problem by ignoring the referenced bit,
> mainly the pte young bit). I wonder if there are better solutions?
> 
> Thanks,
> Fengguang
> 
> ---
>  mm/vmscan.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> --- linux.orig/mm/vmscan.c
> +++ linux/mm/vmscan.c
> @@ -1288,12 +1288,12 @@ static void shrink_active_list(unsigned 
>  			 * Identify referenced, file-backed active pages and
>  			 * give them one more trip around the active list. So
>  			 * that executable code get better chances to stay in
> -			 * memory under moderate memory pressure.  Anon pages
> -			 * are not likely to be evicted by use-once streaming
> -			 * IO, plus JVM can create lots of anon VM_EXEC pages,
> -			 * so we ignore them here.
> +			 * memory under moderate memory pressure.
> +			 *
> +			 * Also protect anon pages: swapping could be costly,
> +			 * and KVM guest's referenced bit is helpful.
>  			 */
> -			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> +			if ((vm_flags & VM_EXEC) || PageAnon(page)) {
>  				list_add(&page->lru, &l_active);
>  				continue;
>  			}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DACAF6B0095
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 22:00:27 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n692DQw1028867
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 11:13:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C12BC45DE6F
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:13:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C99245DE60
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:13:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8944F1DB8042
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:13:26 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 388341DB803E
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:13:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] Show kernel stack usage to /proc/meminfo and OOM log
In-Reply-To: <alpine.DEB.1.10.0907071234070.5124@gentwo.org>
References: <20090705182409.08FC.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907071234070.5124@gentwo.org>
Message-Id: <20090709110952.2389.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 11:13:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Sun, 5 Jul 2009, KOSAKI Motohiro wrote:
> 
> > Subject: [PATCH] Show kernel stack usage to /proc/meminfo and OOM log
> >
> > if the system have a lot of thread, kernel stack consume unignorable large size
> > memory. IOW, it make a lot of unaccountable memory.
> > Tons unaccountable memory bring to harder analyse memory related trouble.
> >
> > Then, kernel stack account is useful.
> 
> The amount of memory allocated to kernel stacks can become significant and
> cause OOM conditions. However, we do not display the amount of memory
> consumed by stacks.'
> 
> Add code to display the amount of memory used for stacks in /proc/meminfo.
> 
> Reviewed-by: <cl@linux-foundation.org>

Thanks.
I'll fix the description.


> (It may be useful to also include the stack sizes in the per zone
> information displayed when an OOM occurs).

following code in this patch mean display per-zone stack size, no?



> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2158,6 +2158,7 @@ void show_free_areas(void)
>  			" mapped:%lukB"
>  			" slab_reclaimable:%lukB"
>  			" slab_unreclaimable:%lukB"
> +			" kernel_stack:%lukB"
>  			" pagetables:%lukB"
>  			" unstable:%lukB"
>  			" bounce:%lukB"
> @@ -2182,6 +2183,8 @@ void show_free_areas(void)
>  			K(zone_page_state(zone, NR_FILE_MAPPED)),
>  			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
>  			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
> +			zone_page_state(zone, NR_KERNEL_STACK) *
> +				THREAD_SIZE / 1024,
>  			K(zone_page_state(zone, NR_PAGETABLE)),
>  			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
>  			K(zone_page_state(zone, NR_BOUNCE)),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

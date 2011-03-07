Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CB2AC8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 03:28:51 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 33FBC3EE0C1
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:28:48 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1650845DE4E
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:28:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F2CEC45DE61
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:28:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D9723E08001
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:28:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 843CDE08006
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:28:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
In-Reply-To: <1299182391-6061-9-git-send-email-andi@firstfloor.org>
References: <1299182391-6061-1-git-send-email-andi@firstfloor.org> <1299182391-6061-9-git-send-email-andi@firstfloor.org>
Message-Id: <20110307172609.8A01.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Mar 2011 17:28:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

> From: Andi Kleen <ak@linux.intel.com>
> 
> I found it difficult to make sense of transparent huge pages without
> having any counters for its actions. Add some counters to vmstat
> for allocation of transparent hugepages and fallback to smaller
> pages.
> 
> Optional patch, but useful for development and understanding the system.
> 
> Contains improvements from Andrea Arcangeli and Johannes Weiner
> 
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/vmstat.h |    7 +++++++
>  mm/huge_memory.c       |   25 +++++++++++++++++++++----
>  mm/vmstat.c            |    8 ++++++++
>  3 files changed, 36 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 9b5c63d..074e8fd 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -58,6 +58,13 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
>  		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
>  		UNEVICTABLE_MLOCKFREED,
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	        THP_FAULT_ALLOC,
> +		THP_FAULT_FALLBACK,
> +		THP_COLLAPSE_ALLOC,
> +		THP_COLLAPSE_ALLOC_FAILED,
> +		THP_SPLIT,
> +#endif
>  		NR_VM_EVENT_ITEMS
>  };

Hmm...
Don't we need to make per zone stastics? I'm afraid small dma zone 
makes much thp-splitting and screw up this stastics.

only nit.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 698866B0083
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 12:37:28 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p53GbO76004769
	for <linux-mm@kvack.org>; Fri, 3 Jun 2011 09:37:24 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by kpbe11.cbf.corp.google.com with ESMTP id p53Gav2O021263
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 3 Jun 2011 09:37:22 -0700
Received: by pxi7 with SMTP id 7so1195805pxi.16
        for <linux-mm@kvack.org>; Fri, 03 Jun 2011 09:37:18 -0700 (PDT)
Date: Fri, 3 Jun 2011 09:37:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ksm: fix race between ksmd and exiting task
In-Reply-To: <20110602173549.GL23047@sequoia.sous-sol.org>
Message-ID: <alpine.LSU.2.00.1106030934130.1810@sister.anvils>
References: <20110601222032.GA2858@thinkpad> <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <20110602141927.GA2011@thinkpad> <20110602164841.GK23047@sequoia.sous-sol.org>
 <20110602173549.GL23047@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrea Righi <andrea@betterlinux.com>, CAI Qian <caiqian@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2 Jun 2011, Chris Wright wrote:

> Andrea Righi reported a case where an exiting task can race against
> ksmd.
> 
> ksm_scan.mm_slot == the only registered mm
> CPU 1 (bug program)		CPU 2 (ksmd)
>  				list_empty() is false
> lock
> ksm_scan.mm_slot
> list_del
> unlock
>  				slot == &ksm_mm_head (but list is now empty_)
> 
> Close this race by revalidating that the new slot is not simply the list
> head again.

Remarkably similar to my patch: it must be good!
But yours appears to be more popular - thanks, Chris.

> 
> Reported-by: Andrea Righi <andrea@betterlinux.com>
> Cc: Hugh Dickins <hughd@google.com>

Acked-by: Hugh Dickins <hughd@google.com>

> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Chris Wright <chrisw@sous-sol.org>

Cc: stable@kernel.org

> ---
>  mm/ksm.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 942dfc7..0373ce4 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1301,6 +1301,9 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>  		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
>  		ksm_scan.mm_slot = slot;
>  		spin_unlock(&ksm_mmlist_lock);
> +		/* We raced against exit of last slot on the list */
> +		if (slot == &ksm_mm_head)
> +			return NULL;
>  next_mm:
>  		ksm_scan.address = 0;
>  		ksm_scan.rmap_list = &slot->rmap_list;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

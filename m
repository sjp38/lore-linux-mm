Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 8BF716B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 12:35:57 -0500 (EST)
Received: by qcsd17 with SMTP id d17so9757514qcs.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 09:35:56 -0800 (PST)
Message-ID: <4EFCA4F9.7070703@gmail.com>
Date: Thu, 29 Dec 2011 12:35:53 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscam: check page order in isolating lru pages
References: <CAJd=RBBJG+hLLc3mR-WzByU1gZEcdFUAoZzyir+1A4a0tVnSmg@mail.gmail.com>
In-Reply-To: <CAJd=RBBJG+hLLc3mR-WzByU1gZEcdFUAoZzyir+1A4a0tVnSmg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

(12/29/11 7:45 AM), Hillf Danton wrote:
> Before we try to isolate physically contiguous pages, check for page order is
> added, and if the reclaim order is no larger than page order, we should give up
> the attempt.
>
> Signed-off-by: Hillf Danton<dhillf@gmail.com>
> Cc: Michal Hocko<mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton<akpm@linux-foundation.org>
> Cc: David Rientjes<rientjes@google.com>
> Cc: Hugh Dickins<hughd@google.com>
> ---
>
> --- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
> +++ b/mm/vmscan.c	Thu Dec 29 20:28:14 2011
> @@ -1162,6 +1162,7 @@ static unsigned long isolate_lru_pages(u
>   		unsigned long end_pfn;
>   		unsigned long page_pfn;
>   		int zone_id;
> +		unsigned int isolated_pages = 0;
>
>   		page = lru_to_page(src);
>   		prefetchw_prev_lru_page(page, src, flags);
> @@ -1172,7 +1173,7 @@ static unsigned long isolate_lru_pages(u
>   		case 0:
>   			mem_cgroup_lru_del(page);
>   			list_move(&page->lru, dst);
> -			nr_taken += hpage_nr_pages(page);
> +			isolated_pages = hpage_nr_pages(page);
>   			break;
>
>   		case -EBUSY:
> @@ -1184,8 +1185,11 @@ static unsigned long isolate_lru_pages(u
>   			BUG();
>   		}
>
> +		nr_taken += isolated_pages;
>   		if (!order)
>   			continue;
> +		if (isolated_pages != 1&&  isolated_pages>= (1<<  order))
> +			continue;

strange space alignment. and I don't think we need "isolated_pages != 1" 
check.

Otherwise, Looks good to me.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

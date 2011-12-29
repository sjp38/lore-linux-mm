Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id C06266B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 18:07:18 -0500 (EST)
Date: Thu, 29 Dec 2011 15:07:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: fix typo in isolating lru pages
Message-Id: <20111229150717.6c8ba825.akpm@linux-foundation.org>
In-Reply-To: <CAJd=RBAp=ooYGoDqJG0qkUhRuYTsSKG9h+bUvC0dvuVCvfkCgQ@mail.gmail.com>
References: <CAJd=RBAp=ooYGoDqJG0qkUhRuYTsSKG9h+bUvC0dvuVCvfkCgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 29 Dec 2011 20:38:41 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> It is not the tag page but the cursor page that we should process, and it looks
> a typo.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> ---
> 
> --- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
> +++ b/mm/vmscan.c	Thu Dec 29 20:23:30 2011
> @@ -1231,13 +1231,13 @@ static unsigned long isolate_lru_pages(u
> 
>  				mem_cgroup_lru_del(cursor_page);
>  				list_move(&cursor_page->lru, dst);
> -				isolated_pages = hpage_nr_pages(page);
> +				isolated_pages = hpage_nr_pages(cursor_page);
>  				nr_taken += isolated_pages;
>  				nr_lumpy_taken += isolated_pages;
>  				if (PageDirty(cursor_page))
>  					nr_lumpy_dirty += isolated_pages;
>  				scan++;
> -				pfn += isolated_pages-1;
> +				pfn += isolated_pages - 1;
>  			} else {
>  				/*
>  				 * Check if the page is freed already.

This problem looks pretty benign in mainline.  But Andrea's "mm:
vmscan: check if we isolated a compound page during lumpy scan" came
along and uses isolated_pages rather a lot more, including using it to
advance across the pfn array.

I jiggled your patch to suit current mainline then reworked everything
else so we end up with this result.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

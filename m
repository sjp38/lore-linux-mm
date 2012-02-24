Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id A4DD16B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 00:32:38 -0500 (EST)
Received: by bkty12 with SMTP id y12so2258528bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 21:32:36 -0800 (PST)
Message-ID: <4F4720F1.2060805@openvz.org>
Date: Fri, 24 Feb 2012 09:32:33 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 18/21] mm: add to lruvec isolated pages counters
References: <20120223133728.12988.5432.stgit@zurg> <20120223135314.12988.97364.stgit@zurg>
In-Reply-To: <20120223135314.12988.97364.stgit@zurg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

Konstantin Khlebnikov wrote:
> @@ -2480,8 +2494,11 @@ static int mem_cgroup_move_parent(struct page *page,
>
>          if (nr_pages>  1)
>                  compound_unlock_irqrestore(page, flags);
> +       if (!ret)
> +               /* This also stabilize PageLRU() sign for lruvec lock holder. */
> +               mem_cgroup_adjust_isolated(lruvec, page, -nr_pages);
>   put_back:
> -       putback_lru_page(page);
> +       __putback_lru_page(page, !ret);
>   put:
>          put_page(page);
>   out:

Oh, no. There must be !!ret

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2482,7 +2482,7 @@ static int mem_cgroup_move_parent(struct page *page,
                 /* This also stabilize PageLRU() sign for lruvec lock holder. */
                 mem_cgroup_adjust_isolated(lruvec, page, -nr_pages);
  put_back:
-       __putback_lru_page(page, !ret);
+       __putback_lru_page(page, !!ret);
  put:
         put_page(page);
  out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

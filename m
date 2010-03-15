Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EADC26B015C
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 08:55:17 -0400 (EDT)
Received: by vws4 with SMTP id 4so742505vws.14
        for <linux-mm@kvack.org>; Mon, 15 Mar 2010 05:55:16 -0700 (PDT)
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100315112829.GI18274@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	 <1268412087-13536-3-git-send-email-mel@csn.ul.ie>
	 <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	 <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100315112829.GI18274@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 15 Mar 2010 21:48:49 +0900
Message-ID: <1268657329.1889.4.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-15 at 11:28 +0000, Mel Gorman wrote:
> The use after free looks like
> 
> 1. page_mapcount(page) was zero so anon_vma was no longer reliable
> 2. rcu lock taken but the anon_vma at this point can already be garbage because the
>    process exited
> 3. call try_to_unmap, looks up tha anon_vma and locks it. This causes problems
> 
> I thought the race would be closed but there is still a very tiny window there all
> right. The following alternative should close it. What do you think?
> 
>         if (PageAnon(page)) {
> 		rcu_read_lock();
> 
>                 /*
>                  * If the page has no mappings any more, just bail. An
>                  * unmapped anon page is likely to be freed soon but worse,
>                  * it's possible its anon_vma disappeared between when
>                  * the page was isolated and when we reached here while
>                  * the RCU lock was not held
>                  */
>                 if (!page_mapcount(page)) {
> 			rcu_read_unlock();
>                         goto uncharge;
> 		}
> 
>                 rcu_locked = 1;
>                 anon_vma = page_anon_vma(page);
>                 atomic_inc(&anon_vma->external_refcount);
>         }
> 
> The rcu_unlock label is not used here because the reference counts were not taken in
> the case where page_mapcount == 0.
> 

Looks good to me. 
Please, repost above code with your use-after-free scenario comment.


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

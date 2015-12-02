Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D2B376B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 17:25:06 -0500 (EST)
Received: by wmec201 with SMTP id c201so603713wme.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 14:25:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q20si45924wjw.68.2015.12.02.14.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 14:25:05 -0800 (PST)
Date: Wed, 2 Dec 2015 14:25:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg, vmscan: Do not wait for writeback if killed
Message-Id: <20151202142503.0921c0d6e06394ff7dff85fa@linux-foundation.org>
In-Reply-To: <1449066378-4764-1-git-send-email-mhocko@kernel.org>
References: <1449066378-4764-1-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed,  2 Dec 2015 15:26:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> Legacy memcg reclaim waits for pages under writeback to prevent from a
> premature oom killer invocation because there was no memcg dirty limit
> throttling implemented back then.
> 
> This heuristic might complicate situation when the writeback cannot make
> forward progress because of the global OOM situation. E.g. filesystem
> backed by the loop device relies on the underlying filesystem hosting
> the image to make forward progress which cannot be guaranteed and so
> we might end up triggering OOM killer to resolve the situation. If the
> oom victim happens to be the task stuck in wait_on_page_writeback in the
> memcg reclaim then we are basically deadlocked.
> 
> Introduce wait_on_page_writeback_killable and use it in this path to
> prevent from the issue. shrink_page_list will back off if the wait
> was interrupted.
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1021,10 +1021,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  			/* Case 3 above */
>  			} else {
> +				int ret;
> +
>  				unlock_page(page);
> -				wait_on_page_writeback(page);
> +				ret = wait_on_page_writeback_killable(page);
>  				/* then go back and try same page again */
>  				list_add_tail(&page->lru, page_list);
> +
> +				/*
> +				 * We've got killed while waiting here so
> +				 * expedite our way out from the reclaim
> +				 */
> +				if (ret)
> +					break;
>  				continue;
>  			}
>  		}

This function is 350 lines long and it takes a bit of effort to work
out what that `break' is breaking from and where it goes next.  I think
you want a "goto keep_killed" here for consistency and sanity.

Also, there's high risk here of a pending signal causing the code to
fall into some busy loop where it repeatedly tries to do something but
then bales out without doing it.  It's unobvious how this change avoids
such things.  (Maybe it *does* avoid such things, but it should be
obvious!).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

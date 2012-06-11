Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 3077B6B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 18:49:34 -0400 (EDT)
Message-ID: <4FD675FE.1060202@kernel.org>
Date: Tue, 12 Jun 2012 07:49:34 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: do not use page_count without a page pin
References: <1339373872-31969-1-git-send-email-minchan@kernel.org> <4FD59C31.6000606@jp.fujitsu.com> <20120611074440.GI3094@redhat.com> <20120611133043.GA2340@barrios> <20120611144132.GT3094@redhat.com>
In-Reply-To: <20120611144132.GT3094@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On 06/11/2012 11:41 PM, Andrea Arcangeli wrote:

> Hi Minchan,
> 
> On Mon, Jun 11, 2012 at 10:30:43PM +0900, Minchan Kim wrote:
>> AFAIUC, you mean we have to increase reference count of head page?
>> If so, it's not in __count_immobile_pages because it is already race-likely function
>> so it shouldn't be critical although race happens.
> 
> I meant, shouldn't we take into account the full size? If it's in the
> lru the whole thing can be moved away.
> 
>   if (!PageLRU(page)) {
>      nr_pages = hpage_nr_pages(page);
>      barrier();


Could you explain why we need barrier?

>      found += nr_pages;
>      iter += nr_pages-1;
>   }
> 


Thanks for the explain.

For the normal pages, the logic accounts it as "non-movable pages" so for the consistency,
it seems you're right. But let's think about a bit.

If THP page isn't LRU and it's still PageTransHuge, I think it's rather rare and
although it happens, it means migration/reclaimer is about to split or isolate/putback
so it ends up making THP page movable pages.

IMHO, it would be better to account it by movable pages.
What do you think about it?

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

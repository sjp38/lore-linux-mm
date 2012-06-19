Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id BF7146B006E
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:29:43 -0400 (EDT)
Message-ID: <4FE0C514.4040807@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 14:29:40 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V5 4/5] mm, vmscan: fix do_try_to_free_pages() livelock
References: <1340038051-29502-1-git-send-email-yinghan@google.com> <1340038051-29502-4-git-send-email-yinghan@google.com>
In-Reply-To: <1340038051-29502-4-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghan@google.com
Cc: mhocko@suse.cz, hannes@cmpxchg.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, dhillf@gmail.com, hughd@google.com, dan.magenheimer@oracle.com, akpm@linux-foundation.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com

On 6/18/2012 12:47 PM, Ying Han wrote:
> Currently, do_try_to_free_pages() can enter livelock. Because of,
> now vmscan has two conflicted policies.
> 
> 1) kswapd sleep when it couldn't reclaim any page even though
>    reach priority 0. This is because to avoid kswapd() infinite
>    loop. That said, kswapd assume direct reclaim makes enough
>    free pages either regular page reclaim or oom-killer.
>    This logic makes kswapd -> direct-reclaim dependency.
> 2) direct reclaim continue to reclaim without oom-killer until
>    kswapd turn on zone->all_unreclaimble. This is because
>    to avoid too early oom-kill.
>    This logic makes direct-reclaim -> kswapd dependency.
> 
> In worst case, direct-reclaim may continue to page reclaim forever
> when kswapd is slept and any other thread don't wakeup kswapd.
> 
> We can't turn on zone->all_unreclaimable because this is racy.
> direct reclaim path don't take any lock. Thus this patch removes
> zone->all_unreclaimable field completely and recalculates every
> time.
> 
> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
> directly and kswapd continue to use zone->all_unreclaimable. Because,
> it is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
> zone->all_unreclaimable as a name) describes the detail.
> 
> Reported-by: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Reported-by: Ying Han <yinghan@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>

Please drop this. I've got some review comment about this patch and
i need respin. but thank you for paying attention this.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

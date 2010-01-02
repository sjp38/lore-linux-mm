Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 01BA260021B
	for <linux-mm@kvack.org>; Sat,  2 Jan 2010 00:21:37 -0500 (EST)
Received: by iwn41 with SMTP id 41so9518736iwn.12
        for <linux-mm@kvack.org>; Fri, 01 Jan 2010 21:21:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1262387986.16572.234.camel@laptop>
References: <1262339141-4682-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
	 <1262387986.16572.234.camel@laptop>
Date: Sat, 2 Jan 2010 14:21:36 +0900
Message-ID: <2f11576a1001012121o4f09d30n6dba925e74099da1@mail.gmail.com>
Subject: Re: [PATCH] mm, lockdep: annotate reclaim context to zone reclaim too
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

2010/1/2 Peter Zijlstra <peterz@infradead.org>:
> On Fri, 2010-01-01 at 18:45 +0900, KOSAKI Motohiro wrote:
>> Commit cf40bd16fd (lockdep: annotate reclaim context) introduced reclaim
>> context annotation. But it didn't annotate zone reclaim. This patch do it.
>
> And yet you didn't CC anyone involved in that patch, nor explain why you
> think it necessary, massive FAIL.
>
> The lockdep annotations cover all of kswapd() and direct reclaim through
> __alloc_pages_direct_reclaim(). So why would you need an explicit
> annotation in __zone_reclaim()?

Thanks CCing. The point is zone-reclaim doesn't use
__alloc_pages_direct_reclaim.
current call graph is

__alloc_pages_nodemask
    get_page_from_freelist
        zone_reclaim()
    __alloc_pages_slowpath
        __alloc_pages_direct_reclaim
            try_to_free_pages

Actually, if zone_reclaim_mode=1, VM never call
__alloc_pages_direct_reclaim in usual VM pressure.
Thus I think zone-reclaim should be annotated explicitly too.
I know almost user don't use zone reclaim mode. but explicit
annotation doesn't have any demerit, I think.

Am I missing anything?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

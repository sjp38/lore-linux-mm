Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 7D13A6B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 23:52:35 -0400 (EDT)
Message-ID: <514BD56F.6050709@redhat.com>
Date: Thu, 21 Mar 2013 23:52:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd reclaims
 at each priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-2-git-send-email-mgorman@suse.de> <20130321155705.GA27848@cmpxchg.org> <514BA04D.2090002@gmail.com>
In-Reply-To: <514BA04D.2090002@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/21/2013 08:05 PM, Will Huck wrote:

> One offline question, how to understand this in function balance_pgdat:
> /*
>   * Do some background aging of the anon list, to give
>   * pages a chance to be referenced before reclaiming.
>   */
> age_acitve_anon(zone, &sc);

The anon lrus use a two-handed clock algorithm. New anonymous pages
start off on the active anon list. Older anonymous pages get moved
to the inactive anon list.

If they get referenced before they reach the end of the inactive anon
list, they get moved back to the active list.

If we need to swap something out and find a non-referenced page at the
end of the inactive anon list, we will swap it out.

In order to make good pageout decisions, pages need to stay on the
inactive anon list for a longer time, so they have plenty of time to
get referenced, before the reclaim code looks at them.

To achieve that, we will move some active anon pages to the inactive
anon list even when we do not want to swap anything out - as long as
the inactive anon list is below its target size.

Does that make sense?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

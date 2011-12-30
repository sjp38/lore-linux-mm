Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 9D4816B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 19:24:22 -0500 (EST)
Received: by qcsd17 with SMTP id d17so9933399qcs.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 16:24:21 -0800 (PST)
Message-ID: <4EFD04B2.7050407@gmail.com>
Date: Thu, 29 Dec 2011 19:24:18 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282037000.1362@eggly.anvils> <20111229145548.e34cb2f3.akpm@linux-foundation.org> <alpine.LSU.2.00.1112291510390.4888@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112291510390.4888@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org

(12/29/11 6:27 PM), Hugh Dickins wrote:
> On Thu, 29 Dec 2011, Andrew Morton wrote:
>> On Wed, 28 Dec 2011 20:39:36 -0800 (PST)
>> Hugh Dickins<hughd@google.com>  wrote:
>>
>>> Replace pagevecs in putback_lru_pages() and move_active_pages_to_lru()
>>> by lists of pages_to_free
>>
>> One effect of the pagevec handling was to limit lru_lock hold times and
>> interrupt-disabled times.
>>
>> This patch removes that upper bound and has the potential to cause
>> various latency problems when processing large numbers of pages.
>>
>> The affected functions have rather a lot of callers.  I don't think
>> that auditing all these callers and convincing ourselves that none of
>> them pass in 10,000 pages is sufficient, because that doesn't prevent us
>> from introducing such latency problems as the MM code evolves.
>
> That's an interesting slant on it, that hadn't crossed my mind;
> but it looks like intervening changes have answered that concern.
>
> putback_lru_pages() has one caller, shrink_inactive_list();
> move_active_pages_to_lru() has one caller, shrink_active_list().
> Following those back, they're in all cases capped to SWAP_CLUSTER_MAX
> pages per call.  That's 32 pages, not so very much more than the 14
> page limit the pagevecs were imposing.
>
> And both shrink_inactive_list() and shrink_active_list() gather these
> pages with isolate_lru_pages(), which does not drop lock or enable
> interrupts at all - probably why the SWAP_CLUSTER_MAX cap got imposed.

When lumpy reclaim occur, isolate_lru_pages() gather much pages than
SWAP_CLUSTER_MAX. However, at that time, I think this patch behave
better than old. If we release and retake zone lock per 14 pages,
other tasks can easily steal a part of lumpy reclaimed pages. and then
long latency wrongness will be happen when system is under large page
memory allocation pressure. That's the reason why I posted very similar 
patch a long time ago.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D69676B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 15:40:58 -0500 (EST)
Received: by bkty12 with SMTP id y12so7587142bkt.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 12:40:57 -0800 (PST)
Message-ID: <4F440154.7010403@openvz.org>
Date: Wed, 22 Feb 2012 00:40:52 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 6/10] mm/memcg: take care over pc->mem_cgroup
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201533260.23274@eggly.anvils> <4F4331BC.70205@openvz.org> <alpine.LSU.2.00.1202211117340.1858@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1202211117340.1858@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:
> On Tue, 21 Feb 2012, Konstantin Khlebnikov wrote:
>>
>> But just one question: how appears uncharged pages in mem-cg lru lists?
>
> One way is swapin readahead pages, which cannot be charged to a memcg
> until they're "claimed"; but we do need them visible on lru, otherwise
> memory pressure couldn't reclaim them when necessary.

Ok, this is really reasonable.

>
> Another way is simply that uncharging has not historically removed the
> page from lru list if it's on.  I usually assume that's an optimization:
> why bother to get lru locks and take it off (and put it on the root lru?
> if we don't, we're assuming it's will be freed very shortly - I'm not
> sure that's always a good assumption), if freeing the page will usually
> do that for us (without having to change lrus).
>
> If I thought for longer, I might come up with other scenarios.
>
>> Maybe we can forbid this case and uncharge these pages right in
>> __page_cache_release() and release_pages() at final removing from LRU.
>> This is how my old mem-controller works. There pages in lru are always
>> charged.
>
> As things stand, that would mean lock_page_cgroup() has to disable irqs
> everywhere.  I'm not sure of the further ramifications of moving uncharge
> to __page_cache_release() and release_pages().  I don't think a change
> like that is out of the question, but it's certainly a bigger change
> than I'd like to consider in this series.

Ok. I have another big question: Why we remove pages from lru at last put_page()?

Logically we can remove them in truncate_inode_pages_range() for file
and in free_pages_and_swap_cache() or something at last unmap for anon.
Pages are unreachable after that, they never become alive again.
Reclaimer also cannot reclaim them in this state, so there no reasons for keeping them in lru.
Into those two functions pages come in large batches, so we can remove them more effectively,
currently they are likely to be removed right in this place, just because release_pages() drops
last references, but we can do this lru remove unconditionally.
Plus it never happens in irq context, so lru_lock can be converted to irq-unsafe in some distant future.

>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

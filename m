Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0AD0F6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 07:31:17 -0500 (EST)
Received: by yx-out-1718.google.com with SMTP id 4so185705yxp.26
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 04:31:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090210210520.7004.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090210204210.6FEF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <28c262360902100403m772576afp3c9212157dc9fcd@mail.gmail.com>
	 <20090210210520.7004.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Tue, 10 Feb 2009 21:31:04 +0900
Message-ID: <28c262360902100431l4a5977e7p9c5152882f09dcf9@mail.gmail.com>
Subject: Re: [RFC] vmscan: initialize sc->nr_reclaimed in do_try_to_free_pages()
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 9:06 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>> > {
>> >        /* Minimum pages needed in order to stay on node */
>> >        const unsigned long nr_pages = 1 << order;
>> >        struct task_struct *p = current;
>> >        struct reclaim_state reclaim_state;
>> >        int priority;
>> >        struct scan_control sc = {
>> >                .may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
>> >                .may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>> >                .swap_cluster_max = max_t(unsigned long, nr_pages,
>> >                                        SWAP_CLUSTER_MAX),
>> >                .gfp_mask = gfp_mask,
>> >                .swappiness = vm_swappiness,
>> >                .isolate_pages = isolate_pages_global,
>> > +               .nr_reclaimed = 0;
>> >        };
>>
>> Hmm.. I missed that.  Thanks.
>> There is one in shrink_all_memory.
>
> No.
> __zone_reclaim isn't a part of shrink_all_memory().
> Currently, shrink_all_memory() don't use sc.nr_reclaimed member.
> (maybe, it's another wrong thing ;)

Hmm.. You're right.
As Johannes pointed out,
too many page shrinking can degrade resume performance.

We need to bale out in shrink_all_memory.
Other people, thought ?

-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

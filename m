Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2D6D56B0071
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 23:05:34 -0500 (EST)
Received: by pzk34 with SMTP id 34so14140492pzk.11
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 20:05:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100112022708.GA21621@localhost>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com>
	 <1263191277-30373-1-git-send-email-shijie8@gmail.com>
	 <20100111153802.f3150117.minchan.kim@barrios-desktop>
	 <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100112022708.GA21621@localhost>
Date: Tue, 12 Jan 2010 13:05:32 +0900
Message-ID: <28c262361001112005s745e5ecj9fd6ae3d0d997477@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
	memory free
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 2010 at 11:27 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> On Tue, Jan 12, 2010 at 09:47:08AM +0900, KAMEZAWA Hiroyuki wrote:
>> > Thanks, Huang.
>> >
>> > Frankly speaking, I am not sure this ir right way.
>> > This patch is adding to fine-grained locking overhead
>> >
>> > As you know, this functions are one of hot pathes.
>> > In addition, we didn't see the any problem, until now.
>> > It means out of synchronization in ZONE_ALL_UNRECLAIMABLE
>> > and pages_scanned are all right?
>> >
>> > If it is, we can move them out of zone->lock, too.
>> > If it isn't, we need one more lock, then.
>> >
>> I don't want to see additional spin_lock, here.
>>
>> About ZONE_ALL_UNRECLAIMABLE, it's not necessary to be handled in atomic way.
>> If you have concerns with other flags, please modify this with single word,
>> instead of a bit field.
>
> I'd second it. It's not a big problem to reset ZONE_ALL_UNRECLAIMABLE
> and pages_scanned outside of zone->lru_lock.
>
> Clear of ZONE_ALL_UNRECLAIMABLE is already atomic; if we lose one

I'd second it? What's meaning? I can't understand your point since I am not
english native.

BTW,
Hmm. It's not atomic as Kame pointed out.

Now, zone->flags have several bit.
 * ZONE_ALL_UNRECLAIMALBE
 * ZONE_RECLAIM_LOCKED
 * ZONE_OOM_LOCKED.

I think this flags are likely to race when the memory pressure is high.
If we don't prevent race, concurrent reclaim and killing could be happened.
So I think reset zone->flags outside of zone->lock would make our efforts which
prevent current reclaim and killing invalidate.


> Thanks,
> Fengguang
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

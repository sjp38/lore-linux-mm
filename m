Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A40EF6B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 13:48:09 -0400 (EDT)
Received: by lahi5 with SMTP id i5so3501650lah.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 10:48:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FDAE3CC.60801@kernel.org>
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com>
	<20120614145716.GA2097@barrios>
	<CAHGf_=qcA5OfuNgk0BiwyshcLftNWoPfOO_VW9H6xQTX2tAbuA@mail.gmail.com>
	<4FDAE3CC.60801@kernel.org>
Date: Sat, 16 Jun 2012 23:18:07 +0530
Message-ID: <CAEtiSavv8nRAFk6VZEgeCMYicjBPy4244+2KQhng5Pq9bxcX5A@mail.gmail.com>
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
From: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, frank.rowand@am.sony.com, tim.bird@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com

On Fri, Jun 15, 2012 at 12:57 PM, Minchan Kim <minchan@kernel.org> wrote:

>>
>> pgdat_balanced() doesn't recognized zone. Therefore kswapd may sleep
>> if node has multiple zones. Hm ok, I realized my descriptions was
>> slightly misleading. priority 0 is not needed. bakance_pddat() calls
>> pgdat_balanced()
>> every priority. Most easy case is, movable zone has a lot of free pages and
>> normal zone has no reclaimable page.
>>
>> btw, current pgdat_balanced() logic seems not correct. kswapd should
>> sleep only if every zones have much free pages than high water mark
>> _and_ 25% of present pages in node are free.
>>
>
>
> Sorry. I can't understand your point.
> Current kswapd doesn't sleep if relevant zones don't have free pages above high watermark.
> It seems I am missing your point.
> Please anybody correct me.

Since currently direct reclaim is given up based on
zone->all_unreclaimable flag,
so for e.g in one of the scenarios:

Lets say system has one node with two zones (NORMAL and MOVABLE) and we
hot-remove the all the pages of the MOVABLE zone.

While migrating pages during memory hot-unplugging, the allocation function
(for new page to which the page in MOVABLE zone would be moved)  can end up
looping in direct reclaim path for ever.

This is so because when most of the pages in the MOVABLE zone have
been migrated,
the zone now contains lots of free memory (basically above low watermark)
BUT all are in MIGRATE_ISOLATE list of the buddy list.

So kswapd() would not balance this zone as free pages are above low watermark
(but all are in isolate list). So zone->all_unreclaimable flag would
never be set for this zone
and allocation function would end up looping forever. (assuming the
zone NORMAL is
left with no reclaimable memory)


Regards,
Aaditya Kumar
Sony India Software Centre,
Bangalore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

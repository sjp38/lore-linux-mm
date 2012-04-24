Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id C28086B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 13:17:42 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so948490lbb.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 10:17:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F96D6EE.6000809@redhat.com>
References: <1335214564-17619-1-git-send-email-yinghan@google.com>
	<CAHGf_=pGhtieRpUqbF4GmAKt5XXhf_2y8c+EzGNx-cgqPNvfJw@mail.gmail.com>
	<CALWz4ix+MC_NuNdvQU3T8BhP+BULPLktLyNQ8osnrMOa2nfhdw@mail.gmail.com>
	<4F960257.9090509@kernel.org>
	<CALWz4izoOYtNfRN3VBLSF7pyYyvjBPyiy865Xf+wvsCFwM6A7A@mail.gmail.com>
	<4F96D6EE.6000809@redhat.com>
Date: Tue, 24 Apr 2012 10:17:40 -0700
Message-ID: <CALWz4iynFr02wzpB5k7nJasGAmHVEOtp56Lo7m4bRHoNgDEkvQ@mail.gmail.com>
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Apr 24, 2012 at 9:38 AM, Rik van Riel <riel@redhat.com> wrote:
> On 04/24/2012 12:36 PM, Ying Han wrote:
>
>> However, what if B frees a pages everytime before pages_scanned
>> reaches the point, then we won't set zone->all_unreclaimable at all.
>> If so, we reaches a livelock here...
>
>
> If B keeps freeing pages, surely A will get a successful
> allocation and there will not be a livelock?

Ah, that is another piece of puzzle. We suspect the zone is under
min_watermark due to previous alloc_flags (ALLOC_NO_WATERMARKS) and B
returns the page under min which can not be allocated by A.

Now we reset the zone->pages_scanned on freeing page regardless of the
watermarks, so it is possible that zone is under min_watermark but
!zone->all_unreclaimable.

--Ying

>
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

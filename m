Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 03E9B9000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 05:08:05 -0400 (EDT)
Received: by vws4 with SMTP id 4so1653200vws.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 02:08:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427173922.4d65534b.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<b7bcce639e9b9bf515431cda79b15d482f889ff2.1303833418.git.minchan.kim@gmail.com>
	<20110427173922.4d65534b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 18:08:04 +0900
Message-ID: <BANLkTikNa+Bq3PjXwX12-uKaNjFRrwdhaQ@mail.gmail.com>
Subject: Re: [RFC 8/8] compaction: make compaction use in-order putback
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 5:39 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 01:25:25 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Compaction is good solution to get contiguos page but it makes
>> LRU churing which is not good.
>> This patch makes that compaction code use in-order putback so
>> after compaction completion, migrated pages are keeping LRU ordering.
>>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0mm/compaction.c | =C2=A0 22 +++++++++++++++-------
>> =C2=A01 files changed, 15 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index a2f6e96..480d2ac 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -211,11 +211,11 @@ static void isolate_freepages(struct zone *zone,
>> =C2=A0/* Update the number of anon and file isolated pages in the zone *=
/
>> =C2=A0static void acct_isolated(struct zone *zone, struct compact_contro=
l *cc)
>> =C2=A0{
>> - =C2=A0 =C2=A0 struct page *page;
>> + =C2=A0 =C2=A0 struct pages_lru *pages_lru;
>> =C2=A0 =C2=A0 =C2=A0 unsigned int count[NR_LRU_LISTS] =3D { 0, };
>>
>> - =C2=A0 =C2=A0 list_for_each_entry(page, &cc->migratepages, lru) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int lru =3D page_lru_base_ty=
pe(page);
>> + =C2=A0 =C2=A0 list_for_each_entry(pages_lru, &cc->migratepages, lru) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int lru =3D page_lru_base_ty=
pe(pages_lru->page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count[lru]++;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> @@ -281,6 +281,7 @@ static unsigned long isolate_migratepages(struct zon=
e *zone,
>> =C2=A0 =C2=A0 =C2=A0 spin_lock_irq(&zone->lru_lock);
>> =C2=A0 =C2=A0 =C2=A0 for (; low_pfn < end_pfn; low_pfn++) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct pages_lru *pages_lru;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool locked =3D true;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* give a chance to irq=
s before checking need_resched() */
>> @@ -334,10 +335,16 @@ static unsigned long isolate_migratepages(struct z=
one *zone,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages_lru =3D kmalloc(sizeof=
(struct pages_lru), GFP_ATOMIC);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pages_lru)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
continue;
>
> Hmm, can't we use fixed size of statically allocated pages_lru, per-node =
or
> per-zone ? I think using kmalloc() in memory reclaim path is risky.

Yes. we can enhance it with pagevec-like approach.
It's my TODO list.  :)

In compaction POV, it is used by reclaiming big order pages so most of
time order-0 pages are enough. It's basic assumption of compaction so
it shouldn't be a problem.

Thanks for the review, Kame.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

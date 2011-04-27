Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DAE5E6B0022
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:43:11 -0400 (EDT)
Received: by wwi36 with SMTP id 36so2113699wwi.26
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:43:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427173450.82cef21e.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
	<20110427173450.82cef21e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Apr 2011 08:43:08 +0900
Message-ID: <BANLkTi=i+LjmmPYjYBy8G4btmGz5Qu-rZA@mail.gmail.com>
Subject: Re: [RFC 6/8] In order putback lru core
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 5:34 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 01:25:23 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> This patch defines new APIs to putback the page into previous position o=
f LRU.
>> The idea is simple.
>>
>> When we try to putback the page into lru list and if friends(prev, next)=
 of the pages
>> still is nearest neighbor, we can insert isolated page into prev's next =
instead of
>> head of LRU list. So it keeps LRU history without losing the LRU informa=
tion.
>>
>> Before :
>> =C2=A0 =C2=A0 =C2=A0 LRU POV : H - P1 - P2 - P3 - P4 -T
>>
>> Isolate P3 :
>> =C2=A0 =C2=A0 =C2=A0 LRU POV : H - P1 - P2 - P4 - T
>>
>> Putback P3 :
>> =C2=A0 =C2=A0 =C2=A0 if (P2->next =3D=3D P4)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 putback(P3, P2);
>> =C2=A0 =C2=A0 =C2=A0 So,
>> =C2=A0 =C2=A0 =C2=A0 LRU POV : H - P1 - P2 - P3 - P4 -T
>>
>> For implement, we defines new structure pages_lru which remebers
>> both lru friend pages of isolated one and handling functions.
>>
>> But this approach has a problem on contiguous pages.
>> In this case, my idea can not work since friend pages are isolated, too.
>> It means prev_page->next =3D=3D next_page always is false and both pages=
 are not
>> LRU any more at that time. It's pointed out by Rik at LSF/MM summit.
>> So for solving the problem, I can change the idea.
>> I think we don't need both friend(prev, next) pages relation but
>> just consider either prev or next page that it is still same LRU.
>> Worset case in this approach, prev or next page is free and allocate new
>> so it's in head of LRU and our isolated page is located on next of head.
>> But it's almost same situation with current problem. So it doesn't make =
worse
>> than now and it would be rare. But in this version, I implement based on=
 idea
>> discussed at LSF/MM. If my new idea makes sense, I will change it.
>>
>
> I think using only 'next'(prev?) pointer will be enough.

I think so but let's wait other's opinion. :)
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

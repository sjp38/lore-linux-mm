Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 44D4A90010C
	for <linux-mm@kvack.org>; Sun,  1 May 2011 19:00:49 -0400 (EDT)
Received: by qyk30 with SMTP id 30so3482555qyk.14
        for <linux-mm@kvack.org>; Sun, 01 May 2011 16:00:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=c2tBcXJnFi-i4r1_ADiMFebmxMA@mail.gmail.com>
References: <cover.1304261567.git.minchan.kim@gmail.com>
	<c7a7b3ceafe4fdc4bc038774374504827c01481f.1304261567.git.minchan.kim@gmail.com>
	<BANLkTi=c2tBcXJnFi-i4r1_ADiMFebmxMA@mail.gmail.com>
Date: Mon, 2 May 2011 08:00:46 +0900
Message-ID: <BANLkTim1k-wGA1j9Cv1scCNR_-5b9BqESQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] Check PageUnevictable in lru_deactivate_fn
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>

On Mon, May 2, 2011 at 7:10 AM, Ying Han <yinghan@google.com> wrote:
> On Sun, May 1, 2011 at 8:03 AM, Minchan Kim <minchan.kim@gmail.com> wrote=
:
>> The lru_deactivate_fn should not move page which in on unevictable lru
>> into inactive list. Otherwise, we can meet BUG when we use isolate_lru_p=
ages
>> as __isolate_lru_page could return -EINVAL.
>> It's really BUG and let's fix it.
>>
>> Reported-by: Ying Han <yinghan@google.com>
>> Tested-by: Ying Han <yinghan@google.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0mm/swap.c | =C2=A0 =C2=A03 +++
>> =C2=A01 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/swap.c b/mm/swap.c
>> index a83ec5a..2e9656d 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -429,6 +429,9 @@ static void lru_deactivate_fn(struct page *page, voi=
d *arg)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!PageLRU(page))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
>>
>> + =C2=A0 =C2=A0 =C2=A0 if (PageUnevictable(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Some processes are using the page */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page_mapped(page))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
>> --
>> 1.7.1
>
> Thanks Minchan for the fix, and i haven't been able to reproducing the
> issue after applying the patch.

Thanks for the help, Ying.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

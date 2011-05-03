Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4EA6B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 20:30:01 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1960579qyk.14
        for <linux-mm@kvack.org>; Mon, 02 May 2011 17:29:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110502193820.2D60.A69D9226@jp.fujitsu.com>
References: <cover.1304261567.git.minchan.kim@gmail.com>
	<dc54a5771cf1f580a91d16816100d4a2bcf2cdf5.1304261567.git.minchan.kim@gmail.com>
	<20110502193820.2D60.A69D9226@jp.fujitsu.com>
Date: Tue, 3 May 2011 09:29:59 +0900
Message-ID: <BANLkTika5G_7Z8t-ED4RcYfKoYpLnZsjSg@mail.gmail.com>
Subject: Re: [PATCH 2/2] Filter unevictable page out in deactivate_page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>

Hi KOSAKI,

On Mon, May 2, 2011 at 7:37 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> It's pointless that deactive_page's pagevec operation about
>> unevictable page as it's nop.
>> This patch removes unnecessary overhead which might be a bit problem
>> in case that there are many unevictable page in system(ex, mprotect work=
load)
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0mm/swap.c | =C2=A0 =C2=A09 +++++++++
>> =C2=A01 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 2e9656d..b707694 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -511,6 +511,15 @@ static void drain_cpu_pagevecs(int cpu)
>> =C2=A0 */
>> =C2=A0void deactivate_page(struct page *page)
>> =C2=A0{
>> +
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* In workload which system has many unevictable pa=
ge(ex, mprotect),
>> + =C2=A0 =C2=A0 =C2=A0* unevictalge page deactivation for accelerating r=
eclaim
>> + =C2=A0 =C2=A0 =C2=A0* is pointless.
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 if (PageUnevictable(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> +
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@=
jp.fujitsu.com>
>

Thanks!

>
> btw, I think we should check PageLRU too.
>

Yes. I remember you advised it when we push this patch but I didn't.
That's because I think most of pages in such context would be LRU as
they are cached pages.
So IMO, PageLRU checking in deactivate_page couldn't help much.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

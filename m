Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id D78116B13F2
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 10:50:33 -0500 (EST)
Received: by eekc13 with SMTP id c13so1353559eek.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 07:50:32 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 08/15] mm: mmzone: MIGRATE_CMA migration type added
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <1328271538-14502-9-git-send-email-m.szyprowski@samsung.com>
 <CAJd=RBByc_wLEJTK66J4eY03CWnCoCRiwAeEYjXCZ5xEZhp3ag@mail.gmail.com>
Date: Fri, 03 Feb 2012 16:50:30 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v830ygma3l0zgt@mpn-glaptop>
In-Reply-To: <CAJd=RBByc_wLEJTK66J4eY03CWnCoCRiwAeEYjXCZ5xEZhp3ag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Hillf Danton <dhillf@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> On Fri, Feb 3, 2012 at 8:18 PM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index d5174c4..a6e7c64 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -45,6 +45,11 @@ static void map_pages(struct list_head *list)
>>        }
>>  }
>>
>> +static inline bool migrate_async_suitable(int migratetype)

On Fri, 03 Feb 2012 15:19:54 +0100, Hillf Danton <dhillf@gmail.com> wrot=
e:
> Just nitpick, since the helper is not directly related to what async m=
eans,
> how about migrate_suitable(int migrate_type) ?

I feel current name is better suited since it says that it's OK to scan =
this
block if it's an asynchronous compaction run.

>> +{
>> +       return is_migrate_cma(migratetype) || migratetype =3D=3D MIGR=
ATE_MOVABLE;
>> +}
>> +
>>  /*
>>  * Isolate free pages onto a private freelist. Caller must hold zone-=
>lock.
>>  * If @strict is true, will abort returning 0 on any invalid PFNs or =
non-free
>> @@ -277,7 +282,7 @@ isolate_migratepages_range(struct zone *zone, str=
uct compact_control *cc,
>>                 */
>>                pageblock_nr =3D low_pfn >> pageblock_order;
>>                if (!cc->sync && last_pageblock_nr !=3D pageblock_nr &=
&
>> -                               get_pageblock_migratetype(page) !=3D =
MIGRATE_MOVABLE) {
>> +                   migrate_async_suitable(get_pageblock_migratetype(=
page))) {
>
> Here compaction looks corrupted if CMA not enabled, Mel?

Damn, yes, this should be !migrate_async_suitable(...).  Sorry about tha=
t.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

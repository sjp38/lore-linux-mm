Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 591CF6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:06:53 -0500 (EST)
Received: by eekc13 with SMTP id c13so1636156eek.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 05:06:51 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 08/15] mm: mmzone: MIGRATE_CMA migration type added
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-9-git-send-email-m.szyprowski@samsung.com>
 <20120130123542.GL25268@csn.ul.ie>
Date: Mon, 30 Jan 2012 14:06:50 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v8wepotk3l0zgt@mpn-glaptop>
In-Reply-To: <20120130123542.GL25268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

> On Thu, Jan 26, 2012 at 10:00:50AM +0100, Marek Szyprowski wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>> @@ -875,10 +895,15 @@ struct page *__rmqueue_smallest(struct zone *zo=
ne, unsigned int order,
>>   * This array describes the order lists are fallen back to when
>>   * the free lists for the desirable migrate type are depleted
>>   */
>> -static int fallbacks[MIGRATE_TYPES][3] =3D {
>> +static int fallbacks[MIGRATE_TYPES][4] =3D {
>>  	[MIGRATE_UNMOVABLE]   =3D { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,  =
 MIGRATE_RESERVE },
>>  	[MIGRATE_RECLAIMABLE] =3D { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,  =
 MIGRATE_RESERVE },
>> +#ifdef CONFIG_CMA
>> +	[MIGRATE_MOVABLE]     =3D { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,=
 MIGRATE_CMA    , MIGRATE_RESERVE },

On Mon, 30 Jan 2012 13:35:42 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> This is a curious choice. MIGRATE_CMA is allowed to contain movable
> pages. By using MIGRATE_RECLAIMABLE and MIGRATE_UNMOVABLE for movable
> pages instead of MIGRATE_CMA, you increase the changes that unmovable
> pages will need to use MIGRATE_MOVABLE in the future which impacts
> fragmentation avoidance. I would recommend that you change this to
>
> { MIGRATE_CMA, MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE=
 }

At the beginning the idea was to try hard not to get pages from MIGRATE_=
CMA
allocated at all, thus it was put at the end of the fallbacks list, but =
on
a busy system this probably won't help anyway, so I'll change it per you=
r
suggestion.

>> @@ -1017,11 +1049,14 @@ __rmqueue_fallback(struct zone *zone, int ord=
er, int start_migratetype)
>>  			rmv_page_order(page);
>>
>>  			/* Take ownership for orders >=3D pageblock_order */
>> -			if (current_order >=3D pageblock_order)
>> +			if (current_order >=3D pageblock_order &&
>> +			    !is_pageblock_cma(page))
>>  				change_pageblock_range(page, current_order,
>>  							start_migratetype);
>>
>> -			expand(zone, page, order, current_order, area, migratetype);
>> +			expand(zone, page, order, current_order, area,
>> +			       is_migrate_cma(start_migratetype)
>> +			     ? start_migratetype : migratetype);
>>
>
> What is this check meant to be doing?
>
> start_migratetype is determined by allocflags_to_migratetype() and
> that never will be MIGRATE_CMA so is_migrate_cma(start_migratetype)
> should always be false.

Right, thanks!  This should be the other way around, ie.:

+			expand(zone, page, order, current_order, area,
+			       is_migrate_cma(migratetype)
+			     ? migratetype : start_migratetype);

I'll fix this and the calls to is_pageblock_cma().

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

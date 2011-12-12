Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C89636B0177
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:23:08 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so5029913vbb.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 06:23:07 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 01/11] mm: page_alloc: handle MIGRATE_ISOLATE in
 free_pcppages_bulk()
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-2-git-send-email-m.szyprowski@samsung.com>
 <20111212134235.GB3277@csn.ul.ie>
Date: Mon, 12 Dec 2011 15:23:02 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v6drko0p3l0zgt@mpn-glaptop>
In-Reply-To: <20111212134235.GB3277@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse
 Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

> On Fri, Nov 18, 2011 at 05:43:08PM +0100, Marek Szyprowski wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 9dd443d..58d1a2e 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -628,6 +628,18 @@ static void free_pcppages_bulk(struct zone *zone=
, int count,
>>  			page =3D list_entry(list->prev, struct page, lru);
>>  			/* must delete as __free_one_page list manipulates */
>>  			list_del(&page->lru);
>> +
>> +			/*
>> +			 * When page is isolated in set_migratetype_isolate()
>> +			 * function it's page_private is not changed since the
>> +			 * function has no way of knowing if it can touch it.
>> +			 * This means that when a page is on PCP list, it's
>> +			 * page_private no longer matches the desired migrate
>> +			 * type.
>> +			 */
>> +			if (get_pageblock_migratetype(page) =3D=3D MIGRATE_ISOLATE)
>> +				set_page_private(page, MIGRATE_ISOLATE);
>> +

On Mon, 12 Dec 2011 14:42:35 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> How much of a problem is this in practice?

IIRC, this lead to allocation being made from area marked as isolated
or some such.

> [...] I'd go as far to say that it would be preferable to drain the
> per-CPU lists after you set pageblocks MIGRATE_ISOLATE. The IPIs also =
have
> overhead but it will be incurred for the rare rather than the common c=
ase.

I'll look into that.

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

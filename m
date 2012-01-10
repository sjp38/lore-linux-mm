Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 66DA56B0068
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 10:04:14 -0500 (EST)
Received: by eeke53 with SMTP id e53so327114eek.14
        for <linux-mm@kvack.org>; Tue, 10 Jan 2012 07:04:12 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 02/11] mm: compaction: introduce
 isolate_{free,migrate}pages_range().
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-3-git-send-email-m.szyprowski@samsung.com>
 <20120110134351.GA3910@csn.ul.ie>
Date: Tue, 10 Jan 2012 16:04:10 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7vis8ap3l0zgt@mpn-glaptop>
In-Reply-To: <20120110134351.GA3910@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Tue, 10 Jan 2012 14:43:51 +0100, Mel Gorman <mel@csn.ul.ie> wrote:

> On Thu, Dec 29, 2011 at 01:39:03PM +0100, Marek Szyprowski wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>

>> +static unsigned long
>> +isolate_freepages_range(struct zone *zone,
>> +			unsigned long start_pfn, unsigned long end_pfn,
>> +			struct list_head *freelist)
>>  {
>> -	unsigned long zone_end_pfn, end_pfn;
>> -	int nr_scanned =3D 0, total_isolated =3D 0;
>> -	struct page *cursor;
>> -
>> -	/* Get the last PFN we should scan for free pages at */
>> -	zone_end_pfn =3D zone->zone_start_pfn + zone->spanned_pages;
>> -	end_pfn =3D min(blockpfn + pageblock_nr_pages, zone_end_pfn);
>> +	unsigned long nr_scanned =3D 0, total_isolated =3D 0;
>> +	unsigned long pfn =3D start_pfn;
>> +	struct page *page;
>>
>> -	/* Find the first usable PFN in the block to initialse page cursor =
*/
>> -	for (; blockpfn < end_pfn; blockpfn++) {
>> -		if (pfn_valid_within(blockpfn))
>> -			break;
>> -	}
>> -	cursor =3D pfn_to_page(blockpfn);
>> +	VM_BUG_ON(!pfn_valid(pfn));
>> +	page =3D pfn_to_page(pfn);
>
> The existing code is able to find the first usable PFN in a pageblock
> with pfn_valid_within(). It's allowed to do that because it knows
> the pageblock is valid so calling pfn_valid() is unnecessary.
>
> It is curious to change this to something that can sometimes BUG_ON
> !pfn_valid(pfn) instead of having a PFN walker that knows how to
> handle pfn_valid().

Actually, this walker seem redundant since one is already present in
isolate_freepages(), ie. if !pfn_valid(pfn) then the loop in
isolate_freepages() will =E2=80=9Ccontinue;=E2=80=9D and the function wi=
ll never get
called.

>> +cleanup:
>> +	/*
>> +	 * Undo what we have done so far, and return.  We know all pages fr=
om
>> +	 * [start_pfn, pfn) are free because we have just freed them.  If o=
ne of
>> +	 * the page in the range was not freed, we would end up here earlie=
r.
>> +	 */
>> +	for (; start_pfn < pfn; ++start_pfn)
>> +		__free_page(pfn_to_page(start_pfn));
>> +	return 0;
>
> This returns 0 even though you could have isolated some pages.

The loop's intention is to =E2=80=9Cunisolate=E2=80=9D (ie. free) anythi=
ng that got
isolated, so at the end number of isolated pages in in fact zero.

> Overall, there would have been less contortion if you
> implemented isolate_freepages_range() in terms of the existing
> isolate_freepages_block. Something that looked kinda like this not
> compiled untested illustration.
>
> static unsigned long isolate_freepages_range(struct zone *zone,
>                         unsigned long start_pfn, unsigned long end_pfn=
,
>                         struct list_head *list)
> {
>         unsigned long pfn =3D start_pfn;
>         unsigned long isolated;
>
>         for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D pageblock_nr_p=
ages) {
>                 if (!pfn_valid(pfn))
>                         continue;
>                 isolated +=3D isolate_freepages_block(zone, pfn, list)=
;
>         }
>
>         return isolated;
> }
>
> I neglected to update isolate_freepages_block() to take the end_pfn
> meaning it will in fact isolate too much but that would be easy to
> address.

This is not a problem since my isolate_freepages_range() implementation
can go beyond end_pfn, anyway.

Of course, the function taking end_pfn is an optimisation since it does
not have to compute zone_end each time.

> It would be up to yourself whether to shuffle the tracepoint
> around because with this example it will be triggered once per
> pageblock. You'd still need the cleanup code and freelist check in
> isolate_freepages_block() of course.
>
> The point is that it would minimise the disruption to the existing
> code and easier to get details like pfn_valid() right without odd
> contortions, more gotos than should be necessary and trying to keep
> pfn and page straight.

Even though I'd personally go with my approach, I see merit in your poin=
t,
so will change.

>>  }
>>
>>  /* Returns true if the page is within a block suitable for migration=
 to */

>> @@ -365,17 +403,49 @@ static isolate_migrate_t isolate_migratepages(s=
truct zone *zone,
>>  		nr_isolated++;
>>
>>  		/* Avoid isolating too much */
>> -		if (cc->nr_migratepages =3D=3D COMPACT_CLUSTER_MAX)
>> +		if (cc->nr_migratepages =3D=3D COMPACT_CLUSTER_MAX) {
>> +			++low_pfn;
>>  			break;
>> +		}
>>  	}
>
> This minor optimisation is unrelated to the implementation of
> isolate_migratepages_range() and should be in its own patch.

It's actually not a mere minor optimisation, but rather making the funct=
ion work
according to the documentation added, ie. that it returns =E2=80=9CPFN o=
f the first page
that was not scanned=E2=80=9D.

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

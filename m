Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 462F16B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 13:28:20 -0500 (EST)
Received: by eaaa11 with SMTP id a11so1764044eaa.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 10:28:18 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [BUG] 3.2.2 crash in isolate_migratepages
References: <4F231A6B.1050607@oracle.com> <20120130090923.GD4065@suse.de>
 <4F26DE75.5050409@oracle.com>
Date: Mon, 30 Jan 2012 19:28:16 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v8wtleuf3l0zgt@mpn-glaptop>
In-Reply-To: <4F26DE75.5050409@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
Cc: linux-mm@kvack.org

> On 1/30/12 1:09 AM, Mel Gorman wrote:
>> The migrate_pfn is just below a memory hole and the free scanner is
>> beyond the hole. When isolate_migratepages started, it scans from
>> migrate_pfn to migrate_pfn+pageblock_nr_pages which is now in a memor=
y
>> hole. It checks pfn_valid() on the first PFN but then scans into the
>> hole where there are not necessarily valid struct pages.
>>
>> This patch ensures that isolate_migratepages calls pfn_valid when
>> necessary.
>>
>> Signed-off-by: Mel Gorman <mgorman@suse.de>

If anyone cares, this looks good to me, so:

Acked-by: Michal Nazarewicz <mina86@mina86.com>

>> ---
>>  mm/compaction.c |   13 +++++++++++++
>>  1 files changed, 13 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 899d956..edc1e26 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -313,6 +313,19 @@ static isolate_migrate_t isolate_migratepages(st=
ruct zone *zone,
>>  		} else if (!locked)
>>  			spin_lock_irq(&zone->lru_lock);
>>
>> +		/*
>> +		 * migrate_pfn does not necessarily start aligned to a
>> +		 * pageblock. Ensure that pfn_valid is called when moving
>> +		 * into a new MAX_ORDER_NR_PAGES range in case of large
>> +		 * memory holes within the zone
>> +		 */
>> +		if ((low_pfn & (MAX_ORDER_NR_PAGES - 1)) =3D=3D 0) {
>> +			if (!pfn_valid(low_pfn)) {
>> +				low_pfn +=3D MAX_ORDER_NR_PAGES - 1;
>> +				continue;
>> +			}
>> +		}
>> +
>>  		if (!pfn_valid_within(low_pfn))
>>  			continue;
>>  		nr_scanned++;

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

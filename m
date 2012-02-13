Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 752196B13F0
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 14:38:27 -0500 (EST)
Received: by dakp5 with SMTP id p5so5329431dak.8
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 11:38:26 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [Linaro-mm-sig] [PATCHv21 12/16] mm: trigger page reclaim in
 alloc_contig_range() to stabilise watermarks
References: <1328895151-5196-1-git-send-email-m.szyprowski@samsung.com>
 <1328895151-5196-13-git-send-email-m.szyprowski@samsung.com>
 <CAOCHtYi01NVp1j=MX+0-z7ygW5tJuoswn8eWTQp+0Z5mMGdeQw@mail.gmail.com>
Date: Mon, 13 Feb 2012 11:38:22 -0800
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v9mt58ch3l0zgt@mpn-glaptop>
In-Reply-To: <CAOCHtYi01NVp1j=MX+0-z7ygW5tJuoswn8eWTQp+0Z5mMGdeQw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Robert Nelson <robertcnelson@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel
 Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel
 Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse
 Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rob
 Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> On Fri, Feb 10, 2012 at 11:32 AM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
>> @@ -5637,6 +5642,56 @@ static int __alloc_contig_migrate_range(unsign=
ed long start, unsigned long end)
>>        return ret > 0 ? 0 : ret;
>>  }
>>
>> +/*
>> + * Update zone's cma pages counter used for watermark level calculat=
ion.
>> + */
>> +static inline void __update_cma_wmark_pages(struct zone *zone, int c=
ount)
>> +{
>> +       unsigned long flags;
>> +       spin_lock_irqsave(&zone->lock, flags);
>> +       zone->min_cma_pages +=3D count;
>> +       spin_unlock_irqrestore(&zone->lock, flags);
>> +       setup_per_zone_wmarks();
>> +}
>> +
>> +/*
>> + * Trigger memory pressure bump to reclaim some pages in order to be=
 able to
>> + * allocate 'count' pages in single page units. Does similar work as=

>> + *__alloc_pages_slowpath() function.
>> + */
>> +static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int co=
unt)
>> +{
>> +       enum zone_type high_zoneidx =3D gfp_zone(gfp_mask);
>> +       struct zonelist *zonelist =3D node_zonelist(0, gfp_mask);
>> +       int did_some_progress =3D 0;
>> +       int order =3D 1;
>> +       unsigned long watermark;
>> +
>> +       /*
>> +        * Increase level of watermarks to force kswapd do his job
>> +        * to stabilise at new watermark level.
>> +        */
>> +       __modify_min_cma_pages(zone, count);

On Mon, 13 Feb 2012 10:57:58 -0800, Robert Nelson <robertcnelson@gmail.c=
om> wrote:
> Hi Marek,   This ^^^ function doesn't seem to exist in this patchset,
> is it in another set posted to lkml?

This should read __update_cma_wmark_pages().  Sorry for the incorrect pa=
tch.

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

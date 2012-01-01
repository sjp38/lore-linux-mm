Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 1DA296B004D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 10:55:01 -0500 (EST)
Received: by eekc41 with SMTP id c41so16972242eek.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 07:54:59 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 01/11] mm: page_alloc: set_migratetype_isolate: drain PCP
 prior to isolating
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-2-git-send-email-m.szyprowski@samsung.com>
 <CAOtvUMeAVgDwRNsDTcG07ChYnAuNgNJjQ+sKALJ79=Ezikos-A@mail.gmail.com>
Date: Sun, 01 Jan 2012 16:54:38 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7ew5cvg3l0zgt@mpn-glaptop>
In-Reply-To: <CAOtvUMeAVgDwRNsDTcG07ChYnAuNgNJjQ+sKALJ79=Ezikos-A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

> On Thu, Dec 29, 2011 at 2:39 PM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>>
>> When set_migratetype_isolate() sets pageblock's migrate type, it does=

>> not change each page_private data.  This makes sense, as the function=

>> has no way of knowing what kind of information page_private stores.

>> A side effect is that instead of draining pages from all zones,
>> set_migratetype_isolate() now drain only pages from zone pageblock it=

>> operates on is in.

>> +/* Caller must hold zone->lock. */
>> +static void __zone_drain_local_pages(void *arg)
>> +{
>> +       struct per_cpu_pages *pcp;
>> +       struct zone *zone =3D arg;
>> +       unsigned long flags;
>> +
>> +       local_irq_save(flags);
>> +       pcp =3D &per_cpu_ptr(zone->pageset, smp_processor_id())->pcp;=

>> +       if (pcp->count) {
>> +               /* Caller holds zone->lock, no need to grab it. */
>> +               __free_pcppages_bulk(zone, pcp->count, pcp);
>> +               pcp->count =3D 0;
>> +       }
>> +       local_irq_restore(flags);
>> +}
>> +
>> +/*
>> + * Like drain_all_pages() but operates on a single zone.  Caller mus=
t
>> + * hold zone->lock.
>> + */
>> +static void __zone_drain_all_pages(struct zone *zone)
>> +{
>> +       on_each_cpu(__zone_drain_local_pages, zone, 1);
>> +}
>> +

On Sun, 01 Jan 2012 08:49:13 +0100, Gilad Ben-Yossef <gilad@benyossef.co=
m> wrote:
> Please consider whether sending an IPI to all processors in the system=

> and interrupting them is appropriate here.
>
> You seem to assume that it is probable that each CPU of the possibly
> 4,096 (MAXSMP on x86) has a per-cpu page for the specified zone,

I'm not really assuming that (in fact I expect what you fear, ie. that
most CPUs won't have pages from specified zone an PCP list), however,
I really need to make sure to get them off all PCP lists.

> otherwise you're just interrupting them out of doing something useful,=

> or save power idle for nothing.

Exactly what's happening now anyway.

> While that may or may not be a reasonable assumption for the general
> drain_all_pages that drains pcps from all zones, I feel it is less
> likely to be the right thing once you limit the drain to a single
> zone.

Currently, set_migratetype_isolate() seem to do more then it needs to,
ie. it drains all the pages even though all it cares about is a single
zone.

> Some background on my attempt to reduce "IPI noise" in the system in
> this context is probably useful here as
> well: https://lkml.org/lkml/2011/11/22/133

Looks interesting, I'm not entirely sure why it does not end up a race
condition, but in case of __zone_drain_all_pages() we already hold
zone->lock, so my fears are somehow gone..  I'll give it a try, and prep=
are
a patch for __zone_drain_all_pages().

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

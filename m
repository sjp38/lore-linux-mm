Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 6B0A16B002C
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 16:15:15 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so4415688wgb.26
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 13:15:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v9mt58ch3l0zgt@mpn-glaptop>
References: <1328895151-5196-1-git-send-email-m.szyprowski@samsung.com>
	<1328895151-5196-13-git-send-email-m.szyprowski@samsung.com>
	<CAOCHtYi01NVp1j=MX+0-z7ygW5tJuoswn8eWTQp+0Z5mMGdeQw@mail.gmail.com>
	<op.v9mt58ch3l0zgt@mpn-glaptop>
Date: Mon, 13 Feb 2012 15:15:13 -0600
Message-ID: <CAOCHtYjc39ThfrcAqdsxNf-bFqKzu=T8=O_W9Cg3cRNzQnX-OQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv21 12/16] mm: trigger page reclaim in
 alloc_contig_range() to stabilise watermarks
From: Robert Nelson <robertcnelson@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2012/2/13 Michal Nazarewicz <mina86@mina86.com>:
>> On Fri, Feb 10, 2012 at 11:32 AM, Marek Szyprowski
>> <m.szyprowski@samsung.com> wrote:
>>>
>>> @@ -5637,6 +5642,56 @@ static int __alloc_contig_migrate_range(unsigned
>>> long start, unsigned long end)
>>> =A0 =A0 =A0 return ret > 0 ? 0 : ret;
>>> =A0}
>>>
>>> +/*
>>> + * Update zone's cma pages counter used for watermark level calculatio=
n.
>>> + */
>>> +static inline void __update_cma_wmark_pages(struct zone *zone, int
>>> count)
>>> +{
>>> + =A0 =A0 =A0 unsigned long flags;
>>> + =A0 =A0 =A0 spin_lock_irqsave(&zone->lock, flags);
>>> + =A0 =A0 =A0 zone->min_cma_pages +=3D count;
>>> + =A0 =A0 =A0 spin_unlock_irqrestore(&zone->lock, flags);
>>> + =A0 =A0 =A0 setup_per_zone_wmarks();
>>> +}
>>> +
>>> +/*
>>> + * Trigger memory pressure bump to reclaim some pages in order to be
>>> able to
>>> + * allocate 'count' pages in single page units. Does similar work as
>>> + *__alloc_pages_slowpath() function.
>>> + */
>>> +static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int coun=
t)
>>> +{
>>> + =A0 =A0 =A0 enum zone_type high_zoneidx =3D gfp_zone(gfp_mask);
>>> + =A0 =A0 =A0 struct zonelist *zonelist =3D node_zonelist(0, gfp_mask);
>>> + =A0 =A0 =A0 int did_some_progress =3D 0;
>>> + =A0 =A0 =A0 int order =3D 1;
>>> + =A0 =A0 =A0 unsigned long watermark;
>>> +
>>> + =A0 =A0 =A0 /*
>>> + =A0 =A0 =A0 =A0* Increase level of watermarks to force kswapd do his =
job
>>> + =A0 =A0 =A0 =A0* to stabilise at new watermark level.
>>> + =A0 =A0 =A0 =A0*/
>>> + =A0 =A0 =A0 __modify_min_cma_pages(zone, count);
>
>
> On Mon, 13 Feb 2012 10:57:58 -0800, Robert Nelson <robertcnelson@gmail.co=
m>
> wrote:
>>
>> Hi Marek, =A0 This ^^^ function doesn't seem to exist in this patchset,
>> is it in another set posted to lkml?
>
>
> This should read __update_cma_wmark_pages(). =A0Sorry for the incorrect p=
atch.

Thanks Michal, that fixed it.. cma-v21 with Rob Clark's omapdrm works
great on the Beagle xM..

Regards

--=20
Robert Nelson
http://www.rcn-ee.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

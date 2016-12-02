Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33B416B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 07:32:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so2769611wma.2
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 04:32:18 -0800 (PST)
Received: from mail-wj0-x22c.google.com (mail-wj0-x22c.google.com. [2a00:1450:400c:c01::22c])
        by mx.google.com with ESMTPS id o9si2778135wmo.54.2016.12.02.04.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 04:32:17 -0800 (PST)
Received: by mail-wj0-x22c.google.com with SMTP id xy5so230749567wjc.0
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 04:32:16 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: alloc_contig: demote PFN busy message to debug level
In-Reply-To: <1480676263.17003.55.camel@pengutronix.de>
References: <20161202095742.32449-1-l.stach@pengutronix.de> <74234427-005f-609e-3f33-cdf9a739c1d2@suse.cz> <1480675271.17003.50.camel@pengutronix.de> <20161202104851.GH6830@dhcp22.suse.cz> <1480676263.17003.55.camel@pengutronix.de>
Date: Fri, 02 Dec 2016 13:32:13 +0100
Message-ID: <xa1tfum6v7ea.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>, Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, "Robin H. Johnson" <robbat2@gentoo.org>, kernel@pengutronix.de, Andrew Morton <akpm@linux-foundation.org>, patchwork-lst@pengutronix.de, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>

>>> Am Freitag, den 02.12.2016, 11:18 +0100 schrieb Vlastimil Babka:
>>>> I don't think we should just hide the issue like this, as getting high=
=20
>>>> volume reports from this is also very likely associated with high=20
>>>> overhead for the allocations. If it's the generic dma-cma context, lik=
e=20
>>>> in [1] where it attempts CMA for order-0 allocations, we should first =
do=20
>>>> something about that, before tweaking the logging.

That was also my concern.  Ideally we would have a counter which
increments whenever isolation failure happens and some monitoring of
that counter but this is kernel so that=E2=80=99s just a pipe dream.

>> On Fri 02-12-16 11:41:11, Lucas Stach wrote:
>>> Still this message is really disturbing as page isolation failures can
>>> be caused by lots of other reasons like temporarily pinned pages.

Just so we=E2=80=99re on the same page, lots of allocations is not a *reaso=
n* of
isolation failures.  It only surfaces it.

This is not to disagree about better having code that is smart about
allocating DMA buffers.  This is true regardless.

> Am Freitag, den 02.12.2016, 11:48 +0100 schrieb Michal Hocko:
>> Hmm, then I think that what Robin has proposed [1] should be a generally
>> better solution because it both ratelimits and points to the user who is
>> triggering this path.=20

On Fri, Dec 02 2016, Lucas Stach wrote:
> Dumping a stacktrace at this point is only going to increase the noise
> from this message, as it can be trigger under normal operating
> conditions of CMA. If someone temporarily locked a previously movable
> page with GUP or something alike, the stacktrace will point to the
> victim rather than the offender, so I think the value of the stackstrace
> is rather limited.

I agree, which is why I suggested printing the stack only if
CONFIG_CMA_DEBUG is enabled.

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

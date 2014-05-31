Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 288FC6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 20:02:59 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so1465623pdi.11
        for <linux-mm@kvack.org>; Fri, 30 May 2014 17:02:58 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id xk1si7697353pab.68.2014.05.30.17.02.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 17:02:58 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id p10so1461594pdj.21
        for <linux-mm@kvack.org>; Fri, 30 May 2014 17:02:57 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 2/3] CMA: aggressively allocate the pages on cma reserved memory when not used
In-Reply-To: <20140530004514.GB8906@js1304-P5Q-DELUXE>
References: <1401260672-28339-1-git-send-email-iamjoonsoo.kim@lge.com> <1401260672-28339-3-git-send-email-iamjoonsoo.kim@lge.com> <5386E0CA.5040201@lge.com> <20140529074847.GA7554@js1304-P5Q-DELUXE> <5386EB3E.5090007@lge.com> <20140530004514.GB8906@js1304-P5Q-DELUXE>
Date: Sat, 31 May 2014 09:02:51 +0900
Message-ID: <xa1tha46hl1w.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> On Thu, May 29, 2014 at 05:09:34PM +0900, Gioh Kim wrote:
>> Is IS_ENABLED(CONFIG_CMA) necessary?
>> What about if (migratetype =3D=3D MIGRATE_MOVABLE && zone->managed_cma_p=
ages) ?

On Fri, May 30 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> Yes, field, managed_cma_pages exists only if CONFIG_CMA is enabled, so
> removing IS_ENABLE(CONFIG_CMA) would break the build.

That statement makes no sense.  If zone->managed_cma_pages not being
defined is the problem, what you need is:

+#ifdef CONFIG_CMA
+	if (migratetype =3D=3D MIGRATE_MOVABLE && zone->managed_cma_pages)
+		page =3D __rmqueue_cma(zone, order);
+#endif

If you use IS_ENABLED, zone-managed_cma_pages has to be defined
regardless of result of state of CONFIG_CMA.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

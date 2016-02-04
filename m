Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE724403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 18:29:56 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id cy9so23372619pac.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 15:29:56 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id sj10si19572095pab.65.2016.02.04.15.29.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 15:29:55 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 1/3] /proc/kpageflags: return KPF_BUDDY for "tail"
 buddy pages
Date: Thu, 4 Feb 2016 23:29:13 +0000
Message-ID: <20160204232912.GA29354@hori1.linux.bs1.fc.nec.co.jp>
References: <1454569683-17918-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160204164226.GA16895@esperanza>
In-Reply-To: <20160204164226.GA16895@esperanza>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3508D0569BA5574F8ED5E88765E9A2F1@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Feb 04, 2016 at 07:42:26PM +0300, Vladimir Davydov wrote:
> On Thu, Feb 04, 2016 at 04:08:01PM +0900, Naoya Horiguchi wrote:
> > Currently /proc/kpageflags returns nothing for "tail" buddy pages, whic=
h
> > is inconvenient when grasping how free pages are distributed. This patc=
h
> > sets KPF_BUDDY for such pages.
>=20
> Looks reasonable to me,
>=20
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thank you.

> >=20
> > With this patch:
> >=20
> >   $ grep MemFree /proc/meminfo ; tools/vm/page-types -b buddy
> >   MemFree:         3134992 kB
> >                flags      page-count       MB  symbolic-flags          =
           long-symbolic-flags
> >   0x0000000000000400          779272     3044  __________B_____________=
__________________ buddy
> >   0x0000000000000c00            4385       17  __________BM____________=
__________________ buddy,mmap
> >                total          783657     3061
>=20
> Why are buddy pages reported as mmapped? That looks weird. Shouldn't we
> fix it? Something like this, may be?
>=20
> --
> From: Vladimir Davydov <vdavydov@virtuozzo.com>
> Subject: [PATCH] proc: kpageflags: do not report buddy and balloon pages =
as
>  mapped
>=20
> PageBuddy and PageBalloon are not usual page flags - they are identified
> by a special negative (so as not to confuse with mapped pages) value of
> page->_mapcount. Since /proc/kpageflags uses page_mapcount helper to
> check if a page is mapped, it reports pages of these kinds as being
> mapped, which is confusing. Fix that by replacing page_mapcount with
> page_mapped.
>=20
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
>=20
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index b2855eea5405..332450d87ea4 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -105,7 +105,7 @@ u64 stable_page_flags(struct page *page)
>  	 * Note that page->_mapcount is overloaded in SLOB/SLUB/SLQB, so the
>  	 * simple test in page_mapcount() is not enough.

We can do s/page_mapcount/page_mapped/ for this line too.

>  	 */
> -	if (!PageSlab(page) && page_mapcount(page))
> +	if (!PageSlab(page) && page_mapped(page))

Look good to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

>  		u |=3D 1 << KPF_MMAP;
>  	if (PageAnon(page))
>  		u |=3D 1 << KPF_ANON;=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

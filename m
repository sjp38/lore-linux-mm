Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8189B6B0006
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:34:20 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w205-v6so11707054oiw.21
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:34:20 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id n189-v6si19424781oia.145.2018.07.16.17.34.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 17:34:19 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 2/2] mm: soft-offline: close the race against page
 allocation
Date: Tue, 17 Jul 2018 00:27:31 +0000
Message-ID: <20180717002731.GA11433@hori1.linux.bs1.fc.nec.co.jp>
References: <1531452366-11661-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531452366-11661-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180713134002.a365049a79d41be3c28916cc@linux-foundation.org>
In-Reply-To: <20180713134002.a365049a79d41be3c28916cc@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <317E8E8C8B68C64890D63BEBEA885BB8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jul 13, 2018 at 01:40:02PM -0700, Andrew Morton wrote:
> On Fri, 13 Jul 2018 12:26:06 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > A process can be killed with SIGBUS(BUS_MCEERR_AR) when it tries to
> > allocate a page that was just freed on the way of soft-offline.
> > This is undesirable because soft-offline (which is about corrected erro=
r)
> > is less aggressive than hard-offline (which is about uncorrected error)=
,
> > and we can make soft-offline fail and keep using the page for good reas=
on
> > like "system is busy."
> >=20
> > Two main changes of this patch are:
> >=20
> > - setting migrate type of the target page to MIGRATE_ISOLATE. As done
> >   in free_unref_page_commit(), this makes kernel bypass pcplist when
> >   freeing the page. So we can assume that the page is in freelist just
> >   after put_page() returns,
> >=20
> > - setting PG_hwpoison on free page under zone->lock which protects
> >   freelists, so this allows us to avoid setting PG_hwpoison on a page
> >   that is decided to be allocated soon.
> >=20
> >
> > ...
> >
> > +
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +/*
> > + * Set PG_hwpoison flag if a given page is confirmed to be a free page
> > + * within zone lock, which prevents the race against page allocation.
> > + */
>=20
> I think this is clearer?
>=20
> --- a/mm/page_alloc.c~mm-soft-offline-close-the-race-against-page-allocat=
ion-fix
> +++ a/mm/page_alloc.c
> @@ -8039,8 +8039,9 @@ bool is_free_buddy_page(struct page *pag
> =20
>  #ifdef CONFIG_MEMORY_FAILURE
>  /*
> - * Set PG_hwpoison flag if a given page is confirmed to be a free page
> - * within zone lock, which prevents the race against page allocation.
> + * Set PG_hwpoison flag if a given page is confirmed to be a free page. =
 This
> + * test is performed under the zone lock to prevent a race against page
> + * allocation.

Yes, I like it.

Thanks,
Naoya Horiguchi=

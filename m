Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8676C6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 00:59:21 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id tt10so5183870pab.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 21:59:21 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id ry2si2306300pab.159.2016.03.07.21.59.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 21:59:20 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] tools/vm/page-types.c: remove memset() in walk_pfn()
Date: Tue, 8 Mar 2016 05:58:35 +0000
Message-ID: <20160308055834.GA9987@hori1.linux.bs1.fc.nec.co.jp>
References: <1457401652-9226-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CALYGNiPgBRuZoi8nA-JQCxx-RGiXE9g-dfeeysvH0Rp2VAYz2A@mail.gmail.com>
In-Reply-To: <CALYGNiPgBRuZoi8nA-JQCxx-RGiXE9g-dfeeysvH0Rp2VAYz2A@mail.gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <29A89ACCD05C694FA194AD1C0D1652EE@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Mar 08, 2016 at 08:12:09AM +0300, Konstantin Khlebnikov wrote:
> On Tue, Mar 8, 2016 at 4:47 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > I found that page-types is very slow and my testing shows many timeout =
errors.
> > Here's an example with a simple program allocating 1000 thps.
> >
> >   $ time ./page-types -p $(pgrep -f test_alloc)
> >   ...
> >   real    0m17.201s
> >   user    0m16.889s
> >   sys     0m0.312s
> >
> >   $ time ./page-types.patched -p $(pgrep -f test_alloc)
> >   ...
> >   real    0m0.182s
> >   user    0m0.046s
> >   sys     0m0.135s
> >
> > Most of time is spent in memset(), which isn't necessary because we che=
ck
> > that the return of kpagecgroup_read() is equal to pages and uninitializ=
ed
> > memory is never used. So we can drop this memset().
>=20
> These zeros are used in show_page_range() - for merging pages into ranges=
.

Hi Konstantin,

Thank you for the response. The below code does solve the problem, so that'=
s fine.

But I don't understand how the zeros are used. show_page_range() is called
via add_page() which is called for i=3D0 to i=3Dpages-1, and the buffer cgi=
 is
already filled for the range [i, pages-1] by kpagecgroup_read(), so even if
without zero initialization, kpagecgroup_read() properly fills zeros, right=
?
IOW, is there any problem if we don't do this zero initialization?

Thanks,
Naoya Horiguchi

> You could add fast-path for count=3D1
>=20
> @@ -633,7 +633,10 @@ static void walk_pfn(unsigned long voffset,
>         unsigned long pages;
>         unsigned long i;
>=20
> -       memset(cgi, 0, sizeof cgi);
> +       if (count =3D=3D 1)
> +               cgi[0] =3D 0;
> +       else
> +               memset(cgi, 0, sizeof cgi);
>=20
>         while (count) {
>                 batch =3D min_t(unsigned long, count, KPAGEFLAGS_BATCH);
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

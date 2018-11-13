Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A69E86B000A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 19:21:35 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id e144-v6so11505986iof.13
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 16:21:35 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id w201-v6si8763290itb.121.2018.11.12.16.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 16:21:29 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC][PATCH v1 04/11] mm: madvise: call soft_offline_page()
 without MF_COUNT_INCREASED
Date: Tue, 13 Nov 2018 00:18:55 +0000
Message-ID: <20181113001855.GC5945@hori1.linux.bs1.fc.nec.co.jp>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <21e5b9ca-ad72-b0d5-3397-4b65831b236b@arm.com>
In-Reply-To: <21e5b9ca-ad72-b0d5-3397-4b65831b236b@arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <49E40B2BBA888A4BB7E66ACE16F63DEE@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>

On Fri, Nov 09, 2018 at 04:16:55PM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
> > Currently madvise_inject_error() pins the target page when calling
> > memory error handler, but it's not good because the refcount is just
> > an artifact of error injector and mock nothing about hw error itself.
> > IOW, pinning the error page is part of error handler's task, so
> > let's stop doing it.
>=20
> Did not get that. Could you please kindly explain how an incremented
> ref count through get_user_pages_fast() was a mocking the HW error
> previously ? Though I might be missing the some context here.

I meant in "mock nothing about hw error itself" that in the code path
for actual HW error (from MCE handler code) the error page is not pinned
outside (but inside) memory_failure().
So it makes more sense to me to do similarly also in error injection code,
and another good thing is that that makes code more simple (A later patch
eliminates MF_COUNT_INCREASED.)

>=20
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/madvise.c | 25 +++++++++++--------------
> >  1 file changed, 11 insertions(+), 14 deletions(-)
> >=20
> > diff --git v4.19-mmotm-2018-10-30-16-08/mm/madvise.c v4.19-mmotm-2018-1=
0-30-16-08_patched/mm/madvise.c
> > index 6cb1ca9..9fa0225 100644
> > --- v4.19-mmotm-2018-10-30-16-08/mm/madvise.c
> > +++ v4.19-mmotm-2018-10-30-16-08_patched/mm/madvise.c
> > @@ -637,6 +637,16 @@ static int madvise_inject_error(int behavior,
> >  		ret =3D get_user_pages_fast(start, 1, 0, &page);
> >  		if (ret !=3D 1)
> >  			return ret;
> > +		/*
> > +		 * The get_user_pages_fast() is just to get the pfn of the
> > +		 * given address, and the refcount has nothing to do with
> > +		 * what we try to test, so it should be released immediately.
> > +		 * This is racy but it's intended because the real hardware
> > +		 * errors could happen at any moment and memory error handlers
> > +		 * must properly handle the race.
> > +		 */
> > +		put_page(page);
> > +
> >  		pfn =3D page_to_pfn(page);
> > =20
> >  		/*
> > @@ -646,16 +656,11 @@ static int madvise_inject_error(int behavior,
> >  		 */
> >  		order =3D compound_order(compound_head(page));
> > =20
> > -		if (PageHWPoison(page)) {
> > -			put_page(page);
> > -			continue;
> > -		}
> > -
> >  		if (behavior =3D=3D MADV_SOFT_OFFLINE) {
> >  			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n"=
,
> >  					pfn, start);
> > =20
> > -			ret =3D soft_offline_page(page, MF_COUNT_INCREASED);
> > +			ret =3D soft_offline_page(page, 0);
>=20
> Probably something defined as a new "ignored" in the memory faults flag
> enumeration instead of passing '0' directly.

MF_* flags are defined as bitmap, not separate values. And according to
other caller like do_memory_failure(), multiple bits in flags can be set to=
gether.

    static int do_memory_failure(struct mce *m)
    {
            int flags =3D MF_ACTION_REQUIRED;
            ....
            if (!(m->mcgstatus & MCG_STATUS_RIPV))
                    flags |=3D MF_MUST_KILL;
            ret =3D memory_failure(m->addr >> PAGE_SHIFT, flags);

So I think that simply adding new MF_* value doesn't work, and "flags =3D=
=3D 0"
seems to me to show "no flag set" in the clearest way.
Or if you have any code suggestion, that's great.

Thanks,
Naoya Horiguchi=

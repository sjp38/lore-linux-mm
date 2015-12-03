Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4992B6B0256
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 09:54:01 -0500 (EST)
Received: by oiww189 with SMTP id w189so50031655oiw.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:54:01 -0800 (PST)
Received: from SHSQR01.spreadtrum.com ([222.66.158.135])
        by mx.google.com with ESMTPS id e83si8113309oib.52.2015.12.03.06.53.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 06:53:34 -0800 (PST)
From: "Pradeep Goswami (Pradeep Kumar Goswami)"
	<Pradeep.Goswami@spreadtrum.com>
Subject: Re: [PATCH]mm:Correctly update number of rotated pages on active
 list.
Date: Thu, 3 Dec 2015 14:46:20 +0000
Message-ID: <20151203144614.GA4907@pradeepkumarubtnb.spreadtrum.com>
References: <20151203100809.GA4544@pradeepkumarubtnb.spreadtrum.com>
 <20151203105948.GE9264@dhcp22.suse.cz>
In-Reply-To: <20151203105948.GE9264@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8D6B9A443AA60146A2581DD64F123514@spreadtrum.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "rebecca@android.com" <rebecca@android.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "sanjeev.yadav@spreatrum.com" <sanjeev.yadav@spreatrum.com>

On Thu, Dec 03, 2015 at 11:59:48AM +0100, Michal Hocko wrote:
> On Thu 03-12-15 10:08:11, Pradeep Goswami (Pradeep Kumar Goswami) wrote:
> > This patch corrects the number of pages which are rotated on active lis=
t.
> > The counter for rotated pages effects the number of pages
> > to be scanned on active pages list in  low memory situations.
>=20
> Why this should be changed?
>=20
> This seems to be deliberate:
>         /*
>          * Count referenced pages from currently used mappings as rotated=
,
>          * even though only some of them are actually re-activated.  This
>          * helps balance scan pressure between file and anonymous pages i=
n
>          * get_scan_count.
>          */
>         reclaim_stat->recent_rotated[file] +=3D nr_rotated;
>=20
> What kind of problem are you trying to fix?
Actually the numeber of pages which are actually rotated are wrongly
updated, So I thought this might be minor coding error but as pointed
out above, this seems to be deliberate. Thanks for clarifying.
>=20
> >=20
> > Signed-off-by: Pradeep Goswami <pradeep.goswami@spredtrum.com>
> > Cc: Rebecca Schultz Zavin <rebecca@android.com>
> > Cc: Vladimir Davydov <vdavydov@parallels.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > --- a/mm/vmscan.c       2015-11-18 20:55:38.208838142 +0800
> > +++ b/mm/vmscan.c       2015-11-19 14:37:31.189838998 +0800
> > @@ -1806,7 +1806,6 @@ static void shrink_active_list(unsigned
> > =20
> >                 if (page_referenced(page, 0, sc->target_mem_cgroup,
> >                                     &vm_flags)) {
> > -                       nr_rotated +=3D hpage_nr_pages(page);
> >                         /* =20
> >                          * Identify referenced, file-backed active page=
s and=20
> >                          * give them one more trip around the active li=
st. So
> > @@ -1818,6 +1817,7 @@ static void shrink_active_list(unsigned
> >                          */ =20
> >                         if ((vm_flags & VM_EXEC) && page_is_file_cache(=
page)) {
> >                                 list_add(&page->lru, &l_active);
> > +                               nr_rotated +=3D hpage_nr_pages(page);
> >                                 continue;
> >                         }  =20
> >                 }  =20
> >=20
> > Thanks,
> > Pradeep.
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
> --=20
> Michal Hocko
> SUSE Labs=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

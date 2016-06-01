Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 95F9E6B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 03:39:29 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a143so17547003oii.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 00:39:29 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g18si31591923iog.23.2016.06.01.00.39.28
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 00:39:29 -0700 (PDT)
Date: Wed, 1 Jun 2016 16:40:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Why __alloc_contig_migrate_range calls  migrate_prep() at first?
Message-ID: <20160601074010.GO19976@bbox>
References: <tencent_29E1A2CA78CE0C9046C1494E@qq.com>
MIME-Version: 1.0
In-Reply-To: <tencent_29E1A2CA78CE0C9046C1494E@qq.com>
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@foxmail.com>
Cc: akpm <akpm@linux-foundation.org>, mgorman <mgorman@techsingularity.net>, "iamjoonsoo.kim" <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Jun 01, 2016 at 11:42:29AM +0800, Wang Sheng-Hui wrote:
> Dear,
>=20
> Sorry to trouble you.
>=20
> I noticed cma_alloc would turn to  __alloc_contig_migrate_range for alloc=
ating pages.
> But  __alloc_contig_migrate_range calls  migrate_prep() at first, even if=
 the requested page
> is single and free, lru_add_drain_all still run (called by  migrate_prep(=
))?
>=20
> Image a large chunk of free contig pages for CMA, various drivers may req=
uest a single page from
> the CMA area, we'll get  lru_add_drain_all run for each page.
>=20
> Should we detect if the required pages are free before migrate_prep(), or=
 detect at least for single=20
> page allocation?

That makes sense to me.

How about calling migrate_prep once migrate_pages fails in the first trial?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d666df5ef95..c504c1a623d2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6623,8 +6623,6 @@ static int __alloc_contig_migrate_range(struct compac=
t_control *cc,
 	unsigned int tries =3D 0;
 	int ret =3D 0;
=20
-	migrate_prep();
-
 	while (pfn < end || !list_empty(&cc->migratepages)) {
 		if (fatal_signal_pending(current)) {
 			ret =3D -EINTR;
@@ -6650,6 +6648,8 @@ static int __alloc_contig_migrate_range(struct compac=
t_control *cc,
=20
 		ret =3D migrate_pages(&cc->migratepages, alloc_migrate_target,
 				    NULL, 0, cc->mode, MR_CMA);
+		if (ret)
+			migrate_prep();
 	}
 	if (ret < 0) {
 		putback_movable_pages(&cc->migratepages);


>=20
> ------------------
> Regards,
> Wang Sheng-HuiN=8B=A7=B2=E6=ECr=B8=9Bz=C7=A7u=A9=9E=B2=C6=A0{=08=AD=86=E9=
=EC=B9=BB=1C=AE&=DE=96)=EE=C6i=A2=9E=D8^n=87r=B6=89=9A=8E=8A=DD=A2j$=BD=A7$=
=A2=B8=05=A2=B9=A8=AD=E8=A7~=8A'.)=EE=C4=C3,y=E8m=B6=9F=FF=C3=0C%=8A{=B1=9A=
j+=83=F0=E8=9E=D7=A6j)Z=86=B7=9F=FEf=A2=96=DA=1D=A2{d=BD=A7$=A2=B8=1E=99=A8=
=A5=92=F6=9C=92=8A=E0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

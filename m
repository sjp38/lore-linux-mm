Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3476B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 16:30:32 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so4827381wiv.5
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 13:30:31 -0800 (PST)
Received: from mailsec111.isp.belgacom.be (mailsec111.isp.belgacom.be. [195.238.20.107])
        by mx.google.com with ESMTP id r15si49623074wij.73.2015.01.09.13.30.31
        for <linux-mm@kvack.org>;
        Fri, 09 Jan 2015 13:30:31 -0800 (PST)
Date: Fri, 9 Jan 2015 22:30:30 +0100 (CET)
From: Fabian Frederick <fabf@skynet.be>
Reply-To: Fabian Frederick <fabf@skynet.be>
Message-ID: <1453795579.577520.1420839030684.open-xchange@webmail.nmp.proximus.be>
In-Reply-To: <54AC1991.9060908@suse.cz>
References: <1420301068-19447-1-git-send-email-fabf@skynet.be> <54AC1991.9060908@suse.cz>
Subject: Re: [PATCH 1/1 linux-next] mm,compaction: move
 suitable_migration_target() under CONFIG_COMPACTION
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org



> On 06 January 2015 at 18:21 Vlastimil Babka <vbabka@suse.cz> wrote:
>
>
> On 01/03/2015 05:04 PM, Fabian Frederick wrote:
> > suitable_migration_target() is only used by isolate_freepages()
> > Define it under CONFIG_COMPACTION || CONFIG_CMA is not needed.
> >
> > Fix the following warning:
> > mm/compaction.c:311:13: warning: 'suitable_migration_target' defined
> > but not used [-Wunused-function]
> >
> > Signed-off-by: Fabian Frederick <fabf@skynet.be>
>
> I agree, I would just move it to the section where isolation_suitable() a=
nd
> related others are, maybe at the end of this section below
> update_pageblock_skip()?

Yes of course, that would solve the warning as well.

Fabian
>
> Vlastimil

>
> > ---
> >=C2=A0 mm/compaction.c | 44 ++++++++++++++++++++++----------------------
> >=C2=A0 1 file changed, 22 insertions(+), 22 deletions(-)
> >
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 546e571..38b151c 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -307,28 +307,6 @@ static inline bool compact_should_abort(struct
> > compact_control *cc)
> >=C2=A0 =C2=A0 =C2=A0return false;
> >=C2=A0 }
> >=C2=A0
> > -/* Returns true if the page is within a block suitable for migration t=
o */
> > -static bool suitable_migration_target(struct page *page)
> > -{
> > -=C2=A0 =C2=A0/* If the page is a large free page, then disallow migrat=
ion */
> > -=C2=A0 =C2=A0if (PageBuddy(page)) {
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * We are checking page_order=
 without zone->lock taken. But
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * the only small danger is t=
hat we skip a potentially suitable
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * pageblock, so it's not wor=
th to check order for valid range.
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page_order_unsafe(page) >=
=3D pageblock_order)
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0r=
eturn false;
> > -=C2=A0 =C2=A0}
> > -
> > -=C2=A0 =C2=A0/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow =
migration */
> > -=C2=A0 =C2=A0if (migrate_async_suitable(get_pageblock_migratetype(page=
)))
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return true;
> > -
> > -=C2=A0 =C2=A0/* Otherwise skip the block */
> > -=C2=A0 =C2=A0return false;
> > -}
> > -
> >=C2=A0 /*
> >=C2=A0 =C2=A0* Isolate free pages onto a private freelist. If @strict is=
 true, will
> >abort
> >=C2=A0 =C2=A0* returning 0 on any invalid PFNs or non-free pages inside =
of the
> >pageblock
> > @@ -802,6 +780,28 @@ isolate_migratepages_range(struct compact_control =
*cc,
> > unsigned long start_pfn,
> >=C2=A0
> >=C2=A0 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
> >=C2=A0 #ifdef CONFIG_COMPACTION
> > +/* Returns true if the page is within a block suitable for migration t=
o */
> > +static bool suitable_migration_target(struct page *page)
> > +{
> > +=C2=A0 =C2=A0/* If the page is a large free page, then disallow migrat=
ion */
> > +=C2=A0 =C2=A0if (PageBuddy(page)) {
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * We are checking page_order=
 without zone->lock taken. But
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * the only small danger is t=
hat we skip a potentially suitable
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * pageblock, so it's not wor=
th to check order for valid range.
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page_order_unsafe(page) >=
=3D pageblock_order)
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0r=
eturn false;
> > +=C2=A0 =C2=A0}
> > +
> > +=C2=A0 =C2=A0/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow =
migration */
> > +=C2=A0 =C2=A0if (migrate_async_suitable(get_pageblock_migratetype(page=
)))
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return true;
> > +
> > +=C2=A0 =C2=A0/* Otherwise skip the block */
> > +=C2=A0 =C2=A0return false;
> > +}
> > +
> >=C2=A0 /*
> >=C2=A0 =C2=A0* Based on information in the current compact_control, find=
 blocks
> >=C2=A0 =C2=A0* suitable for isolating free pages from and then isolate t=
hem.
> >
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 8AB086B002C
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 14:53:30 -0500 (EST)
Received: by eaag11 with SMTP id g11so1331801eaa.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 11:53:28 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 02/15] mm: page_alloc: update migrate type of pages on pcp
 when isolating
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-3-git-send-email-m.szyprowski@samsung.com>
 <20120130111522.GE25268@csn.ul.ie> <op.v8wlu8ws3l0zgt@mpn-glaptop>
 <20120130161447.GU25268@csn.ul.ie>
 <022e01cce034$bc6cf440$3546dcc0$%szyprowski@samsung.com>
 <20120202124729.GA5796@csn.ul.ie>
Date: Thu, 02 Feb 2012 20:53:25 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v82hjbd13l0zgt@mpn-glaptop>
In-Reply-To: <20120202124729.GA5796@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>

> On Tue, Jan 31, 2012 at 05:23:59PM +0100, Marek Szyprowski wrote:
>> Pages, which have incorrect migrate type on free finally
>> causes pageblock migration type change from MIGRATE_CMA to MIGRATE_MO=
VABLE.

On Thu, 02 Feb 2012 13:47:29 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> I'm not quite seeing this. In free_hot_cold_page(), the pageblock
> type is checked so the page private should be set to MIGRATE_CMA or
> MIGRATE_ISOLATE for the CMA area. It's not clear how this can change a=

> pageblock to MIGRATE_MOVABLE in error.

Here's what I think may happen:

When drain_all_pages() is called, __free_one_page() is called for each p=
age on
pcp list with migrate type deducted from page_private() which is MIGRATE=
_CMA.
This result in the page being put on MIGRATE_CMA freelist even though it=
s
pageblock's migrate type is MIGRATE_ISOLATE.

When allocation happens and pcp list is empty, rmqueue_bulk() will get e=
xecuted
with migratetype argument set to MIGRATE_MOVABLE.  It calls __rmqueue() =
to grab
some pages and because the page described above is on MIGRATE_CMA freeli=
st it
may be returned back to rmqueue_bulk().

But, pageblock's migrate type is not MIGRATE_CMA but MIGRATE_ISOLATE, so=
 the
following code:

#ifdef CONFIG_CMA
		if (is_pageblock_cma(page))
			set_page_private(page, MIGRATE_CMA);
		else
#endif
			set_page_private(page, migratetype);

will set it's private to MIGRATE_MOVABLE and in the end the page lands b=
ack
on MIGRATE_MOVABLE pcp list but this time with page_private =3D=3D MIGRA=
TE_MOVABLE
and not MIGRATE_CMA.

One more drain_all_pages() (which may happen since alloc_contig_range() =
calls
set_migratetype_isolate() for each block) and next __rmqueue_fallback() =
may
convert the whole pageblock to MIGRATE_MOVABLE.

I know, this sounds crazy and improbable, but I couldn't find an easier =
path
to destruction.  As you pointed, once the page is allocated, free_hot_co=
ld_page()
will do the right thing by reading pageblock's migrate type.

Marek is currently experimenting with various patches including the foll=
owing
change:

#ifdef CONFIG_CMA
                 int mt =3D get_pageblock_migratetype(page);
                 if (is_migrate_cma(mt) || mt =3D=3D MIGRATE_ISOLATE)
                         set_page_private(page, mt);
                 else
#endif
                         set_page_private(page, migratetype);

As a matter of fact, if __rmqueue() was changed to return migrate type o=
f the
freelist it took page from, we could avoid this get_pageblock_migratetyp=
e() all
together.  For now, however, I'd rather not go that way just yet -- I'll=
 be happy
to dig into it once CMA gets merged.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

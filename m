Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4AB6B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 17:04:42 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so7789606pdj.16
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 14:04:42 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Tue, 1 Oct 2013 15:04:39 -0600
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 832B638C8047
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 17:04:37 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r91L4cNe4719008
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 21:04:38 GMT
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r91L4XR1016936
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 17:04:33 -0400
Date: Tue, 1 Oct 2013 16:04:31 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
Message-ID: <20131001210431.GA8941@variantweb.net>
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
 <5237FDCC.5010109@oracle.com>
 <20130923220757.GC16191@variantweb.net>
 <524318DE.7070106@samsung.com>
 <20130925215744.GA25852@variantweb.net>
 <52455B05.1010603@samsung.com>
 <20130927220045.GA751@variantweb.net>
 <1380529726.11375.11.camel@AMDC1943>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1380529726.11375.11.camel@AMDC1943>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Tomasz Stanislawski <t.stanislaws@samsung.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Mon, Sep 30, 2013 at 10:28:46AM +0200, Krzysztof Kozlowski wrote:
> On pi=C4=85, 2013-09-27 at 17:00 -0500, Seth Jennings wrote:
> > I have to say that when I first came up with the idea, I was thinking
> > the address space would be at the zswap layer and the radix slots wou=
ld
> > hold zbud handles, not struct page pointers.
> >=20
> > However, as I have discovered today, this is problematic when it come=
s
> > to reclaim and migration and serializing access.
> >=20
> > I wanted to do as much as possible in the zswap layer since anything
> > done in the zbud layer would need to be duplicated in any other futur=
e
> > allocator that zswap wanted to support.
> >=20
> > Unfortunately, zbud abstracts away the struct page and that visibilit=
y
> > is needed to properly do what we are talking about.
> >=20
> > So maybe it is inevitable that this will need to be in the zbud code
> > with the radix tree slots pointing to struct pages after all.
>=20
> To me it looks very similar to the solution proposed in my patches.

Yes, it is very similar.  I'm beginning to like aspects of this patch
more as I explore this issue more.

At first, I balked at the idea of yet another abstraction layer, but it
is very hard to avoid unless you want to completely collapse zswap and
zbud into one another and dissolve the layering.  Then you could do a
direct swap_offset -> address mapping.

> The
> difference is that you wish to use offset as radix tree index.
> I thought about this earlier but it imposed two problems:
>=20
> 1. A generalized handle (instead of offset) may be more suitable when
> zbud will be used in other drivers (e.g. zram).
>=20
> 2. It requires redesigning of zswap architecture around
> zswap_frontswap_store() in case of duplicated insertion. Currently when
> storing a page the zswap:
>  - allocates zbud page,
>  - stores new data in it,
>  - checks whether it is a duplicated page (same offset present in
> rbtree),
>  - if yes (duplicated) then zswap frees previous entry.
> The problem here lies in allocating zbud page under the same offset.
> This step would replace old data (because we are using the same offset
> in radix tree).

Yes, but the offset is always going to be the key at the top layer
because that is was the swap subsystem uses.  So we'd have to have a
swap_offset -> handle -> address translation (2 abstraction layers) the
first of which would need to deal with the duplicate store issue.

Seth

>=20
> In my opinion using zbud handle is in this case more flexible.
>=20
>=20
> Best regards,
> Krzysztof
>=20
> > I like the idea of masking the bit into the struct page pointer to
> > indicate which buddy maps to the offset.
> >=20
> > There is a twist here in that, unlike a normal page cache tree, we ca=
n
> > have two offsets pointing at different buddies in the same frame
> > which means we'll have to do some custom stuff for migration.
> >=20
> > The rabbit hole I was going down today has come to an end so I'll tak=
e a
> > fresh look next week.
> >=20
> > Thanks for your ideas and discussion! Maybe we can make zswap/zbud an
> > upstanding MM citizen yet!
> >=20
> > Seth
> >=20
> > >=20
> > > >>
> > > >> In case of zbud, there are two swap offset pointing to
> > > >> the same page. There might be more if zsmalloc is used.
> > > >> What is worse it is possible that one swap entry could
> > > >> point to data that cross a page boundary.
> > > >=20
> > > > We just won't set page->index since it doesn't have a good meanin=
g in
> > > > our case.  Swap cache pages also don't use index, although is see=
ms to
> > > > me that they could since there is a 1:1 mapping of a swap cache p=
age to
> > > > a swap offset and the index field isn't being used for anything e=
lse.
> > > > But I digress...
> > >=20
> > > OK.
> > >=20
> > > >=20
> > > >>
> > > >> Of course, one could try to modify MM to support
> > > >> multiple mapping of a page in the radix tree.
> > > >> But I think that MM guys will consider this as a hack
> > > >> and they will not accept it.
> > > >=20
> > > > Yes, it will require some changes to the MM to handle zbud pages =
on the
> > > > LRU.  I'm thinking that it won't be too intrusive, depending on h=
ow we
> > > > choose to mark zbud pages.
> > > >=20
> > >=20
> > > Anyway, I think that zswap should use two index engines.
> > > I mean index in Data Base meaning.
> > > One index is used to translate swap_entry to compressed page.
> > > And another one to be used by reclaim and migration by MM,
> > > probably address_space is a best choice.
> > > Zbud would responsible for keeping consistency
> > > between mentioned indexes.
> > >=20
> > > Regards,
> > > Tomasz Stanislawski
> > >=20
> > > > Seth
> > > >=20
> > > >>
> > > >> Regards,
> > > >> Tomasz Stanislawski
> > > >>
> > > >>
> > > >>> --
> > > >>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > >>> the body to majordomo@kvack.org.  For more info on Linux MM,
> > > >>> see: http://www.linux-mm.org/ .
> > > >>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org=
 </a>
> > > >>>
> > > >>
> > > >=20
> > > > --
> > > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > > see: http://www.linux-mm.org/ .
> > > > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org <=
/a>
> > > >=20
> > >=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

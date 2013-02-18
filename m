Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id CDDBA6B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 18:17:32 -0500 (EST)
MIME-Version: 1.0
Message-ID: <d0ca0139-cad3-4ef4-9d21-c1631393db24@default>
Date: Mon, 18 Feb 2013 15:17:16 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv5 4/8] zswap: add to mm/
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1360780731-11708-5-git-send-email-sjenning@linux.vnet.ibm.com>
 <511F0536.5030802@gmail.com> <51227FDA.7040000@linux.vnet.ibm.com>
 <0fb2af92-575f-4f5d-a115-829a3cf035e5@default>
 <5122918A.8090307@linux.vnet.ibm.com>
 <2c81050d-72b0-4a93-aecb-900171a019d0@default>
 <5122B0A0.3090401@linux.vnet.ibm.com>
In-Reply-To: <5122B0A0.3090401@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Ric Mason <ric.masonn@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCHv5 4/8] zswap: add to mm/
>=20
> On 02/18/2013 03:59 PM, Dan Magenheimer wrote:
> >>>>> please document in Documentation/kernel-parameters.txt.
> >>>>
> >>>> Will do.
> >>>
> >>> Is that a good idea?  Konrad's frontswap/cleancache patches
> >>> to fix frontswap/cleancache initialization so that backends
> >>> can be built/loaded as modules may be merged for 3.9.
> >>> AFAIK, module parameters are not included in kernel-parameters.txt.
> >>
> >> This is true.  However, the frontswap/cleancache init stuff isn't the
> >> only reason zswap is built-in only.  The writeback code depends on
> >> non-exported kernel symbols:
> >>
> >> swapcache_free
> >> __swap_writepage
> >> __add_to_swap_cache
> >> swapcache_prepare
> >> swapper_space
> >> end_swap_bio_write
> >>
> >> I know a fix is as trivial as exporting them, but I didn't want to
> >> take on that debate right now.
> >
> > Hmmm... I wonder if exporting these might be the best solution
> > as it (unnecessarily?) exposes some swap subsystem internals.
> > I wonder if a small change to read_swap_cache_async might
> > be more acceptable.
>=20
> Yes, I'm not saying that I'm for exporting them; just that that would
> be an easy and probably improper fix.
>=20
> As I recall, the only thing I really needed to change in my adaption
> of read_swap_cache_async(), zswap_get_swap_cache_page() in zswap, was
> the assumption built in that it is swapping in a page on behalf of a
> userspace program with the vma argument and alloc_page_vma().  Maybe
> if we change it to just use alloc_page when vma is NULL, that could
> work.  In a non-NUMA kernel alloc_page_vma() equals alloc_page() so I
> wouldn't expect weird things doing that.

The zcache version (zcache_get_swap_cache_page, in linux-next) expects
the new_page to be pre-allocated and passed in.  This could be
done easily with something like the patch below.  But both the
zswap and zcache version require three distinct return values
and slightly different actions before returning "success" so
some minor surgery will be needed there as well.

With a more generic read_swap_cache_async, I think the only
remaining swap subsystem change might be the modified
__swap_writepage (and possibly the end_swap_bio_write change,
though that seems to be mostly just to modify a counter...
may not be really needed.)

Oh, and then of course read_swap_cache_async() would need to be
exported.

Dan

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 0cb36fb..c0e2509 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -279,9 +279,10 @@ struct page * lookup_swap_cache(swp_entry_t entry)
  * the swap entry is no longer in use.
  */
 struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
-=09=09=09struct vm_area_struct *vma, unsigned long addr)
+=09=09=09struct vm_area_struct *vma, unsigned long addr,
+=09=09=09struct page *new_page)
 {
-=09struct page *found_page, *new_page =3D NULL;
+=09struct page *found_page;
 =09int err;
=20
 =09do {
@@ -389,7 +390,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t =
gfp_mask,
 =09for (offset =3D start_offset; offset <=3D end_offset ; offset++) {
 =09=09/* Ok, do the async read-ahead now */
 =09=09page =3D read_swap_cache_async(swp_entry(swp_type(entry), offset),
-=09=09=09=09=09=09gfp_mask, vma, addr);
+=09=09=09=09=09=09gfp_mask, vma, addr, NULL);
 =09=09if (!page)
 =09=09=09continue;
 =09=09page_cache_release(page);
@@ -397,5 +398,5 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t =
gfp_mask,
 =09blk_finish_plug(&plug);
=20
 =09lru_add_drain();=09/* Push any new pages onto the LRU now */
-=09return read_swap_cache_async(entry, gfp_mask, vma, addr);
+=09return read_swap_cache_async(entry, gfp_mask, vma, addr, NULL);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 0040D6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 22:22:53 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <7058b4bf-4473-4755-a017-e32f5389a73f@default>
Date: Thu, 4 Apr 2013 19:22:21 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv8 5/8] mm: break up swap_writepage() for frontswap
 backends
References: <1365113446-25647-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1365113446-25647-6-git-send-email-sjenning@linux.vnet.ibm.com>
 <515DFF08.3060005@linux.vnet.ibm.com>
In-Reply-To: <515DFF08.3060005@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Bob Liu <lliubbo@gmail.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCHv8 5/8] mm: break up swap_writepage() for frontswap ba=
ckends
>=20
> On 04/04/2013 05:10 PM, Seth Jennings wrote:
> > swap_writepage() is currently where frontswap hooks into the swap
> > write path to capture pages with the frontswap_store() function.
> > However, if a frontswap backend wants to "resume" the writeback of
> > a page to the swap device, it can't call swap_writepage() as
> > the page will simply reenter the backend.
> >
> > This patch separates swap_writepage() into a top and bottom half, the
> > bottom half named __swap_writepage() to allow a frontswap backend,
> > like zswap, to resume writeback beyond the frontswap_store() hook.
> >
> > __add_to_swap_cache() is also made non-static so that the page for
> > which writeback is to be resumed can be added to the swap cache.
> >
> > Acked-by: Minchan Kim <minchan@kernel.org>
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>=20
> Adding Cc Bob Liu.
>=20
> I just remembered that Bob had done a repost of the 5 and 6 patches,
> outside the zswap thread,  with a small change to avoid a checkpatch
> warning.  I didn't pull that change into my version, but I should have.
>=20
> It doesn't make a functional difference, so this patch can still go
> forward and the checkpatch warning can be cleaned up in a subsequent
> patch.  If another revision of the patchset is needed for other
> reasons, I'll pull this change into the next version.
>=20
> I think Dan and Bob would be ok with their tags being applied to 5 and 6:
>=20
> Acked-by: Bob Liu <bob.liu@oracle.com>
> Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>=20
> That ok?

OK with me.  I do support these two MM patches as candidates for the
3.10 window since both zswap AND in-tree zcache depend on them,
but the silence from Andrew was a bit deafening.

Seth, perhaps you could add a #ifdef CONFIG_ZSWAP_WRITEBACK
to the zswap code and Kconfig (as zcache has done) and then
these two patches in your patchset can be reviewed
separately?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

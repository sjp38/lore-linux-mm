Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6482F6B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 11:13:49 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <16b4dcd5-95d8-4cb0-885d-0189ef90c02b@default>
Date: Fri, 4 Jun 2010 08:13:14 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 3/7] Cleancache (was Transcendent Memory): VFS hooks
References: <20100528173610.GA12270@ca-server1.us.oracle.com
 20100604132948.GC1879@barrios-desktop>
In-Reply-To: <20100604132948.GC1879@barrios-desktop>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> Hi, Dan.
> I reviewed quickly. So I may be wrong. :)

Hi Minchan --

Thanks for your thorough review!  I don't think anyone
else yet has examined the semantics of the cleancache
patch as deeply as you have.  Excellent!

> > +=09/*
> > +=09 * if we're uptodate, flush out into the cleancache, otherwise
> > +=09 * invalidate any existing cleancache entries.  We can't leave
> > +=09 * stale data around in the cleancache once our page is gone
> > +=09 */
> > +=09if (PageUptodate(page))
> > +=09=09cleancache_put_page(page);
> > +=09else
> > +=09=09cleancache_flush_page(mapping, page);
>=20
> I doubt it's right place related to PFRA.

I agree it doesn't seem to be the right place, but it does work
and there doesn't seem to be a better place.
=20
> 1)
> You mentiond PFRA in you description and I understood cleancache has
> a cold clean page which is evicted by reclaimer.
> But __remove_from_page_cache can be called by other call sites.
>=20
> For example, shmem_write page calls it for moving the page from page
> cache
> to swap cache. Although there isn't the page in page cache, it is in
> swap cache.
> So next read/write of shmem until swapout happens can be read/write in
> swap cache.
>=20
> I didn't looked into whole of callsites. But please review again them.

I think the "if (PageUptodate(page))" eliminates all the cases
where bad things can happen.

Note that there may be cases where some unnecessary puts/flushes
occur.  The focus of the patch is on correctness first; it may
be possible to increase performance (marginally) in the future by
reducing unnecessary cases.

> 3) Please consider system memory pressure.
> And I hope Nitin consider this, too.

This is definitely very important but remember that cleancache
provides a great deal of flexibility:  Any page in cleancache
can be thrown away at any time as every page is clean!  It
can even accept a page and throw it away immediately.  Clearly
the backend needs to do this intelligently so this will
take some policy work.

Since I saw you sent a separate response to Nitin, I'll
let him answer for his in-kernel page cache compression
work.  The solution to the similar problem for Xen is
described in the tmem internals document that I think
I pointed to earlier here:
http://oss.oracle.com/projects/tmem/documentation/internals/=20

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 26D246B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 11:52:57 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ba74b4e5-500e-4662-ade0-c0b714b8f570@default>
Date: Tue, 31 May 2011 08:49:02 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 1/14] mm: invalidate_mapping_pages flush cleancache
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils
 alpine.LSU.2.00.1105301733500.5482@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1105301733500.5482@sister.anvils>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, chris.mason@oracle.com

> From: Hugh Dickins [mailto:hughd@google.com]
> Sent: Monday, May 30, 2011 6:36 PM
> To: Andrew Morton
> Cc: Dan Magenheimer; linux-kernel@vger.kernel.org; linux-mm@kvack.org
> Subject: [PATCH 1/14] mm: invalidate_mapping_pages flush cleancache
>=20
> truncate_inode_pages_range() and invalidate_inode_pages2_range()
> call cleancache_flush_inode(mapping) before and after: shouldn't
> invalidate_mapping_pages() be doing the same?
>=20
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> ---
>  mm/truncate.c |    2 ++
>  1 file changed, 2 insertions(+)
>=20
> --- linux.orig/mm/truncate.c=092011-05-30 13:56:10.416798124 -0700
> +++ linux/mm/truncate.c=092011-05-30 14:08:46.612547848 -0700
> @@ -333,6 +333,7 @@ unsigned long invalidate_mapping_pages(s
>  =09unsigned long count =3D 0;
>  =09int i;
>=20
> +=09cleancache_flush_inode(mapping);
>  =09pagevec_init(&pvec, 0);
>  =09while (next <=3D end &&
>  =09=09=09pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
> @@ -373,6 +374,7 @@ unsigned long invalidate_mapping_pages(s
>  =09=09mem_cgroup_uncharge_end();
>  =09=09cond_resched();
>  =09}
> +=09cleancache_flush_inode(mapping);
>  =09return count;
>  }
>  EXPORT_SYMBOL(invalidate_mapping_pages);

Hi Hugh --

I don't claim to be an expert on VFS, and so I have cc'ed
Chris Mason who originally placed the cleancache hooks
in VFS, but I think this patch is unnecessary.  Instead
of flushing ALL of the cleancache pages belonging to
the inode with cleancache_flush_inode, the existing code
eventually calls __delete_from_page_cache on EACH page
that is being invalidated. And since __delete_from_page_cache
calls cleancache_flush_page, only that subset of pages
in the mapping that invalidate_mapping_pages() would
invalidate (which, from the comment above the routine
indicates, is only *unlocked* pages) is removed from
cleancache.

However, there may be some path through VFS I am missing
or something else subtle I am misunderstanding so please
clarify if either is true.

Thanks,
Dan
---
Thanks... for the memory!
I really could use more / my throughput's on the floor
The balloon is flat / my swap disk's fat / I've OOM's in store
Overcommitted so much
(with apologies to Bob Hope)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

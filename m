Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 697B06B007E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 11:56:48 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h68so52260334lfh.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 08:56:48 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id b84si31421110wmd.95.2016.05.30.08.56.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 08:56:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 6AA091C1F18
	for <linux-mm@kvack.org>; Mon, 30 May 2016 16:56:46 +0100 (IST)
Date: Mon, 30 May 2016 16:56:45 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0 (was: Re: mm,
 page_alloc: avoid looking up the first zone in a zonelist twice)
Message-ID: <20160530155644.GP2527@techsingularity.net>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

On Mon, May 30, 2016 at 03:13:40PM +0200, Geert Uytterhoeven wrote:
> >     The benefit is negligible and the results are within the noise but each
> >     cycle counts.
> >
> >     Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> >     Cc: Vlastimil Babka <vbabka@suse.cz>
> >     Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> About one week ago, I started seeing an obscure intermittent crash during
> system shutdown on m68k/ARAnyM using atari_defconfig.
> The crash isn't 100% reproducible, but it happens during ca. 1 out of 5
> shutdowns.
> 
> I finally managed to bisect it to the above commit.
> I did verify that the parent commit didn't crash after 60 tries.
> Unfortunately I couldn't revert the offending commit on top of v4.7-rc1, due to
> conflicting changes.
> 
> Do you have any idea what's going wrong?

There isn't anything obvious from the crash log you showed but can you
try the following just in case?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dba8cfd0b2d6..f2c1e47adc11 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3232,6 +3232,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * allocations are system rather than user orientated
 		 */
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
+		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
+					ac->high_zoneidx, ac->nodemask);
+		ac->classzone_idx = zonelist_zone_idx(ac->preferred_zoneref);
 		page = get_page_from_freelist(gfp_mask, order,
 						ALLOC_NO_WATERMARKS, ac);
 		if (page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

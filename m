Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01CB06B007E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 14:56:20 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id q17so88703986lbn.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 11:56:19 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id gs6si45984160wjc.83.2016.05.30.11.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 11:56:18 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id F219B1C1DC2
	for <linux-mm@kvack.org>; Mon, 30 May 2016 19:56:17 +0100 (IST)
Date: Mon, 30 May 2016 19:56:16 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0 (was: Re: mm,
 page_alloc: avoid looking up the first zone in a zonelist twice)
Message-ID: <20160530185616.GQ2527@techsingularity.net>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
 <20160530155644.GP2527@techsingularity.net>
 <CAMuHMdWioTRo1PGymqCEv+3CoQYH8qnhP2T__orSbMw1q-CBMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAMuHMdWioTRo1PGymqCEv+3CoQYH8qnhP2T__orSbMw1q-CBMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

On Mon, May 30, 2016 at 07:37:39PM +0200, Geert Uytterhoeven wrote:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index dba8cfd0b2d6..f2c1e47adc11 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3232,6 +3232,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >                  * allocations are system rather than user orientated
> >                  */
> >                 ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> > +               ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> > +                                       ac->high_zoneidx, ac->nodemask);
> > +               ac->classzone_idx = zonelist_zone_idx(ac->preferred_zoneref);
> >                 page = get_page_from_freelist(gfp_mask, order,
> >                                                 ALLOC_NO_WATERMARKS, ac);
> >                 if (page)
> 
> Thanks, but unfortunately it doesn't help.
> 

Thanks. Please try the following instead

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb320cde4d6d..557549c81083 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3024,6 +3024,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		apply_fair = false;
 		fair_skipped = false;
 		reset_alloc_batches(ac->preferred_zoneref->zone);
+		z = ac->preferred_zoneref;
 		goto zonelist_scan;
 	}
 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

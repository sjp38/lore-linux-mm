Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06E25828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 12:00:21 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g18so57540079lfg.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:00:20 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id gl9si972330wjb.144.2016.06.23.09.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 09:00:18 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC, DEBUGGING 1/2] mm: pass NR_FILE_PAGES/NR_SHMEM into node_page_state
Date: Thu, 23 Jun 2016 17:56:57 +0200
Message-ID: <4149446.1SMXVuGq6X@wuerfel>
In-Reply-To: <20160623135111.GX1868@techsingularity.net>
References: <20160623100518.156662-1-arnd@arndb.de> <3817461.6pThRKgN9N@wuerfel> <20160623135111.GX1868@techsingularity.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thursday, June 23, 2016 2:51:11 PM CEST Mel Gorman wrote:
> On Thu, Jun 23, 2016 at 03:17:43PM +0200, Arnd Bergmann wrote:
> > > I have an alternative fix for this in a private tree. For now, I've asked
> > > Andrew to withdraw the series entirely as there are non-trivial collisions
> > > with OOM detection rework and huge page support for tmpfs.  It'll be easier
> > > and safer to resolve this outside of mmotm as it'll require a full round
> > > of testing which takes 3-4 days.
> > 
> > Ok. I've done a new version of my debug patch now, will follow up here
> > so you can do some testing on top of that as well if you like. We probably
> > don't want to apply my patch for the type checking, but you might find it
> > useful for your own testing.
> > 
> 
> It is useful. After fixing up a bunch of problems manually, it
> identified two more errors. I probably won't merge it but I'll hang on
> to it during development.

I'm glad it helps. On my randconfig build machine, I've also now run
into yet another finding that I originally didn't catch, not sure if you
found this one already:

In file included from ../include/linux/mm.h:999:0,
                 from ../include/linux/highmem.h:7,
                 from ../drivers/staging/lustre/lustre/osc/../../include/linux/libcfs/linux/libcfs.h:46,
                 from ../drivers/staging/lustre/lustre/osc/../../include/linux/libcfs/libcfs.h:36,
                 from ../drivers/staging/lustre/lustre/osc/osc_cl_internal.h:45,
                 from ../drivers/staging/lustre/lustre/osc/osc_cache.c:40:
../drivers/staging/lustre/lustre/osc/osc_cache.c: In function 'osc_dec_unstable_pages':
../include/linux/vmstat.h:247:42: error: comparison between 'enum node_stat_item' and 'enum zone_stat_item' [-Werror=enum-compare]
  dec_zone_page_state_check(page, ((item) == (enum zone_stat_item )0) ? (item) : (item))
                                          ^
../drivers/staging/lustre/lustre/osc/osc_cache.c:1867:3: note: in expansion of macro 'dec_zone_page_state'
   dec_zone_page_state(desc->bd_iov[i].kiov_page, NR_UNSTABLE_NFS);
   ^~~~~~~~~~~~~~~~~~~
../drivers/staging/lustre/lustre/osc/osc_cache.c: In function 'osc_inc_unstable_pages':
../include/linux/vmstat.h:245:42: error: comparison between 'enum node_stat_item' and 'enum zone_stat_item' [-Werror=enum-compare]
  inc_zone_page_state_check(page, ((item) == (enum zone_stat_item )0) ? (item) : (item))
                                          ^
../drivers/staging/lustre/lustre/osc/osc_cache.c:1901:3: note: in expansion of macro 'inc_zone_page_state'
   inc_zone_page_state(desc->bd_iov[i].kiov_page, NR_UNSTABLE_NFS);
   ^~~~~~~~~~~~~~~~~~~

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

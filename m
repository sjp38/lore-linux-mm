Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A60986B0260
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:15:36 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g18so53849710lfg.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:15:36 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id le1si183975wjb.30.2016.06.23.06.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 06:15:35 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC, DEBUGGING 1/2] mm: pass NR_FILE_PAGES/NR_SHMEM into node_page_state
Date: Thu, 23 Jun 2016 15:17:43 +0200
Message-ID: <3817461.6pThRKgN9N@wuerfel>
In-Reply-To: <20160623104124.GR1868@techsingularity.net>
References: <20160623100518.156662-1-arnd@arndb.de> <20160623104124.GR1868@techsingularity.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thursday, June 23, 2016 11:41:24 AM CEST Mel Gorman wrote:
> On Thu, Jun 23, 2016 at 12:05:17PM +0200, Arnd Bergmann wrote:
> > I see some new warnings from a recent mm change:
> > 
> > mm/filemap.c: In function '__delete_from_page_cache':
> > include/linux/vmstat.h:116:2: error: array subscript is above array bounds [-Werror=array-bounds]
> >   atomic_long_add(x, &zone->vm_stat[item]);
> >   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > include/linux/vmstat.h:116:35: error: array subscript is above array bounds [-Werror=array-bounds]
> >   atomic_long_add(x, &zone->vm_stat[item]);
> >                       ~~~~~~~~~~~~~^~~~~~
> > include/linux/vmstat.h:116:35: error: array subscript is above array bounds [-Werror=array-bounds]
> > include/linux/vmstat.h:117:2: error: array subscript is above array bounds [-Werror=array-bounds]
> > 
> > Looking deeper into it, I find that we pass the wrong enum
> > into some functions after the type for the symbol has changed.
> > 
> > This changes the code to use the other function for those that
> > are using the incorrect type. I've done this blindly just going
> > by warnings I got from a debug patch I did for this, so it's likely
> > that some cases are more subtle and need another change, so please
> > treat this as a bug-report rather than a patch for applying.
> > 
> 
> I have an alternative fix for this in a private tree. For now, I've asked
> Andrew to withdraw the series entirely as there are non-trivial collisions
> with OOM detection rework and huge page support for tmpfs.  It'll be easier
> and safer to resolve this outside of mmotm as it'll require a full round
> of testing which takes 3-4 days.

Ok. I've done a new version of my debug patch now, will follow up here
so you can do some testing on top of that as well if you like. We probably
don't want to apply my patch for the type checking, but you might find it
useful for your own testing.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

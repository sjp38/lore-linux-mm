Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAB7828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:41:28 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id js8so55594213lbc.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 03:41:28 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id l4si6504842wjt.26.2016.06.23.03.41.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 03:41:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 0EE2B98BD8
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 10:41:26 +0000 (UTC)
Date: Thu, 23 Jun 2016 11:41:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC, DEBUGGING 1/2] mm: pass NR_FILE_PAGES/NR_SHMEM into
 node_page_state
Message-ID: <20160623104124.GR1868@techsingularity.net>
References: <20160623100518.156662-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160623100518.156662-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 23, 2016 at 12:05:17PM +0200, Arnd Bergmann wrote:
> I see some new warnings from a recent mm change:
> 
> mm/filemap.c: In function '__delete_from_page_cache':
> include/linux/vmstat.h:116:2: error: array subscript is above array bounds [-Werror=array-bounds]
>   atomic_long_add(x, &zone->vm_stat[item]);
>   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> include/linux/vmstat.h:116:35: error: array subscript is above array bounds [-Werror=array-bounds]
>   atomic_long_add(x, &zone->vm_stat[item]);
>                       ~~~~~~~~~~~~~^~~~~~
> include/linux/vmstat.h:116:35: error: array subscript is above array bounds [-Werror=array-bounds]
> include/linux/vmstat.h:117:2: error: array subscript is above array bounds [-Werror=array-bounds]
> 
> Looking deeper into it, I find that we pass the wrong enum
> into some functions after the type for the symbol has changed.
> 
> This changes the code to use the other function for those that
> are using the incorrect type. I've done this blindly just going
> by warnings I got from a debug patch I did for this, so it's likely
> that some cases are more subtle and need another change, so please
> treat this as a bug-report rather than a patch for applying.
> 

I have an alternative fix for this in a private tree. For now, I've asked
Andrew to withdraw the series entirely as there are non-trivial collisions
with OOM detection rework and huge page support for tmpfs.  It'll be easier
and safer to resolve this outside of mmotm as it'll require a full round
of testing which takes 3-4 days.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

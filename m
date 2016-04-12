Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB5816B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:03:13 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id v188so118113330wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 02:03:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si33193266wjx.242.2016.04.12.02.03.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 02:03:12 -0700 (PDT)
Subject: Re: mmotm woes, mainly compaction
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570CB9CE.1070408@suse.cz>
Date: Tue, 12 Apr 2016 11:03:10 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/12/2016 09:18 AM, Hugh Dickins wrote:
> 3. /proc/sys/vm/stat_refresh warns nr_isolated_anon and nr_isolated_file
>     go increasingly negative under compaction: which would add delay when
>     should be none, or no delay when should delay.  putback_movable_pages()
>     decrements the NR_ISOLATED counts which acct_isolated() increments,
>     so isolate_migratepages_block() needs to acct before putback in that
>     special case, and isolate_migratepages_range() can always do the acct
>     itself, leaving migratepages putback to caller like most other places.

The isolate_migratepages_block() part is mmotm-specific, so I'll split
it out in this patch. Thanks for catching it and the lack of reset for
cc->nr_migratepages which wasn't mentioned in changelog so I added it.
 
> 5. It's easier to track the life of cc->migratepages if we don't assign
>     it to a migratelist variable.

This is also included here.

This is a -fix for:
mm-compaction-skip-blocks-where-isolation-fails-in-async-direct-compaction.patch

----8<----

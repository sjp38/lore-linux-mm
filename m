Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id BAE0D6B0044
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 23:52:35 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id um15so1703442pbc.30
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 20:52:34 -0800 (PST)
Date: Wed, 19 Dec 2012 20:52:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: migrate_misplaced_transhuge_page: no page_count check?
Message-ID: <alpine.LNX.2.00.1212192011320.25992@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Mel, Ingo,

I want to raise again a question I raised (in offline mail with Mel)
a couple of weeks ago.

I see only a page_mapcount check in migrate_misplaced_transhuge_page,
and don't understand how migration can be safe against the possibility
of an earlier call to get_user_pages or get_user_pages_fast (intended
to pin a part of the THP) without a page_count check.

(I'm also still somewhat worried about unidentified attempts to
pin the page concurrently; but since I don't have an example to give,
and concurrent get_user_pages or get_user_pages_fast wouldn't get past
the pmd_numa, let's not worry too much about my unidentified anxiety ;)

migrate_page_move_mapping and migrate_huge_page_move_mapping check
page_count, but migrate_misplaced_transhuge_page doesn't use those.
__collapse_huge_page_isolate and khugepaged_scan_pmd (over in
huge_memory.c) take commented care to check page_count lest GUP.

I can see that page_count might often be raised by concurrent faults
on the same pmd_numa, waiting on the lock_page in do_huge_pmd_numa_page.
That's unfortunate, and maybe you can find a clever way to discount
those.  But safety must come first: don't we need to check page_count?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

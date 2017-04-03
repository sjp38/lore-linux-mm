Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3828D6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 18:11:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u202so155268059pgb.9
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 15:11:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y11si15350403plg.84.2017.04.03.15.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 15:11:14 -0700 (PDT)
Date: Mon, 3 Apr 2017 15:11:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix print order in show_free_areas()
Message-Id: <20170403151111.4c9967329d6d6140e2a652ff@linux-foundation.org>
In-Reply-To: <1490377730.30219.2.camel@beget.ru>
References: <1490377730.30219.2.camel@beget.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Polakov <apolyakov@beget.ru>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>

On Fri, 24 Mar 2017 20:48:50 +0300 Alexander Polakov <apolyakov@beget.ru> wrote:

> Better seen in context: https://github.com/torvalds/linux/blob/master/m
> m/page_alloc.c#L4500
> 
> Signed-off-by: Alexander Polyakov <apolyakov@beget.com>

--- a/mm/page_alloc.c~fix-print-order-in-show_free_areas
+++ a/mm/page_alloc.c
@@ -4519,13 +4519,13 @@ void show_free_areas(unsigned int filter
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			K(node_page_state(pgdat, NR_FILE_DIRTY)),
 			K(node_page_state(pgdat, NR_WRITEBACK)),
+			K(node_page_state(pgdat, NR_SHMEM)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
 			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
 					* HPAGE_PMD_NR),
 			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
 #endif
-			K(node_page_state(pgdat, NR_SHMEM)),
 			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
 			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 			node_page_state(pgdat, NR_PAGES_SCANNED),
_

huh.  It looks like this has been broken for nearly a year, by

: commit 11fb998986a72aa7e997d96d63d52582a01228c5
: Author:     Mel Gorman <mgorman@techsingularity.net>
: AuthorDate: Thu Jul 28 15:46:20 2016 -0700
: Commit:     Linus Torvalds <torvalds@linux-foundation.org>
: CommitDate: Thu Jul 28 16:07:41 2016 -0700
: 
:     mm: move most file-based accounting to the node

I'm surprised nobody noticed until now.

btw, your email client is messing up the patches: tabs are getting
mangled and wordwrapping is added.  Please fix that up for next time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

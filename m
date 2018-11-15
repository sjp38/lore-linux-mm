Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38D266B062A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 17:30:04 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 89so1911196ple.19
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 14:30:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u23si28260920pgb.66.2018.11.15.14.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 14:30:02 -0800 (PST)
Date: Thu, 15 Nov 2018 14:29:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cleancache: fix corruption on missed inode
 invalidation
Message-Id: <20181115142959.89ecdb6b4f24a1427062d861@linux-foundation.org>
In-Reply-To: <20181112113153.GC7175@quack2.suse.cz>
References: <20181112095734.17979-1-ptikhomirov@virtuozzo.com>
	<20181112113153.GC7175@quack2.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>, Vasily Averin <vvs@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Konstantin Khorenko <khorenko@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Nov 2018 12:31:53 +0100 Jan Kara <jack@suse.cz> wrote:

> >  mm/truncate.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> The patch looks good but can you add a short comment before the
> truncate_inode_pages() call explaining why it needs to be called always?
> Something like:
> 
> 	 /*
> 	  * Cleancache needs notification even if there are no pages or
> 	  * shadow entries...
> 	  */

--- a/mm/truncate.c~mm-cleancache-fix-corruption-on-missed-inode-invalidation-fix
+++ a/mm/truncate.c
@@ -519,6 +519,10 @@ void truncate_inode_pages_final(struct a
 		xa_unlock_irq(&mapping->i_pages);
 	}
 
+	/*
+	 * Cleancache needs notification even if there are no pages or shadow
+	 * entries.
+	 */
 	truncate_inode_pages(mapping, 0);
 }
 EXPORT_SYMBOL(truncate_inode_pages_final);
_

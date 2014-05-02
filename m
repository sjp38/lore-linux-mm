Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 70D716B0038
	for <linux-mm@kvack.org>; Fri,  2 May 2014 06:22:38 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so3006172eek.8
        for <linux-mm@kvack.org>; Fri, 02 May 2014 03:22:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y41si1209054eel.140.2014.05.02.03.22.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 03:22:36 -0700 (PDT)
Date: Fri, 2 May 2014 11:22:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch v2 4/4] mm, thp: do not perform sync compaction on
 pagefault
Message-ID: <20140502102231.GQ23991@suse.de>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011435210.23898@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405011435210.23898@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 01, 2014 at 02:35:48PM -0700, David Rientjes wrote:
> Synchronous memory compaction can be very expensive: it can iterate an enormous 
> amount of memory without aborting, constantly rescheduling, waiting on page
> locks and lru_lock, etc, if a pageblock cannot be defragmented.
> 
> Unfortunately, it's too expensive for pagefault for transparent hugepages and 
> it's much better to simply fallback to pages.  On 128GB machines, we find that 
> synchronous memory compaction can take O(seconds) for a single thp fault.
> 
> Now that async compaction remembers where it left off without strictly relying
> on sync compaction, this makes thp allocations best-effort without causing
> egregious latency during pagefault.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Compaction uses MIGRATE_SYNC_LIGHT which in the current implementation
avoids calling ->writepage to clean dirty page in the fallback migrate
case

static int fallback_migrate_page(struct address_space *mapping,
        struct page *newpage, struct page *page, enum migrate_mode mode)
{
        if (PageDirty(page)) {
                /* Only writeback pages in full synchronous migration */
                if (mode != MIGRATE_SYNC)
                        return -EBUSY;
                return writeout(mapping, page);
        }

or waiting on page writeback in other cases

                /*
                 * Only in the case of a full synchronous migration is it
                 * necessary to wait for PageWriteback. In the async case,
                 * the retry loop is too short and in the sync-light case,
                 * the overhead of stalling is too much
                 */
                if (mode != MIGRATE_SYNC) {
                        rc = -EBUSY;
                        goto uncharge;
                }

or on acquiring the page lock for unforced migrations.

However, buffers still get locked in the SYNC_LIGHT case causing stalls
in buffer_migrate_lock_buffers which may be undesirable or maybe you are
hitting some other case. It would be preferable to identify what is
getting stalled in SYNC_LIGHT compaction and fix that rather than
disabling it entirely. You may also want to distinguish between a direct
compaction by a process and collapsing huge pages as done by khugepaged.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

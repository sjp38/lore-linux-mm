Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id B2D306B0062
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 06:31:24 -0400 (EDT)
Message-ID: <1340793075.10063.24.camel@twins>
Subject: Re: needed lru_add_drain_all() change
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 27 Jun 2012 12:31:15 +0200
In-Reply-To: <20120626234603.779f5cbb.akpm@linux-foundation.org>
References: <20120626143703.396d6d66.akpm@linux-foundation.org>
	 <4FEA59EE.8060804@kernel.org>
	 <20120626181504.23b8b73d.akpm@linux-foundation.org>
	 <4FEA6B5B.5000205@kernel.org>
	 <20120626221217.1682572a.akpm@linux-foundation.org>
	 <4FEA9D13.6070409@kernel.org>
	 <20120626225544.068df1b9.akpm@linux-foundation.org>
	 <4FEAA925.9020202@kernel.org>
	 <20120626234603.779f5cbb.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Tue, 2012-06-26 at 23:46 -0700, Andrew Morton wrote:
> btw, the first step should be to audit all lru_add_drain_all() sites
> and work out exactly why they are calling lru_add_drain_all() - what
> are they trying to achive?

# git grep lru_add_drain_all
fs/block_dev.c: lru_add_drain_all();    /* make sure all lru add caches are=
 flushed */
include/linux/swap.h:extern int lru_add_drain_all(void);
mm/compaction.c:        lru_add_drain_all();
mm/compaction.c:                lru_add_drain_all();
mm/ksm.c:               lru_add_drain_all();
mm/memcontrol.c:                lru_add_drain_all();
mm/memcontrol.c:        lru_add_drain_all();
mm/memcontrol.c:        lru_add_drain_all();
mm/memory-failure.c:            lru_add_drain_all();
mm/memory_hotplug.c:            lru_add_drain_all();
mm/memory_hotplug.c:    lru_add_drain_all();
mm/migrate.c:   lru_add_drain_all();
mm/migrate.c:    * here to avoid lru_add_drain_all().
mm/mlock.c:     lru_add_drain_all();    /* flush pagevec */
mm/mlock.c:             lru_add_drain_all();    /* flush pagevec */
mm/page_alloc.c:         * For avoiding noise data, lru_add_drain_all() sho=
uld be called
mm/page_alloc.c:        lru_add_drain_all();
mm/swap.c:int lru_add_drain_all(void)


I haven't audited all sites, but most of them try to flush the per-cpu
lru pagevecs to make sure the pages are on the lru so they can take them
off again ;-)

Take compaction for instance, if a page in the middle of a range is on a
per-cpu pagevec it can't move it and the compaction might fail.


Hmm, another alternative is teaching isolate_lru_page() and friends to
take pages from the pagevecs directly, not sure what that would take.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

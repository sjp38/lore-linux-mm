Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id BF72A6B00EF
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:01:24 -0400 (EDT)
Date: Mon, 14 May 2012 09:01:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Allow migration of mlocked page?
In-Reply-To: <1337003515.2443.35.camel@twins>
Message-ID: <alpine.DEB.2.00.1205140857380.26304@router.home>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de> <4FADA007.3020309@gmail.com> <20120514133210.GE29102@suse.de> <1337003515.2443.35.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon, 14 May 2012, Peter Zijlstra wrote:

> I'd say go for it, I've been telling everybody who would listen that
> mlock() only means no major faults for a very long time now.

We could introduce a new page flag PG_pinned (it already exists for Xen)
that would mean no faults on the page?

The situation with pinned pages is not clean right now because page count
increases should only signal temporary references to a page but subsystems
use an elevated page count to pin pages for good (f.e. Infiniband memory
registration). The reclaim logic has no way to differentiate between a
pinned page and a temporary reference count increase for page handling.

Therefore f.e. the page migration logic will repeatedly try to move the
page and always fail to account for all references.

A PG_pinned could allow us to make that distinction to avoid overhead in
the reclaim and page migration logic and also we could add some semantics
that avoid page faults.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

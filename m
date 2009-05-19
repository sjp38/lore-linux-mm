Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D03876B0055
	for <linux-mm@kvack.org>; Tue, 19 May 2009 02:55:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4J6uRS1027352
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 May 2009 15:56:27 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 359DD45DE62
	for <linux-mm@kvack.org>; Tue, 19 May 2009 15:56:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DB27645DD79
	for <linux-mm@kvack.org>; Tue, 19 May 2009 15:56:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B53E91DB803F
	for <linux-mm@kvack.org>; Tue, 19 May 2009 15:56:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67FC41DB803B
	for <linux-mm@kvack.org>; Tue, 19 May 2009 15:56:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class  citizen
In-Reply-To: <84144f020905182339o5fb1e78eved95c4c20fd9ffa7@mail.gmail.com>
References: <20090516090448.410032840@intel.com> <84144f020905182339o5fb1e78eved95c4c20fd9ffa7@mail.gmail.com>
Message-Id: <20090519155528.4EE1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 May 2009 15:56:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi

> Hi!
> 
> On Sat, May 16, 2009 at 12:00 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > @@ -1272,28 +1273,40 @@ static void shrink_active_list(unsigned
> >
> >        /* page_referenced clears PageReferenced */
> >        if (page_mapping_inuse(page) &&
> > -          page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
> > +          page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
> >            pgmoved++;
> > +            /*
> > +            * Identify referenced, file-backed active pages and
> > +            * give them one more trip around the active list. So
> > +            * that executable code get better chances to stay in
> > +            * memory under moderate memory pressure. Anon pages
> > +            * are ignored, since JVM can create lots of anon
> > +            * VM_EXEC pages.
> > +            */
> > +            if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> > +                list_add(&page->lru, &l_active);
> > +                continue;
> > +            }
> 
> Why do we need to skip JIT'd code? There are plenty of desktop
> applications that use Mono, for example, and it would be nice if we
> gave them the same treatment as native applications. Likewise, I am
> sure all browsers that use JIT for JavaScript need to be considered.

anon pages are already protected from streaming-io by get_scan_ratio().




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

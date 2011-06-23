Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id F0747900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 06:09:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 018DC3EE0AE
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 19:09:10 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB18745DE52
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 19:09:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B213B45DE4E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 19:09:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A49B21DB803B
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 19:09:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6747E1DB802F
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 19:09:09 +0900 (JST)
Date: Thu, 23 Jun 2011 19:01:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] mm: preallocate page before lock_page at filemap COW.
 (WasRe: [PATCH V2] mm: Do not keep page locked during page fault while
 charging it for memcg
Message-Id: <20110623190157.1bc8cbb9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110623090204.GE31593@tiehlicka.suse.cz>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
	<20110622121516.GA28359@infradead.org>
	<20110622123204.GC14343@tiehlicka.suse.cz>
	<20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623074133.GA31593@tiehlicka.suse.cz>
	<20110623170811.16f4435f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623090204.GE31593@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Lutz Vieweg <lvml@5t9.de>

On Thu, 23 Jun 2011 11:02:04 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 23-06-11 17:08:11, KAMEZAWA Hiroyuki wrote:
> > On Thu, 23 Jun 2011 09:41:33 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> [...]
> > > Other than that:
> > > Reviewed-by: Michal Hocko <mhocko@suse.cz>
> > > 
> > 
> > I found the page is added to LRU before charging. (In this case,
> > memcg's LRU is ignored.) I'll post a new version with a fix.
> 
> Yes, you are right. I have missed that.
> This means that we might race with reclaim which could evict the COWed
> page wich in turn would uncharge that page even though we haven't
> charged it yet.
> 
> Can we postpone page_add_new_anon_rmap to the charging path or it would
> just race somewhere else?
> 

I got a different idea. How about this ?
I think this will have benefit for non-memcg users under OOM, too.

A concerns is VM_FAULT_RETRY case but wait-for-lock will be much heavier
than preallocation + free-for-retry cost.

(I'm sorry I'll not be very active until the next week, so feel free to
 post your own version if necessary.)

This is onto -rc4 and worked well on my test.

==

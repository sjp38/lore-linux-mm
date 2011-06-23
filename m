Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 96583900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 02:16:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5CA933EE0C3
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:16:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AA7045DE9D
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:16:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 105B945DE9A
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:16:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 00CF4E08001
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:16:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 98B691DB804A
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:16:13 +0900 (JST)
Date: Thu, 23 Jun 2011 15:08:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: unlock page before charging it. (WasRe: [PATCH V2]
 mm: Do not keep page locked during page fault while charging it for memcg
Message-Id: <20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110622123204.GC14343@tiehlicka.suse.cz>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
	<20110622121516.GA28359@infradead.org>
	<20110622123204.GC14343@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Lutz Vieweg <lvml@5t9.de>

On Wed, 22 Jun 2011 14:32:04 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 22-06-11 08:15:16, Christoph Hellwig wrote:
> > > +
> > > +			/* We have to drop the page lock here because memcg
> > > +			 * charging might block for unbound time if memcg oom
> > > +			 * killer is disabled.
> > > +			 */
> > > +			unlock_page(vmf.page);
> > > +			ret = mem_cgroup_newpage_charge(page, mm, GFP_KERNEL);
> > > +			lock_page(vmf.page);
> > 
> > This introduces a completely poinless unlock/lock cycle for non-memcg
> > pagefaults.  Please make sure it only happens when actually needed.
> 
> Fair point. Thanks!
> What about the following?
> I realize that pushing more memcg logic into mm/memory.c is not nice but
> I found it better than pushing the old page into mem_cgroup_newpage_charge.
> We could also check whether the old page is in the root cgroup because
> memcg oom killer is not active there but that would add more code into
> this hot path so I guess it is not worth it.
> 
> Changes since v1
> - do not unlock page when memory controller is disabled.
> 

Great work. Then I confirmed Lutz' problem is fixed.

But I like following style rather than additional lock/unlock.
How do you think ? I tested this on the latest git tree and confirmed
the Lutz's livelock problem is fixed. And I think this should go stable tree.


==

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0C98B6B01C6
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 22:24:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5G2OoQN029118
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Jun 2010 11:24:50 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E38045DE53
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 11:24:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EBF045DE52
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 11:24:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EAECEE08005
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 11:24:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F44BE18003
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 11:24:49 +0900 (JST)
Date: Wed, 16 Jun 2010 11:20:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
Message-Id: <20100616112024.5b093905.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100616104036.b45d352b.kamezawa.hiroyu@jp.fujitsu.com>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-13-git-send-email-mel@csn.ul.ie>
	<4C16A567.4080000@redhat.com>
	<20100615114510.GE26788@csn.ul.ie>
	<4C17815A.8080402@redhat.com>
	<20100615135928.GK26788@csn.ul.ie>
	<4C178868.2010002@redhat.com>
	<20100615141601.GL26788@csn.ul.ie>
	<20100616091755.7121c7d3.kamezawa.hiroyu@jp.fujitsu.com>
	<4C181AFD.5060503@redhat.com>
	<20100616093958.00673123.kamezawa.hiroyu@jp.fujitsu.com>
	<4C182097.2070603@redhat.com>
	<20100616104036.b45d352b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jun 2010 10:40:36 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 15 Jun 2010 20:53:43 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > On 06/15/2010 08:39 PM, KAMEZAWA Hiroyuki wrote:
> > 
> > > Hmm, or do you recommend no-dirty-page-writeback when a memcg hits limit ?
> > > Maybe we'll see much swaps.
> > >
> > > I want to go with this for a while, changing memcg's behavior will took
> > > some amounts of time, there are only a few developpers.
> > 
> > One thing we can do, for kswapd, memcg and direct reclaim alike,
> > is to tell the flusher threads to flush pages related to a pageout
> > candidate page to disk.
> > 
> > That way the reclaiming processes can wait on some disk IO to
> > finish, while the flusher thread takes care of the actual flushing.
> > 
> > That should also fix the "kswapd filesystem IO has really poor IO
> > patterns" issue.
> > 
> > There's no reason not to fix this issue the right way.
> > 
> yes. but this patch just stops writeback. I think it's sane to ask
> not to change behavior until there are some useful changes in flusher
> threads.
> 
> IMO, until flusher threads can work with I/O cgroup, memcg shoudln't
> depend on it because writeback allows stealing resource without it.
> 

BTW, copy_from_user/copy_to_user is _real_ problem, I'm afraid following
much more than memcg.

handle_mm_fault()
-> handle_pte_fault()
-> do_wp_page()
-> balance_dirty_page_rate_limited()
-> balance_dirty_pages()
-> writeback_inodes_wbc()
-> writeback_inodes_wb()
-> writeback_sb_inodes()
-> writeback_single_inode()
-> do_writepages()
-> generic_write_pages()
-> write_cache_pages()   // use on-stack pagevec.
-> writepage()

maybe much more stack consuming than memcg->writeback after vmscan.c diet.

Bye.
-Kame


















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

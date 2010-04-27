Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BA8256B01E3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 05:14:06 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3R9Dx3h031150
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Apr 2010 18:13:59 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FA6145DE52
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 18:13:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 036C245DE50
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 18:13:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D3B281DB801C
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 18:13:58 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BCAA1DB8017
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 18:13:58 +0900 (JST)
Date: Tue, 27 Apr 2010 18:09:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-Id: <20100427180949.673350f2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100427085951.GB4895@csn.ul.ie>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
	<1272321478-28481-3-git-send-email-mel@csn.ul.ie>
	<20100427090706.7ca68e12.kamezawa.hiroyu@jp.fujitsu.com>
	<20100427125040.634f56b3.kamezawa.hiroyu@jp.fujitsu.com>
	<20100427085951.GB4895@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Apr 2010 09:59:51 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Tue, Apr 27, 2010 at 12:50:40PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 27 Apr 2010 09:07:06 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Mon, 26 Apr 2010 23:37:58 +0100
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > vma_adjust() is updating anon VMA information without any locks taken.
> > > > In contrast, file-backed mappings use the i_mmap_lock and this lack of
> > > > locking can result in races with page migration. During rmap_walk(),
> > > > vma_address() can return -EFAULT for an address that will soon be valid.
> > > > This leaves a dangling migration PTE behind which can later cause a BUG_ON
> > > > to trigger when the page is faulted in.
> > > > 
> > > > With the recent anon_vma changes, there can be more than one anon_vma->lock
> > > > that can be taken in a anon_vma_chain but a second lock cannot be spinned
> > > > upon in case of deadlock. Instead, the rmap walker tries to take locks of
> > > > different anon_vma's. If the attempt fails, the operation is restarted.
> > > > 
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > 
> > > Ok, acquiring vma->anon_vma->spin_lock always sounds very safe.
> > > (but slow.)
> > > 
> > > I'll test this, too.
> > > 
> > > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > 
> > Sorry. reproduced. It seems the same bug before patch. 
> > mapcount 1 -> unmap -> remap -> mapcount 0. And it was SwapCache.
> > 
> 
> Same here, reproduced after 18 hours.
> 
Hmm. It seems rmap_one() is called and the race is not in vma_address()
but in remap_migration_pte().
So, I added more hooks for debug..but not reproduced yet.
(But I doubt my debug code, too ;)

But it seems strange to have a race in remap_migration_pte(), so, I doubt
my debug code, too.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

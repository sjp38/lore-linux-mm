Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE106B0211
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 02:18:38 -0400 (EDT)
Date: Tue, 13 Apr 2010 16:18:02 +1000
From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100413161802.498336ca@notabene.brown>
In-Reply-To: <20100412203829.871f1dee.akpm@linux-foundation.org>
References: <4BC0DE84.3090305@redhat.com>
	<20100411104608.GA12828@elte.hu>
	<4BC1B2CA.8050208@redhat.com>
	<20100411120800.GC10952@elte.hu>
	<20100412060931.GP5683@laptop>
	<4BC2BF67.80903@redhat.com>
	<20100412071525.GR5683@laptop>
	<4BC2CF8C.5090108@redhat.com>
	<20100412082844.GU5683@laptop>
	<4BC2E1D6.9040702@redhat.com>
	<20100412092615.GY5683@laptop>
	<4BC2EFBA.5080404@redhat.com>
	<20100412203829.871f1dee.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Avi Kivity <avi@redhat.com>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael  S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Apr 2010 20:38:29 -0400
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 12 Apr 2010 13:02:34 +0300 Avi Kivity <avi@redhat.com> wrote:
> 
> > The only scenario I can see where it degrades is that you have a dcache 
> > load that spills over to all of memory, then falls back leaving a pinned 
> > page in every huge frame.  It can happen, but I don't see it as a likely 
> > scenario.  But maybe I'm missing something.
> 
> <prehistoric memory>
> 
> This used to happen fairly easily.  You have a directory tree and some
> app which walks down and across it, stat()ing regular files therein. 
> So you end up with dentries and inodes which are laid out in memory as
> dir-file-file-file-file-...-file-dir-file-...  Then the file
> dentries/inodes get reclaimed and you're left with a sparse collection
> of directory dcache/icache entries - massively fragmented.
> 
> I forget _why_ it happened.  Perhaps because S_ISREG cache items aren't
> pinned by anything, but S_ISDIR cache items are pinned by their children
> so it takes many more expiry rounds to get rid of them.
> 
> There was talk about fixing this, perhaps by using different slab
> caches for dirs vs files.  Hard, because the type of the file/inode
> isn't known at allocation time.  Nothing happened about it.

Actually I don't think that would be hard at all.
->lookup can return a different dentry than the one passed in, usually using
d_splice_alias to find it.
So when you create an inode for a directory, create an anonymous dentry,
attach it via i_dentry, and it should "just work".
That is assuming this is still a "problem" that needs to be "fixed".

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

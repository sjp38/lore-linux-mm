Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA02710
	for <linux-mm@kvack.org>; Mon, 21 Oct 2002 20:39:43 -0700 (PDT)
Message-ID: <3DB4C87E.7CF128F3@digeo.com>
Date: Mon, 21 Oct 2002 20:39:42 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
References: <3DB4855F.D5DA002E@digeo.com> <326730000.1035246693@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> >> On Mon, 21 Oct 2002, Martin J. Bligh wrote:
> >>
> >> > > Blockdevices only use ZONE_NORMAL for their pagecache.  That cat will
> >> > > selectively put pressure on the normal zone (and DMA zone, of course).
> >> >
> >> > Ah, I recall that now. That's fundamentally screwed.
> >>
> >> It's not too bad since the data can be reclaimed easily.
> >>
> >> The problem in your case is that the dentry and inode cache
> >> didn't get reclaimed. Maybe there is a leak so they can't get
> >> reclaimed at all or maybe they just don't get reclaimed fast
> >> enough.
> 
> OK, well "find / | xargs ls -l" results in:
> 
> dentry_cache      1125216 1125216    160 46884 46884    1 :  248  124
> 
> repeating it gives
> 
> dentry_cache      969475 1140960    160 47538 47540    1 :  248  124
> 
> Which is only a third of what I eventually ended up with over the weekend,
> so presumably that means you're correct and there is a leak.

I cannot make it happen here, either.  2.5.43-mm2 or current devel
stuff.  Heisenbug; maybe something broke dcache-rcu?  Or the math
overflow (unlikely).

> Hmmm .... but why did it shrink ... I didn't expect mem pressure just
> doing a find ....

Maybe because the ext2 inode cache didn't shrink as it should have.

The dentry/inode caches are pretty much FIFO with this sort of test,
and you're showing the traditional worst-case FIFO replacement behaviour.

> ...
> ext2_inode_cache  921200 938547    416 104283 104283    1 :  120   60
> dentry_cache      1068133 1131096    160 47129 47129    1 :  248  124
> 
> So it looks as though it's actually ext2_inode cache that's first against the wall.

Well that's to be expected.  Each ext2 directory inode has highmem
pagecache attached to it, which pins the inode.  There's no highmem
eviction pressure so your normal zone gets stuffed full of inodes.

There's a fix for this in Andrea's tree, although that's perhaps a
bit heavy on inode_lock for 2.5 purposes.  It's a matter of running
invalidate_inode_pages() against the inodes as they come off the
unused_list.  I haven't got around to it yet.

> For comparison, over the weekend I ended up with:
> 
> ext2_inode_cache  554556 554598    416 61622 61622    1 :  120   60
> dentry_cache      2791320 2791320    160 116305 116305    1 :  248  124
> 
> did a cat of /dev/sda2 > /dev/null ..... after that:
> 
> larry:~# egrep '(dentry|inode)' /proc/slabinfo
> isofs_inode_cache      0      0    320    0    0    1 :  120   60
> ext2_inode_cache  667345 809181    416 89909 89909    1 :  120   60
> shmem_inode_cache      3      9    416    1    1    1 :  120   60
> sock_inode_cache      16     22    352    2    2    1 :  120   60
> proc_inode_cache      12     12    320    1    1    1 :  120   60
> inode_cache          385    396    320   33   33    1 :  120   60
> dentry_cache      1068289 1131096    160 47129 47129    1 :  248  124

OK, so there's reasonable dentry shrinkage there, and the inodes
for regular files whch have no attached pagecache were reaped.
But all the directory inodes are sitting there pinned.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

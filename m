Date: Sun, 24 Sep 2000 22:43:03 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000924224303.C2615@redhat.com>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu>; from mingo@elte.hu on Sun, Sep 24, 2000 at 11:12:39PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Sep 24, 2000 at 11:12:39PM +0200, Ingo Molnar wrote:
> 
> > ext2_new_block (or whatever that runs getblk with the superlock lock
> > acquired)->getblk->GFP->shrink_dcache_memory->prune_dcache->
> > prune_one_dentry->dput->dentry_iput->iput->inode->i_sb->s_op->
> > put_inode->ext2_discard_prealloc->ext2_free_blocks->lock_super->D
> 
> nasty indeed, sigh. Shouldnt ext2_new_block drop the superblock lock in
> places where we might block?

That's only a valid fix if there are no other filesystems, and no
other places in ext2, where we can call GFP with locks which prevent a
put_inode from being incurred.  And with the quota case to consider,
you have to avoid calling GFP with a lock against quota file writes
too (and since quota writes may GFP, this would deadlock if there was
any form of serialisation on the quota file).  This feels like rather
a lot of new and interesting deadlocks to be introducing so late in
2.4.  :-)

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id CF5456B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 02:26:31 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id eb20so3231243lab.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 23:26:29 -0700 (PDT)
Date: Tue, 18 Jun 2013 10:26:24 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130618062623.GA20528@localhost.localdomain>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <20130617223004.GB2538@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 18, 2013 at 02:30:05AM +0400, Glauber Costa wrote:
> On Mon, Jun 17, 2013 at 02:35:08PM -0700, Andrew Morton wrote:
> > On Mon, 17 Jun 2013 19:14:12 +0400 Glauber Costa <glommer@gmail.com> wrote:
> > 
> > > > I managed to trigger:
> > > > [ 1015.776029] kernel BUG at mm/list_lru.c:92!
> > > > [ 1015.776029] invalid opcode: 0000 [#1] SMP
> > > > with Linux next (next-20130607) with https://lkml.org/lkml/2013/6/17/203
> > > > on top. 
> > > > 
> > > > This is obviously BUG_ON(nlru->nr_items < 0) and 
> > > > ffffffff81122d0b:       48 85 c0                test   %rax,%rax
> > > > ffffffff81122d0e:       49 89 44 24 18          mov    %rax,0x18(%r12)
> > > > ffffffff81122d13:       0f 84 87 00 00 00       je     ffffffff81122da0 <list_lru_walk_node+0x110>
> > > > ffffffff81122d19:       49 83 7c 24 18 00       cmpq   $0x0,0x18(%r12)
> > > > ffffffff81122d1f:       78 7b                   js     ffffffff81122d9c <list_lru_walk_node+0x10c>
> > > > [...]
> > > > ffffffff81122d9c:       0f 0b                   ud2
> > > > 
> > > > RAX is -1UL.
> > > Yes, fearing those kind of imbalances, we decided to leave the counter as a signed quantity
> > > and BUG, instead of an unsigned quantity.
> > > 
> > > > 
> > > > I assume that the current backtrace is of no use and it would most
> > > > probably be some shrinker which doesn't behave.
> > > > 
> > > There are currently 3 users of list_lru in tree: dentries, inodes and xfs.
> > > Assuming you are not using xfs, we are left with dentries and inodes.
> > > 
> > > The first thing to do is to find which one of them is misbehaving. You can try finding
> > > this out by the address of the list_lru, and where it lays in the superblock.
> > > 
> > > Once we know each of them is misbehaving, then we'll have to figure out why.
> > 
> > The trace says shrink_slab_node->super_cache_scan->prune_icache_sb.  So
> > it's inodes?
> > 
> Assuming there is no memory corruption of any sort going on , let's check the code.
> nr_item is only manipulated in 3 places:
> 
> 1) list_lru_add, where it is increased
> 2) list_lru_del, where it is decreased in case the user have voluntarily removed the
>    element from the list
> 3) list_lru_walk_node, where an element is removing during shrink.
> 
> All three excerpts seem to be correctly locked, so something like this indicates an imbalance.
> Either the element was never added to the list, or it was added, removed, and we didn't notice
> it. (Again, your backing storage is not XFS, is it? If it is , we have another user to look for)
> 
> I will assume that Andrew is correct and this is inode related. list_lru_del reads as follows:
>         spin_lock(&nlru->lock);
>         if (!list_empty(item)) { ... }
> 
> So one possibility is that we are manipulating this list outside this lock somewhere. Going to
> inode.c... We always manipulate the LRU inside the lock, but the element is not always in the LRU,
> if it is in a list. Could it be possible that the element is in the dispose_list, and at the same
> time someone calls list_lru_del at it, creating the imbalance ?
> 
> callers:
> iput_final, evict_inodes, invalidate_inodes.
> Both evict_inodes and invalidate_inodes will do the following pattern:
> 
>                 inode->i_state |= I_FREEING;                                            
>                 inode_lru_list_del(inode);
>                 spin_unlock(&inode->i_lock);
>                 list_add(&inode->i_lru, &dispose);
> 
> IOW, they will remove the element from the LRU, and add it to the dispose list.
> Both of them will also bail out if they see I_FREEING already set, so they are safe
> against each other - because the flag is manipulated inside the lock.
> 
> But how about iput_final? It seems to me that if we are calling iput_final at the
> same time as the other two, this *could* happen (maybe there is some extra protection
> that can be seen from Australia but not from here. Dave?)
> 
> Right now this is my best theory.
> 
> I am attaching a patch that should make a difference in case I am right.
> 
> 
> 

Which is obviously borked since I did not fix the other callers so to move I_FREEING
after lru del.

Michal, would you mind testing the following patch?


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="inode.patch"

diff --git a/fs/inode.c b/fs/inode.c
index 00b804e..48eafa6 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -419,6 +419,8 @@ void inode_add_lru(struct inode *inode)
 
 static void inode_lru_list_del(struct inode *inode)
 {
+	if (inode->i_state & I_FREEING)
+		return;
 
 	if (list_lru_del(&inode->i_sb->s_inode_lru, &inode->i_lru))
 		this_cpu_dec(nr_unused);
@@ -609,8 +611,8 @@ void evict_inodes(struct super_block *sb)
 			continue;
 		}
 
-		inode->i_state |= I_FREEING;
 		inode_lru_list_del(inode);
+		inode->i_state |= I_FREEING;
 		spin_unlock(&inode->i_lock);
 		list_add(&inode->i_lru, &dispose);
 	}
@@ -653,8 +655,8 @@ int invalidate_inodes(struct super_block *sb, bool kill_dirty)
 			continue;
 		}
 
-		inode->i_state |= I_FREEING;
 		inode_lru_list_del(inode);
+		inode->i_state |= I_FREEING;
 		spin_unlock(&inode->i_lock);
 		list_add(&inode->i_lru, &dispose);
 	}
@@ -1381,9 +1383,8 @@ static void iput_final(struct inode *inode)
 		inode->i_state &= ~I_WILL_FREE;
 	}
 
+	inode_lru_list_del(inode);
 	inode->i_state |= I_FREEING;
-	if (!list_empty(&inode->i_lru))
-		inode_lru_list_del(inode);
 	spin_unlock(&inode->i_lock);
 
 	evict(inode);

--ZGiS0Q5IWpPtfppv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

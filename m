Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id AA6EE6B00A4
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:14:31 -0400 (EDT)
Date: Mon, 15 Jul 2013 11:14:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130715091428.GA26199@dhcp22.suse.cz>
References: <20130629025509.GG9047@dastard>
 <20130630183349.GA23731@dhcp22.suse.cz>
 <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
 <20130704163643.GF7833@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130704163643.GF7833@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 04-07-13 18:36:43, Michal Hocko wrote:
> On Wed 03-07-13 21:24:03, Dave Chinner wrote:
> > On Tue, Jul 02, 2013 at 02:44:27PM +0200, Michal Hocko wrote:
> > > On Tue 02-07-13 22:19:47, Dave Chinner wrote:
> > > [...]
> > > > Ok, so it's been leaked from a dispose list somehow. Thanks for the
> > > > info, Michal, it's time to go look at the code....
> > > 
> > > OK, just in case we will need it, I am keeping the machine in this state
> > > for now. So we still can play with crash and check all the juicy
> > > internals.
> > 
> > My current suspect is the LRU_RETRY code. I don't think what it is
> > doing is at all valid - list_for_each_safe() is not safe if you drop
> > the lock that protects the list. i.e. there is nothing that protects
> > the stored next pointer from being removed from the list by someone
> > else. Hence what I think is occurring is this:
> > 
> > 
> > thread 1			thread 2
> > lock(lru)
> > list_for_each_safe(lru)		lock(lru)
> >   isolate			......
> >     lock(i_lock)
> >     has buffers
> >       __iget
> >       unlock(i_lock)
> >       unlock(lru)
> >       .....			(gets lru lock)
> >       				list_for_each_safe(lru)
> > 				  walks all the inodes
> > 				  finds inode being isolated by other thread
> > 				  isolate
> > 				    i_count > 0
> > 				      list_del_init(i_lru)
> > 				      return LRU_REMOVED;
> > 				   moves to next inode, inode that
> > 				   other thread has stored as next
> > 				   isolate
> > 				     i_state |= I_FREEING
> > 				     list_move(dispose_list)
> > 				     return LRU_REMOVED
> > 				 ....
> > 				 unlock(lru)
> >       lock(lru)
> >       return LRU_RETRY;
> >   if (!first_pass)
> >     ....
> >   --nr_to_scan
> >   (loop again using next, which has already been removed from the
> >   LRU by the other thread!)
> >   isolate
> >     lock(i_lock)
> >     if (i_state & ~I_REFERENCED)
> >       list_del_init(i_lru)	<<<<< inode is on dispose list!
> > 				<<<<< inode is now isolated, with I_FREEING set
> >       return LRU_REMOVED;
> > 
> > That fits the corpse left on your machine, Michal. One thread has
> > moved the inode to a dispose list, the other thread thinks it is
> > still on the LRU and should be removed, and removes it.
> > 
> > This also explains the lru item count going negative - the same item
> > is being removed from the lru twice. So it seems like all the
> > problems you've been seeing are caused by this one problem....
> > 
> > Patch below that should fix this.
> 
> Good news! The test was running since morning and it didn't hang nor
> crashed. So this really looks like the right fix. It will run also
> during weekend to be 100% sure. But I guess it is safe to say
> 
> Tested-by: Michal Hocko <mhocko@suse.cz>

And I can finally confirm this after over weekend testing on ext3.

Thanks a lot for your help Dave!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

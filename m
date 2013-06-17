Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 611616B0031
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 12:54:16 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id y6so2720402lbh.37
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 09:54:14 -0700 (PDT)
Date: Mon, 17 Jun 2013 20:54:10 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130617165409.GA10764@localhost.localdomain>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617153302.GI5018@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617153302.GI5018@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 17, 2013 at 05:33:02PM +0200, Michal Hocko wrote:
> On Mon 17-06-13 19:14:12, Glauber Costa wrote:
> > On Mon, Jun 17, 2013 at 04:18:22PM +0200, Michal Hocko wrote:
> > > Hi,
> > 
> > Hi,
> > 
> > > I managed to trigger:
> > > [ 1015.776029] kernel BUG at mm/list_lru.c:92!
> > > [ 1015.776029] invalid opcode: 0000 [#1] SMP
> > > with Linux next (next-20130607) with https://lkml.org/lkml/2013/6/17/203
> > > on top. 
> > > 
> > > This is obviously BUG_ON(nlru->nr_items < 0) and 
> > > ffffffff81122d0b:       48 85 c0                test   %rax,%rax
> > > ffffffff81122d0e:       49 89 44 24 18          mov    %rax,0x18(%r12)
> > > ffffffff81122d13:       0f 84 87 00 00 00       je     ffffffff81122da0 <list_lru_walk_node+0x110>
> > > ffffffff81122d19:       49 83 7c 24 18 00       cmpq   $0x0,0x18(%r12)
> > > ffffffff81122d1f:       78 7b                   js     ffffffff81122d9c <list_lru_walk_node+0x10c>
> > > [...]
> > > ffffffff81122d9c:       0f 0b                   ud2
> > > 
> > > RAX is -1UL.
> >
> > Yes, fearing those kind of imbalances, we decided to leave the counter
> > as a signed quantity and BUG, instead of an unsigned quantity.
> > 
> > > I assume that the current backtrace is of no use and it would most
> > > probably be some shrinker which doesn't behave.
> > > 
> > There are currently 3 users of list_lru in tree: dentries, inodes and xfs.
> > Assuming you are not using xfs, we are left with dentries and inodes.
> > 
> > The first thing to do is to find which one of them is misbehaving. You
> > can try finding this out by the address of the list_lru, and where it
> > lays in the superblock.
> 
> I am not sure I understand. Care to prepare a debugging patch for me?
>  
> > Once we know each of them is misbehaving, then we'll have to figure
> > out why.
> > 
> > Any special filesystem workload ?
> 
> This is two parallel kernel builds with separate kernel trees running
> under 2 hard unlimitted groups (with 0 soft limit) followed by rm -rf
> source trees + drop caches. Sometimes I have to repeat this multiple
> times. I can also see some timer specific crashes which are most
> probably not related so I am getting back to my mm tree and will hope
> the tree is healthy.
> 
> I have seen some other traces as well (mentioning ext3 dput paths) but I
> cannot reproduce them anymore.
> 

Do you have those traces? If there is a bug in the ext3 dput, then it is
most likely the culprit. dput() is when we insert things into the LRU. So
if we are not fully inserting an element that we should have - and later
on try to remove it, we'll go negative.

Can we see those traces?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

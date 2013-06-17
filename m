Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A2B576B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 11:33:04 -0400 (EDT)
Date: Mon, 17 Jun 2013 17:33:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130617153302.GI5018@dhcp22.suse.cz>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617151403.GA25172@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 17-06-13 19:14:12, Glauber Costa wrote:
> On Mon, Jun 17, 2013 at 04:18:22PM +0200, Michal Hocko wrote:
> > Hi,
> 
> Hi,
> 
> > I managed to trigger:
> > [ 1015.776029] kernel BUG at mm/list_lru.c:92!
> > [ 1015.776029] invalid opcode: 0000 [#1] SMP
> > with Linux next (next-20130607) with https://lkml.org/lkml/2013/6/17/203
> > on top. 
> > 
> > This is obviously BUG_ON(nlru->nr_items < 0) and 
> > ffffffff81122d0b:       48 85 c0                test   %rax,%rax
> > ffffffff81122d0e:       49 89 44 24 18          mov    %rax,0x18(%r12)
> > ffffffff81122d13:       0f 84 87 00 00 00       je     ffffffff81122da0 <list_lru_walk_node+0x110>
> > ffffffff81122d19:       49 83 7c 24 18 00       cmpq   $0x0,0x18(%r12)
> > ffffffff81122d1f:       78 7b                   js     ffffffff81122d9c <list_lru_walk_node+0x10c>
> > [...]
> > ffffffff81122d9c:       0f 0b                   ud2
> > 
> > RAX is -1UL.
>
> Yes, fearing those kind of imbalances, we decided to leave the counter
> as a signed quantity and BUG, instead of an unsigned quantity.
> 
> > I assume that the current backtrace is of no use and it would most
> > probably be some shrinker which doesn't behave.
> > 
> There are currently 3 users of list_lru in tree: dentries, inodes and xfs.
> Assuming you are not using xfs, we are left with dentries and inodes.
> 
> The first thing to do is to find which one of them is misbehaving. You
> can try finding this out by the address of the list_lru, and where it
> lays in the superblock.

I am not sure I understand. Care to prepare a debugging patch for me?
 
> Once we know each of them is misbehaving, then we'll have to figure
> out why.
> 
> Any special filesystem workload ?

This is two parallel kernel builds with separate kernel trees running
under 2 hard unlimitted groups (with 0 soft limit) followed by rm -rf
source trees + drop caches. Sometimes I have to repeat this multiple
times. I can also see some timer specific crashes which are most
probably not related so I am getting back to my mm tree and will hope
the tree is healthy.

I have seen some other traces as well (mentioning ext3 dput paths) but I
cannot reproduce them anymore.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

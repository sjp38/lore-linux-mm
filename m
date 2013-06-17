Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 7070D6B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 11:14:18 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id d10so2645548lbj.14
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 08:14:16 -0700 (PDT)
Date: Mon, 17 Jun 2013 19:14:12 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130617151403.GA25172@localhost.localdomain>
References: <20130617141822.GF5018@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617141822.GF5018@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 17, 2013 at 04:18:22PM +0200, Michal Hocko wrote:
> Hi,

Hi,

> I managed to trigger:
> [ 1015.776029] kernel BUG at mm/list_lru.c:92!
> [ 1015.776029] invalid opcode: 0000 [#1] SMP
> with Linux next (next-20130607) with https://lkml.org/lkml/2013/6/17/203
> on top. 
> 
> This is obviously BUG_ON(nlru->nr_items < 0) and 
> ffffffff81122d0b:       48 85 c0                test   %rax,%rax
> ffffffff81122d0e:       49 89 44 24 18          mov    %rax,0x18(%r12)
> ffffffff81122d13:       0f 84 87 00 00 00       je     ffffffff81122da0 <list_lru_walk_node+0x110>
> ffffffff81122d19:       49 83 7c 24 18 00       cmpq   $0x0,0x18(%r12)
> ffffffff81122d1f:       78 7b                   js     ffffffff81122d9c <list_lru_walk_node+0x10c>
> [...]
> ffffffff81122d9c:       0f 0b                   ud2
> 
> RAX is -1UL.
Yes, fearing those kind of imbalances, we decided to leave the counter as a signed quantity
and BUG, instead of an unsigned quantity.

> 
> I assume that the current backtrace is of no use and it would most
> probably be some shrinker which doesn't behave.
> 
There are currently 3 users of list_lru in tree: dentries, inodes and xfs.
Assuming you are not using xfs, we are left with dentries and inodes.

The first thing to do is to find which one of them is misbehaving. You can try finding
this out by the address of the list_lru, and where it lays in the superblock.

Once we know each of them is misbehaving, then we'll have to figure out why.

Any special filesystem workload ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

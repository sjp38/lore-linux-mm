Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 884296B0034
	for <linux-mm@kvack.org>; Sun, 23 Jun 2013 07:51:34 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id eb20so9091714lab.29
        for <linux-mm@kvack.org>; Sun, 23 Jun 2013 04:51:32 -0700 (PDT)
Date: Sun, 23 Jun 2013 15:51:29 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130623115127.GA7986@localhost.localdomain>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618062623.GA20528@localhost.localdomain>
 <20130619071346.GA9545@dhcp22.suse.cz>
 <20130619142801.GA21483@dhcp22.suse.cz>
 <20130620141136.GA3351@localhost.localdomain>
 <20130620151201.GD27196@dhcp22.suse.cz>
 <20130621090021.GB12424@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130621090021.GB12424@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 21, 2013 at 11:00:21AM +0200, Michal Hocko wrote:
> On Thu 20-06-13 17:12:01, Michal Hocko wrote:
> > I am bisecting it again. It is quite tedious, though, because good case
> > is hard to be sure about.
> 
> OK, so now I converged to 2d4fc052 (inode: convert inode lru list to generic lru
> list code.) in my tree and I have double checked it matches what is in
> the linux-next. This doesn't help much to pin point the issue I am
> afraid :/
> 
Can you revert this patch (easiest way ATM is to rewind your tree to a point
right before it) and apply the following patch?

As Dave has mentioned, it is very likely that this bug was already there, we
were just not ever checking imbalances. The attached patch would tell us at
least if the imbalance was there before. If this is the case, I would suggest
turning the BUG condition into a WARN_ON_ONCE since we would be officially
not introducing any regression. It is no less of a bug, though, and we should
keep looking for it.

The main change from before / after the patch is that we are now keeping things
per node. One possibility of having this BUGing would be to have an inode to be
inserted into one node-lru and removed from another. I cannot see how it could
happen, because kernel pages are stable in memory and are not moved from node
to node. We could still have some sort of weird bug in the node calculation
function. In any case, would it be possible for you to artificially restrict
your setup to a single node ? Although I have no idea how to do that, we seem
to have no parameter to disable numa. Maybe booting with less memory, enough to
fit a single node?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

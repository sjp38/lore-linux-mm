Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 743726B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 04:19:33 -0400 (EDT)
Date: Tue, 18 Jun 2013 10:19:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130618081931.GB13677@dhcp22.suse.cz>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617223004.GB2538@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 18-06-13 02:30:05, Glauber Costa wrote:
> On Mon, Jun 17, 2013 at 02:35:08PM -0700, Andrew Morton wrote:
[...]
> > The trace says shrink_slab_node->super_cache_scan->prune_icache_sb.  So
> > it's inodes?
> > 
> Assuming there is no memory corruption of any sort going on , let's
> check the code. nr_item is only manipulated in 3 places:
> 
> 1) list_lru_add, where it is increased
> 2) list_lru_del, where it is decreased in case the user have voluntarily removed the
>    element from the list
> 3) list_lru_walk_node, where an element is removing during shrink.
> 
> All three excerpts seem to be correctly locked, so something like this
> indicates an imbalance.  Either the element was never added to the
> list, or it was added, removed, and we didn't notice it. (Again, your
> backing storage is not XFS, is it? If it is , we have another user to
> look for)

No this is ext3. But I can try to test with xfs as well if it helps.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

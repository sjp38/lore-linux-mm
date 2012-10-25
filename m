Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 9319A6B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 02:59:50 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1024951pad.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 23:59:49 -0700 (PDT)
Date: Wed, 24 Oct 2012 23:59:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
In-Reply-To: <5088C51D.3060009@gmail.com>
Message-ID: <alpine.LNX.2.00.1210242338030.2688@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <5088C51D.3060009@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 25 Oct 2012, Ni zhan Chen wrote:
> On 10/25/2012 12:36 PM, Hugh Dickins wrote:
> > On Wed, 24 Oct 2012, Dave Jones wrote:
> > 
> > > Machine under significant load (4gb memory used, swap usage fluctuating)
> > > triggered this...
> > > 
> > > WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
> > > Pid: 29795, comm: trinity-child4 Not tainted 3.7.0-rc2+ #49
> > > 
> > > 1148                         error = shmem_add_to_page_cache(page,
> > > mapping, index,
> > > 1149                                                 gfp,
> > > swp_to_radix_entry(swap));
> > > 1150                         /* We already confirmed swap, and make no
> > > allocation */
> > > 1151                         VM_BUG_ON(error);
> > > 1152                 }
> > That's very surprising.  Easy enough to handle an error there, but
> > of course I made it a VM_BUG_ON because it violates my assumptions:
> > I rather need to understand how this can be, and I've no idea.
> > 
> > Clutching at straws, I expect this is entirely irrelevant, but:
> > there isn't a warning on line 1151 of mm/shmem.c in 3.7.0-rc2 nor
> > in current linux.git; rather, there's a VM_BUG_ON on line 1149.
> > 
> > So you've inserted a couple of lines for some reason (more useful
> > trinity behaviour, perhaps)?  And have some config option I'm
> > unfamiliar with, that mutates a BUG_ON or VM_BUG_ON into a warning?
> 
> Hi Hugh,
> 
> I think it maybe caused by your commit [d189922862e03ce: shmem: fix negative
> rss in memcg memory.stat], one question:

Well, yes, I added the VM_BUG_ON in that commit.

> 
> if function shmem_confirm_swap confirm the entry has already brought back
> from swap by a racing thread,

The reverse: true confirms that the swap entry has not been brought back
from swap by a racing thread; false indicates that there has been a race.

> then why call shmem_add_to_page_cache to add
> page from swapcache to pagecache again?

Adding it to pagecache again, after such a race, would set error to
-EEXIST (originating from radix_tree_insert); but we don't do that,
we add it to pagecache when it has not already been added.

Or that's the intention: but Dave seems to have found an unexpected
exception, despite us holding the page lock across all this.

(But if it weren't for the memcg and replace_page issues, I'd much
prefer to let shmem_add_to_page_cache discover the race as before.)

Hugh

> otherwise, will goto unlock and then go to repeat? where I miss?
> 
> Regards,
> Chen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

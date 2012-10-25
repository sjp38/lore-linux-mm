Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 48CCE6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 17:48:39 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so3695746ied.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 14:48:38 -0700 (PDT)
Date: Thu, 25 Oct 2012 14:48:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
In-Reply-To: <20121025205213.GB4771@cmpxchg.org>
Message-ID: <alpine.LNX.2.00.1210251429080.3623@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121025205213.GB4771@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 25 Oct 2012, Johannes Weiner wrote:
> On Wed, Oct 24, 2012 at 09:36:27PM -0700, Hugh Dickins wrote:
> > On Wed, 24 Oct 2012, Dave Jones wrote:
> > 
> > > Machine under significant load (4gb memory used, swap usage fluctuating)
> > > triggered this...
> > > 
> > > WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
> > > Pid: 29795, comm: trinity-child4 Not tainted 3.7.0-rc2+ #49
> > > 
> > > 1148                         error = shmem_add_to_page_cache(page, mapping, index,
> > > 1149                                                 gfp, swp_to_radix_entry(swap));
> > > 1150                         /* We already confirmed swap, and make no allocation */
> > > 1151                         VM_BUG_ON(error);
> > > 1152                 }
> > 
> > That's very surprising.  Easy enough to handle an error there, but
> > of course I made it a VM_BUG_ON because it violates my assumptions:
> > I rather need to understand how this can be, and I've no idea.
> 
> Could it be concurrent truncation clearing out the entry between
> shmem_confirm_swap() and shmem_add_to_page_cache()?  I don't see
> anything preventing that.
> 
> The empty slot would not match the expected swap entry this call
> passes in and the returned error would be -ENOENT.

Excellent notion, many thanks Hannes, I believe you've got it.

I've hit that truncation problem in swapoff (and commented on it
in shmem_unuse_inode), but never hit it or considered it here.
I think of the page lock as holding it stable, but truncation's
free_swap_and_cache only does a trylock on the swapcache page,
so we're not secured against that possibility.

So I'd like to change it to VM_BUG_ON(error && error != -ENOENT),
but there's a little tidying up to do in the -ENOENT case, which
needs more thought.  A delete_from_swap_cache(page) - though we
can be lazy and leave that to reclaim for such a rare occurrence -
and probably a mem_cgroup uncharge; but the memcg hooks are always
the hardest to get right, I'll have think about that one carefully.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

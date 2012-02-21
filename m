Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 116216B00E8
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:05:56 -0500 (EST)
Received: by dadv6 with SMTP id v6so9004330dad.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 14:05:55 -0800 (PST)
Date: Tue, 21 Feb 2012 14:05:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/10] mm/memcg: take care over pc->mem_cgroup
In-Reply-To: <4F440154.7010403@openvz.org>
Message-ID: <alpine.LSU.2.00.1202211340530.2012@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201533260.23274@eggly.anvils> <4F4331BC.70205@openvz.org> <alpine.LSU.2.00.1202211117340.1858@eggly.anvils> <4F440154.7010403@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 22 Feb 2012, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > 
> > As things stand, that would mean lock_page_cgroup() has to disable irqs
> > everywhere.  I'm not sure of the further ramifications of moving uncharge
> > to __page_cache_release() and release_pages().  I don't think a change
> > like that is out of the question, but it's certainly a bigger change
> > than I'd like to consider in this series.
> 
> Ok. I have another big question: Why we remove pages from lru at last
> put_page()?
> 
> Logically we can remove them in truncate_inode_pages_range() for file
> and in free_pages_and_swap_cache() or something at last unmap for anon.
> Pages are unreachable after that, they never become alive again.
> Reclaimer also cannot reclaim them in this state, so there no reasons for
> keeping them in lru.
> Into those two functions pages come in large batches, so we can remove them
> more effectively,
> currently they are likely to be removed right in this place, just because
> release_pages() drops
> last references, but we can do this lru remove unconditionally.

That may be a very good idea, but I'm not going to commit myself
in a hurry.

I think Kamezawa-san was involved, and has a much better grasp than
I have, of the choices of precisely when to charge and uncharge;
and why we would not have removed from lru at the point of uncharge.

There may have been lock ordering reasons, now gone away, why it could
not have been done.  Or they may just have been the overriding reason,
now going away, that memcg should not make any change to what already
was happening without memcg.

One difficulty that comes to mind, is that at the point of uncharge,
the page may be (temporarily) off lru already: what then?  We certainly
don't want the uncharge to wait until the page comes back on to lru.
But it should be possible to deal with, by just making everywhere that
puts a page back on lru check for the charge first.  Hmm, but then
what of non-memcg, where there is never any charge?  And what of
those swapin readahead pages?  I think what you were suggesting
is probably slightly different from what I went on to imagine.

Please keep this idea in mind: maybe Kamezawa will immediately point
out the fatal flaw in it, or maybe we should come back to it later -
I'm not getting deeper into it now.

> Plus it never happens in irq context, so lru_lock can be converted to
> irq-unsafe in some distant future.

I'd love that: no very strong reason, the irq-disabling just irritates
me.  But note that the irq-disabling was introduced by Andrew, not for
I/O completion reasons (those somehow followed later IIRC), but because
the lock was so contended that he didn't want the holders interrupted.
Though I've not seen such a justification used recently.

We'd also have to do something about the "rotation",
maybe Mel's separate list would help, maybe not.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

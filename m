Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B11576B01AC
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 12:16:40 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so1842063fga.8
        for <linux-mm@kvack.org>; Thu, 25 Mar 2010 09:16:38 -0700 (PDT)
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100325180221.e1d9bae7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100319152103.876F.A69D9226@jp.fujitsu.com>
	 <20100319085949.GQ12388@csn.ul.ie>
	 <20100325095349.944E.A69D9226@jp.fujitsu.com>
	 <20100325083235.GF2024@csn.ul.ie>
	 <20100325180221.e1d9bae7.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Mar 2010 01:16:24 +0900
Message-ID: <1269533784.1814.64.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-03-25 at 18:02 +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 25 Mar 2010 08:32:35 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Thu, Mar 25, 2010 at 11:49:23AM +0900, KOSAKI Motohiro wrote:
> > > > On Fri, Mar 19, 2010 at 03:21:41PM +0900, KOSAKI Motohiro wrote: 
> > > Hmmm...
> > > I haven't understand your mention because I guess I was wrong.
> > > 
> > > probably my last question was unclear. I mean,
> > > 
> > > 1) If we still need SLAB_DESTROY_BY_RCU, why do we need to add refcount?
> > >     Which difference is exist between normal page migration and compaction?
> > 
> > The processes typically calling migration today own the page they are moving
> > and is not going to exit unexpectedly during migration.
> > 
> > > 2) If we added refcount, which race will solve?
> > > 
> > 
> > The process exiting and the last anon_vma being dropped while compaction
> > is running. This can be reliably triggered with compaction.
> > 
> > > IOW, Is this patch fix old issue or compaction specific issue?
> > > 
> > 
> > Strictly speaking, it's an old issue but in practice it's impossible to
> > trigger because the process migrating always owns the page. Compaction
> > moves pages belonging to arbitrary processes.
> > 
> Kosaki-san,
> 
>  IIUC, the race in memory-hotunplug was fixed by this patch [2/11].
> 
>  But, this behavior of unmap_and_move() requires access to _freed_
>  objects (spinlock). Even if it's safe because of SLAB_DESTROY_BY_RCU,
>  it't not good habit in general.

I agree kosaki's opinion. 

I guess Mel met the problem before this patch. 
Apparently, It had a problem like Mel's description. 
But we can close race window by this patch. 
so we don't need to new ref counter. 

At least, rcu_read_lock prevent anon_vma's free. 
so we can hold spinlock of anon_vma although it's not good habit.
About reusing anon_vma by SLAB_XXX_RCU, page_check_address and 
vma_address can prevent wrong working in try_to_unmap.  


>  After direct compaction, page-migration will be one of "core" code of
>  memory management. Then, I agree to patch [1/11] as our direction for
>  keeping sanity and showing direction to more updates. Maybe adding
>  refcnt and removing RCU in futuer is good.


I agree. (use one locking rule) 
I don't mean that we have to remove SLAB_XXX_RCU.
I want to reduce two locking rule with just one if we can. 
As far as we can do, I hope hide rcu_read_lock by Kame's version.
(Kame's version copy & page)
==

       if (PageAnon(page)) {
               struct anon_vma anon = page_lock_anon_vma(page);
               /* to take this lock, this page must be mapped. */
               if (!anon_vma)
                       goto uncharge;
               increase refcnt
               page_unlock_anon_vma(anon);
       }
       ....
==
and
==
void anon_vma_free(struct anon_vma *anon)
{
       /*
        * To increase refcnt of anon-vma, anon_vma->lock should be held by
        * page_lock_anon_vma(). It means anon_vma has a "mapped" page.
        * If this anon is freed by unmap or exit, all pages under this anon
        * must be unmapped. Then, just checking refcnt without lock is ok.
        */
       if (check refcnt > 0)
               return do nothing
       kmem_cache_free(anon);
}
==
Many locking rule would make many contributor very hard.

> 
>  IMHO, pushing this patch [2/11] as "BUGFIX" independent of this set and
>  adding anon_vma->refcnt [1/11] and [3/11] in 1st Direct-compaction patch
>  series  to show the direction will makse sense.
>  (I think merging 1/11 and 3/11 will be okay...)

Yes. For reducing locking, We can enhance it step by step after merge 
[1/11] and [3/11] if others doesn't oppose it any more. 

> 
> Thanks,
> -Kame
> 
> 


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

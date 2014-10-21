Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id D07BD6B006C
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 16:39:19 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id gq15so1747729lab.26
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 13:39:19 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k10si20636317lbp.126.2014.10.21.13.39.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 13:39:18 -0700 (PDT)
Date: Tue, 21 Oct 2014 16:39:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/4] mm: memcontrol: uncharge pages on swapout
Message-ID: <20141021203907.GA29116@phnom.home.cmpxchg.org>
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
 <1413818532-11042-2-git-send-email-hannes@cmpxchg.org>
 <5445B1E8.1010100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5445B1E8.1010100@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 21, 2014 at 10:07:52AM +0900, Kamezawa Hiroyuki wrote:
> (2014/10/21 0:22), Johannes Weiner wrote:
> > mem_cgroup_swapout() is called with exclusive access to the page at
> > the end of the page's lifetime.  Instead of clearing the PCG_MEMSW
> > flag and deferring the uncharge, just do it right away.  This allows
> > follow-up patches to simplify the uncharge code.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >   mm/memcontrol.c | 17 +++++++++++++----
> >   1 file changed, 13 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index bea3fddb3372..7709f17347f3 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -5799,6 +5799,7 @@ static void __init enable_swap_cgroup(void)
> >    */
> >   void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> >   {
> > +	struct mem_cgroup *memcg;
> >   	struct page_cgroup *pc;
> >   	unsigned short oldid;
> >   
> > @@ -5815,13 +5816,21 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> >   		return;
> >   
> >   	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
> shouldn't be removed ?

It's still a legitimate check at this point.  But it's removed later
in the series when PCG_MEMSW itself goes away.

> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

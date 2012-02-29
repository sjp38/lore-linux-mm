Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id CEF3E6B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 22:10:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A02703EE0C0
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 12:10:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 801E545DE53
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 12:10:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 68AF145DD74
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 12:10:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5229B1DB8040
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 12:10:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0394B1DB803E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 12:10:41 +0900 (JST)
Date: Wed, 29 Feb 2012 12:08:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/2] mm: memcg: count pte references from every member
 of the reclaimed hierarchy
Message-Id: <20120229120852.f2ca193e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120229020246.GF1702@cmpxchg.org>
References: <1330438489-21909-1-git-send-email-hannes@cmpxchg.org>
	<1330438489-21909-2-git-send-email-hannes@cmpxchg.org>
	<20120229093946.611a20d3.kamezawa.hiroyu@jp.fujitsu.com>
	<20120229020246.GF1702@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 29 Feb 2012 03:02:46 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Feb 29, 2012 at 09:39:46AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 28 Feb 2012 15:14:49 +0100
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -708,7 +708,8 @@ static enum page_references page_check_references(struct page *page,
> > >  	int referenced_ptes, referenced_page;
> > >  	unsigned long vm_flags;
> > >  
> > > -	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup, &vm_flags);
> > > +	referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
> > > +					  &vm_flags);
> > 
> > 
> > I'm sorry if I don't understand the codes... !sc->target_mem_cgroup case is handled ?
> 
> Yes, but it's not obvious from the diff alone.  page_referenced() does
> this:
> 
> 		/*
> 		 * If we are reclaiming on behalf of a cgroup, skip
> 		 * counting on behalf of references from different
> 		 * cgroups
> 		 */
> 		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
> 			continue;
> 
> As a result, !sc->target_mem_cgroup -- global reclaim -- will never
> ignore references, or put differently, respect references from all
> memcgs, which is what we want.
> 
Ah, thank you. 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

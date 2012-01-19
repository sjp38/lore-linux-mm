Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 9ABF26B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 18:58:02 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8E2BB3EE0C0
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:58:00 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7534245DE52
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:58:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F7FD45DE4F
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:58:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 431B81DB8041
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:58:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E9BB21DB803B
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:57:59 +0900 (JST)
Date: Fri, 20 Jan 2012 08:56:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove PCG_CACHE page_cgroup flag
Message-Id: <20120120085644.60d14c17.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120119134358.GC13932@tiehlicka.suse.cz>
References: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
	<20120119134358.GC13932@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Thu, 19 Jan 2012 14:43:58 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 19-01-12 18:17:11, KAMEZAWA Hiroyuki wrote:
> > This patch is onto memcg-devel, can be applied to linux-next, too.
> 
> Just for record memcg-devel tree should _always_ be compatible with
> linux-next. It just contains patches which are memcg related to be more
> stable for memcg specific development.
> 
> > 
> > ==
> > From 529653c266b0682894d64e4797fcaf6a3c35db25 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 19 Jan 2012 17:09:41 +0900
> > Subject: [PATCH] memcg: remove PCG_CACHE
> > 
> > We record 'the page is cache' by PCG_CACHE bit to page_cgroup.
> > Here, "CACHE" means anonymous user pages (and SwapCache). This
> > doesn't include shmem.
> 
> > Consdering callers, at charge/uncharge, the caller should know
> > what  the page is and we don't need to record it by using 1bit
> > per page.
> > 
> > This patch removes PCG_CACHE bit and make callers of
> > mem_cgroup_charge_statistics() to specify what the page is.
> > 
> > Changelog since RFC.
> >  - rebased onto memcg-devel
> >  - rename 'file' to 'not_rss'
> 
> The name is confusing.
> 
> Other than that the patch looks reasonable. Minor comment bellow:
> 

will use 'anon'.


> >  - some cleanup and added comment.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/page_cgroup.h |    8 +-----
> >  mm/memcontrol.c             |   55 ++++++++++++++++++++++++++----------------
> >  2 files changed, 35 insertions(+), 28 deletions(-)
> > 
> [...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index fb2dfc3..de7721d 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> [...]
> > @@ -2908,9 +2915,15 @@ void mem_cgroup_uncharge_page(struct page *page)
> >  
> >  void mem_cgroup_uncharge_cache_page(struct page *page)
> >  {
> > +	int ctype;
> > +
> >  	VM_BUG_ON(page_mapped(page));
> >  	VM_BUG_ON(page->mapping);
> > -	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> > +	if (page_is_file_cache(page))
> > +		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> > +	else
> > +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> > +	__mem_cgroup_uncharge_common(page, ctype);
> 
> OK, this makes sense but doesn't make any real difference now, so it is
> more a clean up, right?
> 

Yes. Johannes reuqested to remove this. I'll remove this in v3.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 10 Oct 2007 09:38:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][for -mm] Fix and Enhancements for memory cgroup [3/6]
 add helper function for page_cgroup
Message-Id: <20071010093839.f97d79da.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071009202642.9f174445.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20071009185132.a870b0f0.kamezawa.hiroyu@jp.fujitsu.com>
	<470B617C.1060504@linux.vnet.ibm.com>
	<20071009202642.9f174445.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Oct 2007 20:26:42 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > 
> > > +		 */
> > > +		if (clear_page_cgroup(page, pc) == pc) {
> > 
> > OK.. so we've come so far and seen that pc has changed underneath us,
> > what do we do with this pc?
> > 
> Hmm... How about this ?
> ==
>  if (clear_page_cgroup(page, pc) == pc) {
> 	/* do usual work */
>  } else {
> 	BUG();
>  }
> == or BUG_ON(clear_page_cgroup(page, pc) != pc)
> 
> I have no clear idea when this race will occur.
After good sleep, I noticed there is a race with force_reclaim (in patch 6).

force_reclaim doesn't check refcnt before clearing page->pc.

My final view will be
==
   if (clear_page_cgroup(page, pc) == pc) {
	/* do usual work */
   } else {
	/* force reclaim clears page->page_cgroup */
   }
==
Anyway, I'll add a meaningful comment here.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

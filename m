Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BE00B6B003D
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 21:31:32 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB32VTZv012571
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Dec 2009 11:31:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D01745DE62
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 11:31:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DC5445DE5A
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 11:31:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB6C91DB8047
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 11:31:20 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE8B31DB8042
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 11:31:19 +0900 (JST)
Date: Thu, 3 Dec 2009 11:28:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 22/24] HWPOISON: add memory cgroup filter
Message-Id: <20091203112822.ecee5bf5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091203021915.GA13587@localhost>
References: <20091202031231.735876003@intel.com>
	<20091202043046.519053333@intel.com>
	<20091202124446.GA18989@one.firstfloor.org>
	<20091202125842.GA13277@localhost>
	<20091203105229.afb0efc4.kamezawa.hiroyu@jp.fujitsu.com>
	<20091203021915.GA13587@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Dec 2009 10:19:15 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Thu, Dec 03, 2009 at 09:52:29AM +0800, KAMEZAWA Hiroyuki wrote:
> > On Wed, 2 Dec 2009 20:58:42 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > On Wed, Dec 02, 2009 at 08:44:46PM +0800, Andi Kleen wrote:
> > > > >  
> > > > > +static int hwpoison_filter_task(struct page *p)
> > > > > +{
> > > > 
> > > > Can we make that ifdef instead of depends on ?
> > > 
> > > Sure. Here is the updated patch.
> > > 
> > > ---
> > > HWPOISON: add memory cgroup filter
> > > 
> > > The hwpoison test suite need to inject hwpoison to a collection of
> > > selected task pages, and must not touch pages not owned by them and
> > > thus kill important system processes such as init. (But it's OK to
> > > mis-hwpoison free/unowned pages as well as shared clean pages.
> > > Mis-hwpoison of shared dirty pages will kill all tasks, so the test
> > > suite will target all or non of such tasks in the first place.)
> > > 
> > > The memory cgroup serves this purpose well. We can put the target
> > > processes under the control of a memory cgroup, and tell the hwpoison
> > > injection code to only kill pages associated with some active memory
> > > cgroup.
> > > 
> > > The prerequisite for doing hwpoison stress tests with mem_cgroup is,
> > > the mem_cgroup code tracks task pages _accurately_ (unless page is
> > > locked).  Which we believe is/should be true.
> > > 
> > > The benifits are simplification of hwpoison injector code. Also the
> > > mem_cgroup code will automatically be tested by hwpoison test cases.
> > > 
> > > The alternative interfaces pin-pfn/unpin-pfn can also delegate the
> > > (process and page flags) filtering functions reliably to user space.
> > > However prototype implementation shows that this scheme adds more
> > > complexity than we wanted.
> > > 
> > > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > > CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > CC: Li Zefan <lizf@cn.fujitsu.com>
> > > CC: Paul Menage <menage@google.com>
> > > CC: Nick Piggin <npiggin@suse.de> 
> > > CC: Andi Kleen <andi@firstfloor.org> 
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > >  mm/Kconfig           |    2 +-
> > >  mm/hwpoison-inject.c |    7 +++++++
> > >  mm/internal.h        |    1 +
> > >  mm/memory-failure.c  |   28 ++++++++++++++++++++++++++++
> > >  4 files changed, 37 insertions(+), 1 deletion(-)
> > > 
> > > --- linux-mm.orig/mm/memory-failure.c	2009-12-01 09:56:06.000000000 +0800
> > > +++ linux-mm/mm/memory-failure.c	2009-12-02 20:56:55.000000000 +0800
> > > @@ -96,6 +96,31 @@ static int hwpoison_filter_flags(struct 
> > >  		return -EINVAL;
> > >  }
> > >  
> > > +#ifdef	CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > > +u32 hwpoison_filter_memcg;
> > > +static int hwpoison_filter_task(struct page *p)
> > > +{
> > > +	struct mem_cgroup *mem;
> > > +	struct cgroup_subsys_state *css;
> > > +
> > > +	if (!hwpoison_filter_memcg)
> > > +		return 0;
> > > +
> > > +	mem = try_get_mem_cgroup_from_page(p);
> > > +	if (!mem)
> > > +		return -EINVAL;
> > > +
> > > +	css = mem_cgroup_css(mem);
> > > +	if (!css)
> > > +		return -EINVAL;
> > 
> > > +
> > > +	css_put(css);
> > > +	return 0;
> > > +}
> > 
> > 
> > Hmm..can you adds comment ? What does this function is for ?
> 
> Good idea. How about this one?
> 
> /*
>  * This allows stress tests to limit test scope to a collection of tasks
>  * by putting them under some memcg. This prevents killing unrelated/important
>  * processes such as /sbin/init. Note that the target task may share clean
>  * pages with init (eg. libc text), which is harmless. If the target task
>  * share _dirty_ pages with another task B, the test scheme must make sure B
>  * is also included in the memcg. At last, due to race conditions this filter
>  * can only guarantee that the page either belongs to the memcg tasks, or is
>  * a freed page.
>  */
> 
Hmm. seems good but..by what means "avoiding killing /sbin/init" is done ?
All process are under some memcg..

If you have more patches to be usable the function above,
I recommend you to post this with some real-use patches, in step by step.
patch 19,20 is ok for me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

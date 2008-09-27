Date: Sat, 27 Sep 2008 12:25:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
Message-Id: <20080927122530.29e02ba8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926104336.d96ab5bd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926100022.8bfb8d4d.nishimura@mxp.nes.nec.co.jp>
	<20080926104336.d96ab5bd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 10:43:36 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > > -	VM_BUG_ON(pc->page != page);
> > > +	pc = lookup_page_cgroup(page);
> > > +	if (unlikely(!pc || !PageCgroupUsed(pc)))
> > > +		return;
> > > +	preempt_disable();
> > > +	lock_page_cgroup(pc);
> > > +	if (unlikely(page_mapped(page))) {
> > > +		unlock_page_cgroup(pc);
> > > +		preempt_enable();
> > > +		return;
> > > +	}
> > Just for clarification, in what sequence will the page be mapped here?
> > mem_cgroup_uncharge_page checks whether the page is mapped.
> > 

I think I saw page_mapped() case (in your shmem/page test.)
I'll check what cause this if I have time.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

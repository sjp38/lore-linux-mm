Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3B6EB6B004F
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 21:34:23 -0400 (EDT)
Date: Thu, 20 Aug 2009 09:34:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] memcg: move definitions to .h and inline some functions
Message-ID: <20090820013418.GA12766@localhost>
References: <4A856467.6050102@redhat.com> <20090815054524.GB11387@localhost> <20090818224230.A648.A69D9226@jp.fujitsu.com> <20090819134036.GA7267@localhost> <f4131456fc4b1dd4f5b8d060e0cbef80.squirrel@webmail-b.css.fujitsu.com> <20090819142705.GN22626@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090819142705.GN22626@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 10:27:05PM +0800, Balbir Singh wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-19 23:18:01]:
> 
> > Wu Fengguang ?$B$5$s$O=q$-$^$7$?!'
> > > On Tue, Aug 18, 2009 at 11:57:52PM +0800, KOSAKI Motohiro wrote:
> > >>
> > >> > > This one of the reasons why we unconditionally deactivate
> > >> > > the active anon pages, and do background scanning of the
> > >> > > active anon list when reclaiming page cache pages.
> > >> > >
> > >> > > We want to always move some pages to the inactive anon
> > >> > > list, so it does not get too small.
> > >> >
> > >> > Right, the current code tries to pull inactive list out of
> > >> > smallish-size state as long as there are vmscan activities.
> > >> >
> > >> > However there is a possible (and tricky) hole: mem cgroups
> > >> > don't do batched vmscan. shrink_zone() may call shrink_list()
> > >> > with nr_to_scan=1, in which case shrink_list() _still_ calls
> > >> > isolate_pages() with the much larger SWAP_CLUSTER_MAX.
> > >> >
> > >> > It effectively scales up the inactive list scan rate by 10 times when
> > >> > it is still small, and may thus prevent it from growing up for ever.
> > >> >
> > >> > In that case, LRU becomes FIFO.
> > >> >
> > >> > Jeff, can you confirm if the mem cgroup's inactive list is small?
> > >> > If so, this patch should help.
> > >>
> > >> This patch does right thing.
> > >> However, I would explain why I and memcg folks didn't do that in past
> > >> days.
> > >>
> > >> Strangely, some memcg struct declaration is hide in *.c. Thus we can't
> > >> make inline function and we hesitated to introduce many function calling
> > >> overhead.
> > >>
> > >> So, Can we move some memcg structure declaration to *.h and make
> > >> mem_cgroup_get_saved_scan() inlined function?
> > >
> > > OK here it is. I have to move big chunks to make it compile, and it
> > > does reduced a dozen lines of code :)
> > >
> > > Is this big copy&paste acceptable? (memcg developers CCed).
> > >
> > > Thanks,
> > > Fengguang
> > 
> > I don't like this. plz add hooks to necessary places, at this stage.
> > This will be too big for inlined function, anyway.
> > plz move this after you find overhead is too big.

It shall not be a performance regression, since the text size is slightly
smaller with the patch:

            text      data        bss        dec      hex      filename
before      8732148   2771858   11048432   22552438   1581f76  vmlinux
after       8731972   2771858   11048432   22552262   1581ec6  vmlinux    

> Me too.. I want to abstract the implementation within memcontrol.c to
> be honest (I am concerned that someone might include memcontrol.h and
> access its structure members, which scares me). Hiding it within
> memcontrol.c provides the right level of abstraction.

Yeah quite reasonable.
 
> Could you please explain your motivation for this change? I got cc'ed
> on to a few emails, is this for the patch that export nr_save_scanned
> approach?

Yes, KOSAKI proposed to inline the mem_cgroup_get_saved_scan() function
introduced in that patch, which requires moving the structs into .h

I'll submit the original (un-inlined) patch.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 26F466B0098
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 21:14:57 -0500 (EST)
Date: Thu, 16 Dec 2010 03:13:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Transparent Hugepage Support #33
Message-ID: <20101216021353.GD5638@random.random>
References: <20101215051540.GP5638@random.random>
 <20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
 <20101216101053.05cb1516.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101216101053.05cb1516.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>
List-ID: <linux-mm.kvack.org>

Hi Daisuke and Kame,

On Thu, Dec 16, 2010 at 10:10:53AM +0900, Daisuke Nishimura wrote:
> Hi,
> 
> On Thu, 16 Dec 2010 09:54:08 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 15 Dec 2010 06:15:40 +0100
> > Andrea Arcangeli <aarcange@redhat.com> wrote:
> > 
> > > Some of some relevant user of the project:
> > > 
> > > KVM Virtualization
> > > GCC (kernel build included, requires a few liner patch to enable)
> > > JVM
> > > VMware Workstation
> > > HPC
> > > 
> > > It would be great if it could go in -mm.
> > 
> > Things should be done in memory cgroup is
> >  
> >  - make accounting correct (RSS count will be broken)
> >  - make move_charge() to work
> >    (at rmdir(), this is now broken. It seems move-charge-at-task-move to work)
> > 
> Yes.
> I think we should add mem_cgroup_split_hugepage_commit() and add PageTransHuge()
> check in mem_cgroup_move_parent() as done in RHEL6 kernel.

Yes, unfortunately porting all the RHEL6 THP cgroups bits wasn't
trivial because of the difference in the cgroup code.

> As for move-charge-at-task-move, it will work because walk_pmd_range() splits
> THP pages(it would be better to change move-charge not to split THP pages, but
> it's not so urgent IMHO).
> 
> > Do you have known other viewpoints ?
> Not yet, but I'll test and check.

Same here.

One detail I'd ask you to check is the compound_trans_order I added in
#33 for memory-failure and cgroups. It's not really necessary in memcg
if we stop reading the order and we do page_size = HPAGE_PMD_SIZE
instead. I thought having the cgroup code handling compound pages
without hardwiring the size was better but maybe it's not. Maybe the
compound_lock locking should also be extended there? It's up to you to
what you prefer there but I'll try to help as much as I can.

BTW, now that it's in -mm I'll keep any further change incremental at
the end and I'll stop rebasing to avoid confusion.

> > I'll look into when -mm is shipped.
> > 
> me too :)

Thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

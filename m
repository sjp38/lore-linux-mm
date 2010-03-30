Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7C0926B020D
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 21:54:43 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U1seSj002504
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Mar 2010 10:54:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B5A1145DE4E
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 10:54:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 88FCE45DE54
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 10:54:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6646CE1800D
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 10:54:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E1DC3E1800B
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 10:54:38 +0900 (JST)
Date: Tue, 30 Mar 2010 10:50:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH(v2) -mmotm 1/2] memcg move charge of file cache at task
 migration
Message-Id: <20100330105057.90dbe2ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100330103236.83b319ce.nishimura@mxp.nes.nec.co.jp>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120321.bb6e65fe.nishimura@mxp.nes.nec.co.jp>
	<20100329131541.7cdc1744.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330103236.83b319ce.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 10:32:36 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Mon, 29 Mar 2010 13:15:41 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 29 Mar 2010 12:03:21 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > This patch adds support for moving charge of file cache. It's enabled by setting
> > > bit 1 of <target cgroup>/memory.move_charge_at_immigrate.
> > > 
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > ---
> > >  Documentation/cgroups/memory.txt |    6 ++++--
> > >  mm/memcontrol.c                  |   14 +++++++++++---
> > >  2 files changed, 15 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > > index 1b5bd04..f53d220 100644
> > > --- a/Documentation/cgroups/memory.txt
> > > +++ b/Documentation/cgroups/memory.txt
> > > @@ -461,10 +461,12 @@ charges should be moved.
> > >     0  | A charge of an anonymous page(or swap of it) used by the target task.
> > >        | Those pages and swaps must be used only by the target task. You must
> > >        | enable Swap Extension(see 2.4) to enable move of swap charges.
> > > + -----+------------------------------------------------------------------------
> > > +   1  | A charge of file cache mmap'ed by the target task. Those pages must be
> > > +      | mmap'ed only by the target task.
> > 
> > Hmm..my English is not good but..
> > ==
> > A charge of a page cache mapped by the target task. Pages mapped by multiple processes
> > will not be moved. This "page cache" doesn't include tmpfs.
> > ==
> > 
> This is more accurate than mine.
> 
> > Hmm, "a page mapped only by target task but belongs to other cgroup" will be moved ?
> > The answer is "NO.".
> > 
> > The code itself seems to work well. So, could you update Documentation ?
> > 
> Thank you for your advice.
> 
> This is the updated version.
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> This patch adds support for moving charge of file cache. It's enabled by setting
> bit 1 of <target cgroup>/memory.move_charge_at_immigrate.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

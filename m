Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 229536B0047
	for <linux-mm@kvack.org>; Fri,  1 May 2009 12:41:14 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n41GdHcR004086
	for <linux-mm@kvack.org>; Fri, 1 May 2009 10:39:17 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n41GfokR243296
	for <linux-mm@kvack.org>; Fri, 1 May 2009 10:41:51 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n41GfoFp029771
	for <linux-mm@kvack.org>; Fri, 1 May 2009 10:41:50 -0600
Date: Fri, 1 May 2009 21:02:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH mmotm] memcg: fix mem_cgroup_update_mapped_file_stat
	oops
Message-ID: <20090501153206.GA4686@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0904292209550.30874@blonde.anvils> <20090430090646.a1443096.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0905011447290.26997@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905011447290.26997@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> [2009-05-01 14:55:51]:

> On Thu, 30 Apr 2009, KAMEZAWA Hiroyuki wrote:
> > On Wed, 29 Apr 2009 22:13:33 +0100 (BST)
> > Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > > CONFIG_SPARSEMEM=y CONFIG_CGROUP_MEM_RES_CTLR=y cgroup_disable=memory
> > > bootup is oopsing in mem_cgroup_update_mapped_file_stat().  !SPARSEMEM
> > > is fine because its lookup_page_cgroup() contains an explicit check for
> > > NULL node_page_cgroup, but the SPARSEMEM version was missing a check for
> > > NULL section->page_cgroup.
> > > 
> > Ouch, it's curious this bug alive now.. thank you.
> > 
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > I think this patch itself is sane but.. Balbir, could you see "caller" ?
> > It seems strange.
> 
> I agree with you, it seems strange for it to come alive only now;
> but I've not investigated further, may I leave that to you?
> 
> Could it be that all those checks on NULL lookup_page_cgroup()
> actually date from before you reworked page cgroup assignment,
> and they're now redundant?  If so, you'd do better to remove
> all the checks, and Balbir put an explicit check in his code.
>

I agree, it needs investigation. I would propose converting them to a
VM_BUG_ON() and then consider removing them, just to catch potential
problems, in case we miss anything.
 
> Alternatively, could the SPARSEMEM case have been corrupting or
> otherwise misbehaving in a hidden way until now?  Seems unlikely.

Agreed.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

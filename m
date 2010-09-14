Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8B31B6B0047
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 00:41:07 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8E4f4jx012600
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 14 Sep 2010 13:41:04 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7488345DE4E
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:41:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ECED45DE4F
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:41:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 33A30E08003
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:41:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF1C8E18001
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:41:03 +0900 (JST)
Date: Tue, 14 Sep 2010 13:35:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix race in file_mapped accouting flag
 management
Message-Id: <20100914133546.35d90726.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100913140803.b83d3fe1.akpm@linux-foundation.org>
References: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
	<20100913140803.b83d3fe1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Sep 2010 14:08:03 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 13 Sep 2010 16:08:22 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
<snip>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > Index: lockless-update/mm/memcontrol.c
> > ===================================================================
> > --- lockless-update.orig/mm/memcontrol.c
> > +++ lockless-update/mm/memcontrol.c
> > @@ -1485,7 +1485,8 @@ void mem_cgroup_update_file_mapped(struc
> >  		SetPageCgroupFileMapped(pc);
> >  	} else {
> >  		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		ClearPageCgroupFileMapped(pc);
> > +		if (page_mapped(page)) /* for race between dec->inc counter */
> > +			ClearPageCgroupFileMapped(pc);
> >  	}
> 
> This should be !page_mapped(), shouldn't it?
> 

Ahhhh, yes. reflesh miss..

> And your second patch _does_ have !page_mapped() here, which is why the
> second patch didn't apply.
> 
Very sorry.

> I tried to fix things up.  Please check.

Thank you. 

-Kame

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

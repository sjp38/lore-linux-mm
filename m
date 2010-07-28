Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 744A46B02AB
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 03:19:17 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S7JFca021594
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Jul 2010 16:19:15 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0628E45DE51
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 16:19:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A582745DE4F
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 16:19:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F6801DB801A
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 16:19:14 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BCDDFE08005
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 16:19:10 +0900 (JST)
Date: Wed, 28 Jul 2010 16:14:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/7][memcg] generic file status update
Message-Id: <20100728161422.753029c1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr937hkgkrle.fsf@ninji.mtv.corp.google.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727170059.ca06af88.kamezawa.hiroyu@jp.fujitsu.com>
	<xr937hkgkrle.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2010 00:12:13 -0700
Greg Thelen <gthelen@google.com> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > This patch itself is not important. I just feel we need this kind of
> > clean up in future.
> >
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Preparing for adding new status arounf file caches.(dirty, writeback,etc..)
> > Using a unified macro and more generic names.
> > All counters will have the same rule for updating.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h  |   10 +++++++---
> >  include/linux/page_cgroup.h |   21 +++++++++++++++------
> >  mm/memcontrol.c             |   27 +++++++++++++++++----------
> >  mm/rmap.c                   |    4 ++--
> >  4 files changed, 41 insertions(+), 21 deletions(-)
> >
> > Index: mmotm-0719/include/linux/memcontrol.h
> > ===================================================================
> > --- mmotm-0719.orig/include/linux/memcontrol.h
> > +++ mmotm-0719/include/linux/memcontrol.h
> > @@ -121,7 +121,11 @@ static inline bool mem_cgroup_disabled(v
> >  	return false;
> >  }
> >  
> > -void mem_cgroup_update_file_mapped(struct page *page, int val);
> > +enum {
> > +	__MEMCG_FILE_MAPPED,
> > +	NR_MEMCG_FILE_STAT
> > +};
> 
> These two stat values need to be defined outside of "#if
> CONFIG_CGROUP_MEM_RES_CTLR" (above) to allow for rmap.c to allow for the
> following (from rmap.c) when memcg is not compiled in:
> 	mem_cgroup_update_file_stat(page, __MEMCG_FILE_MAPPED, 1);
> 

ok. or I'll not remove mem_cgroup_update_file_mapped().



> > +void mem_cgroup_update_file_stat(struct page *page, int stat, int val);
> >  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >  						gfp_t gfp_mask, int nid,
> >  						int zid);
> > @@ -292,8 +296,8 @@ mem_cgroup_print_oom_info(struct mem_cgr
> >  {
> >  }
> >  
> > -static inline void mem_cgroup_update_file_mapped(struct page *page,
> > -							int val)
> > +static inline void
> > +mem_cgroup_update_file_stat(struct page *page, int stat, int val);
> 
> Trailing ';' needs to be removed.
> 
ok, will do.

Bye.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

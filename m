Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAD2HeG3013976
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 11:17:40 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1345745DD78
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:17:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D1E7145DD76
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:17:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CF831DB803B
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:17:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 45C591DB8037
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:17:39 +0900 (JST)
Date: Thu, 13 Nov 2008 11:17:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.28-rc4 mem_cgroup_charge_common panic
Message-Id: <20081113111702.9a5b6ce7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1226527376.4835.8.camel@badari-desktop>
References: <1226353408.8805.12.camel@badari-desktop>
	<20081111101440.f531021d.kamezawa.hiroyu@jp.fujitsu.com>
	<20081111110934.d41fa8db.kamezawa.hiroyu@jp.fujitsu.com>
	<1226527376.4835.8.camel@badari-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 14:02:56 -0800
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> On Tue, 2008-11-11 at 11:09 +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 11 Nov 2008 10:14:40 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Mon, 10 Nov 2008 13:43:28 -0800
> > > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > > 
> > > > Hi KAME,
> > > > 
> > > > Thank you for the fix for online/offline page_cgroup panic.
> > > > 
> > > > While running memory offline/online tests ran into another
> > > > mem_cgroup panic.
> > > > 
> > > 
> > > Hm, should I avoid freeing mem_cgroup at memory Offline ?
> > > (memmap is also not free AFAIK.)
> > > 
> > > Anyway, I'll dig this. thanks.
> > > 
> > it seems not the same kind of bug..
> > 
> > Could you give me disassemble of mem_cgroup_charge_common() ?
> > (I'm not sure I can read ppc asm but I want to know what is "0x20"
> >  of fault address....)
> > 
> > As first impression, it comes from page migration..
> > rc4's page migration handler of memcg handles *usual* path but not so good.
> > 
> > new migration code of memcg in mmotm is much better, I think.
> > Could you try mmotm if you have time ?
> 
> I tried mmtom. Its even worse :(
> 
> Ran into following quickly .. Sorry!!
> 
>From 
> Instruction dump:
> 794b1f24 794026e4 7d6bda14 7d3b0214 7d234b78 39490008 e92b0048 39290001 
> f92b0048 419e001c e9230008 f93c0018 <f9090008> f9030008 f9480008 48000018 

the reason doesn't seem to be different from the one you saw in rc4.

We'do add_list() hear, so (maybe) used page_cgroup is zero-cleared, I think.
We usually do migration test on cpuset and confirmed this works with migration.

Hmm...I susupect following. could you try ?

Sorry.
-Kame
==

Index: mmotm-2.6.28-Nov10/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.28-Nov10.orig/mm/page_cgroup.c
+++ mmotm-2.6.28-Nov10/mm/page_cgroup.c
@@ -166,7 +166,7 @@ int online_page_cgroup(unsigned long sta
 	end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);
 
 	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
-		if (!pfn_present(pfn))
+		if (!pfn_valid(pfn))
 			continue;
 		fail = init_section_page_cgroup(pfn);
 	}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

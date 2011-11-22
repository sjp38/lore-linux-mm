Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3FDC06B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:36:40 -0500 (EST)
Date: Mon, 21 Nov 2011 16:36:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix virtual address handling in hugetlb fault
Message-Id: <20111121163637.df529ca5.akpm@linux-foundation.org>
In-Reply-To: <20111122093238.9bdbee39.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111121194832.a0026d3e.kamezawa.hiroyu@jp.fujitsu.com>
	<20111121142720.a5b62c9c.akpm@linux-foundation.org>
	<20111122093238.9bdbee39.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, n-horiguchi@ah.jp.nec.com

On Tue, 22 Nov 2011 09:32:38 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 21 Nov 2011 14:27:20 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Mon, 21 Nov 2011 19:48:32 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > >From 7c29389be2890c6b6934a80b4841d07a7014fe26 Mon Sep 17 00:00:00 2001
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Date: Mon, 21 Nov 2011 19:45:27 +0900
> > > Subject: [PATCH] Fix virtual address handling in hugetlb fault
> > > 
> > > handle_mm_fault() passes 'faulted' address to hugetlb_fault().
> > > Then, the address is not aligned to hugepage boundary.
> > > 
> > > Most of functions for hugetlb pages are aware of that and
> > > calculate an alignment by itself. Some functions as copy_user_huge_page(),
> > > and clear_huge_page() doesn't handle alignment by themselves.
> > > 
> > > This patch make hugeltb_fault() to calculate the alignment and pass
> > > aligned addresss (top address of a faulted hugepage) to functions.
> > > 
> > 
> > Does this actually fix any known user-visible misbehaviour?
> > 
> 
> I just found this at reading codes. And I know 'vaddr' is ignored
> in most of per-arch implemantation of clear_user_highpage().
> It seems, in some arch, vaddr is used for flushing cache. Now,
> CONFIG_HUGETLBFS can be set on x86,powerpc,ia64,mips,sh,sparc,tile. (by grep)
> 
> it seems mips and sh uses vaddr in clear_user_(high)page.

OK.  Those architectures are probably OK with "any address within the
page" anyway.

I'm actually trying to work out which kernel(s) we should merge this
into ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

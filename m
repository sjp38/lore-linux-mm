Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 046385F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 20:16:16 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3H0GUQH018818
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Apr 2009 09:16:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CAF1645DE52
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 09:16:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A278445DE55
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 09:16:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C887E08001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 09:16:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E49A1DB803C
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 09:16:29 +0900 (JST)
Date: Fri, 17 Apr 2009 09:14:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
 controller (v2)
Message-Id: <20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090416120316.GG7082@balbir.in.ibm.com>
References: <20090415120510.GX7082@balbir.in.ibm.com>
	<20090416095303.b4106e9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416015955.GB7082@balbir.in.ibm.com>
	<20090416110246.c3fef293.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416164036.03d7347a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416171535.cfc4ca84.kamezawa.hiroyu@jp.fujitsu.com>
	<20090416120316.GG7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Apr 2009 17:33:16 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-16 17:15:35]:
> 
> > 
> > > Sorry, some troubles found. Ignore above Ack. 3points now.
> > > 
> > > 1. get_cpu should be after (*)
> > > ==mem_cgroup_update_mapped_file_stat()
> > > +	int cpu = get_cpu();
> > > +
> > > +	if (!page_is_file_cache(page))
> > > +		return;
> > > +
> > > +	if (unlikely(!mm))
> > > +		mm = &init_mm;
> > > +
> > > +	mem = try_get_mem_cgroup_from_mm(mm);
> > > +	if (!mem)
> > > +		return;
> > > + ----------------------------------------(*)
> > > +	stat = &mem->stat;
> > > +	cpustat = &stat->cpustat[cpu];
> > > +
> > > +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_MAPPED_FILE, val);
> > > +	put_cpu();
> > > +}
> > > ==
> 
> Yes or I should have a goto
> 
> > > 
> > > 2. In above, "mem" shouldn't be got from "mm"....please get "mem" from page_cgroup.
> > > (Because it's file cache, pc->mem_cgroup is not NULL always.)
> 
> Hmmm.. not sure I understand this part. Are you suggesting that mm can
> be NULL?
No.

> I added the check for !mm as a safety check. Since this
> routine is only called from rmap context, mm is not NULL, hence mem
> should not be NULL. Did you find a race between mm->owner assignment
> and lookup via mm->owner?
> 
No.

page_cgroup->mem_cgroup != try_get_mem_cgroup_from_mm(mm);  in many many cases.

For example, libc and /bin/*** is tend to be loaded into default cgroup at boot but
used by many cgroups. But mapcount of page caches for /bin/*** is 0 if not running.

Then, File_Mapped can be greater than Cached easily if you use mm->owner.

I can't estimate RSS in *my* cgroup if File_Mapped includes pages which is under 
other cgroups. It's meaningless.
Especially, when Cached==0 but File_Mapped > 0, I think "oh, the kernel leaks somehing..hmm..."

By useing page_cgroup->mem_cgroup, we can avoid above mess.

Thanks,
-Kame 









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

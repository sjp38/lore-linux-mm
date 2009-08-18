Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5A4E16B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 04:27:45 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7I8Rp97005731
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 18 Aug 2009 17:27:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FBA545DE56
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 17:27:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E172145DE4F
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 17:27:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B97B5E08004
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 17:27:50 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 28947E08006
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 17:27:50 +0900 (JST)
Date: Tue, 18 Aug 2009 17:25:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
Message-Id: <20090818172552.779d0768.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A8A4ABB.70003@redhat.com>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
	<20090812081906.5757.39417.sendpatchset@localhost.localdomain>
	<m1bpmk8l1g.fsf@fess.ebiederm.org>
	<4A83893D.50707@redhat.com>
	<m1eirg5j9i.fsf@fess.ebiederm.org>
	<4A83CD84.8040609@redhat.com>
	<m1tz0avy4h.fsf@fess.ebiederm.org>
	<4A8927DD.6060209@redhat.com>
	<20090818092939.2efbe158.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8A4ABB.70003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Amerigo Wang <amwang@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Aug 2009 14:31:23 +0800
Amerigo Wang <amwang@redhat.com> wrote:
> Hi, thank you!
> > Can I have a question ?
> >
> >   - How crash kernel's memory is preserved at boot ?
> >   
> 
> Use bootmem, I think.
> 
I see.

In x86,
 
  setup_arch()
	-> reserve_crashkernel()
		-> find_and_reserve_crashkernel()
			-> reserve_bootmem_generic()

Then, all "active range" is already registered and there are memmap.


> >     It's hidden from the system before mem_init() ?
> >   
> 
> Not sure, but probably yes. It is reserved in setup_arch() which is 
> before mm_init() which calls mem_init().
> 
> Do you have any advice to free that reserved memory after boot? :)
> 

Let's see arch/x86/mm/init.c::free_initmem()

Maybe it's all you want.

	- ClearPageReserved()
	- init_page_count()
	- free_page()
	- totalram_pages++

But it has no argumetns. Maybe you need your own function or modification.
online_pages() does very similar. But, hmm,.. writing something open coded one
for crashkernel is not very bad, I think.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

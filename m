Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A80056B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:27:51 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o230Rm3w012878
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 09:27:49 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C829E45DE4E
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:27:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 972ED45DE63
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:27:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3211C1DB803A
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:27:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 98D05E38004
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:27:47 +0900 (JST)
Date: Wed, 3 Mar 2010 09:24:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-Id: <20100303092417.1a2f0418.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003021547210.11946@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
	<20100301101259.af730fa0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003010204180.26824@chino.kir.corp.google.com>
	<20100302085932.7b22f830.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021547210.11946@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010 15:55:47 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 2 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > Your nack is completely unjustified, we're not going to stop oom killer 
> > > development so memcg can catch up.  This patch allows pagefaults to go 
> > > through the typical out_of_memory() interface so we don't have any 
> > > ambiguity in how situations such as panic_on_oom are handled or whether 
> > > current's memcg recently called the oom killer and it PREVENTS needlessly 
> > > killing tasks when a parallel oom condition exists but a task hasn't been 
> > > killed yet.
> > > 
> > > mem_cgroup_oom_called() is completely and utterly BOGUS since we can 
> > > detect the EXACT same conditions via a tasklist scan filtered on current's 
> > > memcg by looking for parallel oom kills, which out_of_memory() does, and 
> > > locking the zonelists to prevent racing in calling out_of_memory() and 
> > > actually setting the TIF_MEMDIE bit for the selected task.
> > > 
> > > You said earlier that you would wait for the next mmotm to be released and 
> > > could easily rebase on my patchset and now you're stopping development 
> > > entirely and allowing tasks to be needlessly oom killed via the old 
> > > pagefault_out_of_memory() which does not synchronize on parallel oom 
> > > kills.
> > > 
> > > I'm completely sure that you'll remove mem_cgroup_oom_called() entirely 
> > > yourself since it doesn't do anything but encourage VM_FAULT_OOM loops 
> > > itself, so please come up with some constructive criticism of my patch 
> > > that Andrew can use to decide whether to merge my work or not instead of 
> > > thinking you're the only one that can touch memcg.
> > > 
> > 
> > Your patch seems not to go earlier than mine.
> 
> Your latest patch, "memcg: fix oom killer behavior v2" at 
> http://marc.info/?l=linux-kernel&m=126750597522101 removes the same code 
> that this patch removes from memcg.  Your convoluting the issue by saying 
> they have any dependency on each other at all, and that's why it's 
> extremely frustrating for you to go around nacking other people's work 
> when you really don't understand what it does.  You could trivially rebase 
> on my patch at any time and I could trivially rebase on yours, it's that 
> simple. 
Ok.


 
> > And please avoid zone avoid locking. memcg requires memcg based locking.
> 
> Trying to set ZONE_OOM_LOCKED for all populated zones is fundamentally the 
> correct thing to do on VM_FAULT_OOM when you don't know the context in 
> which we're trying to allocate pages.  The _only_ thing that does is close 
> a race between when another thread calls out_of_memory(), which is likely 
> in such conditions, and the oom killer hasn't killed a task yet so we 
> can't detect the TIF_MEMDIE bit during the tasklist scan.  Memcg is 
> completely irrelevant with respect to this zone locking and that's why I 
> didn't touch mem_cgroup_out_of_memory().  Did you seriously even read this 
> patch?
> 

Then, memcg will see second oom-kill.


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

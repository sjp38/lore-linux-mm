Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F1D726B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 19:03:05 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o22033Hd016726
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Mar 2010 09:03:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7980D45DE62
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 09:03:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4509E45DE57
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 09:03:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 29E001DB803B
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 09:03:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C53651DB803E
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 09:03:02 +0900 (JST)
Date: Tue, 2 Mar 2010 08:59:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-Id: <20100302085932.7b22f830.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003010204180.26824@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
	<20100301101259.af730fa0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003010204180.26824@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Mar 2010 02:13:28 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 1 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > On Fri, 26 Feb 2010 15:53:11 -0800 (PST)
> > David Rientjes <rientjes@google.com> wrote:
> > 
> > > It is possible to remove the special pagefault oom handler by simply
> > > oom locking all system zones and then calling directly into
> > > out_of_memory().
> > > 
> > > All populated zones must have ZONE_OOM_LOCKED set, otherwise there is a
> > > parallel oom killing in progress that will lead to eventual memory
> > > freeing so it's not necessary to needlessly kill another task.  The
> > > context in which the pagefault is allocating memory is unknown to the oom
> > > killer, so this is done on a system-wide level.
> > > 
> > > If a task has already been oom killed and hasn't fully exited yet, this
> > > will be a no-op since select_bad_process() recognizes tasks across the
> > > system with TIF_MEMDIE set.
> > > 
> > > The special handling to determine whether a parallel memcg is currently
> > > oom is removed since we can detect future memory freeing with TIF_MEMDIE.
> > > The memcg has already reached its memory limit, so it will still need to
> > > kill a task regardless of the pagefault oom.
> > > 
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > NACK. please leave memcg's oom as it is. We're now rewriting.
> > This is not core of your patch set. please skip.
> > 
> 
> Your nack is completely unjustified, we're not going to stop oom killer 
> development so memcg can catch up.  This patch allows pagefaults to go 
> through the typical out_of_memory() interface so we don't have any 
> ambiguity in how situations such as panic_on_oom are handled or whether 
> current's memcg recently called the oom killer and it PREVENTS needlessly 
> killing tasks when a parallel oom condition exists but a task hasn't been 
> killed yet.
> 
> mem_cgroup_oom_called() is completely and utterly BOGUS since we can 
> detect the EXACT same conditions via a tasklist scan filtered on current's 
> memcg by looking for parallel oom kills, which out_of_memory() does, and 
> locking the zonelists to prevent racing in calling out_of_memory() and 
> actually setting the TIF_MEMDIE bit for the selected task.
> 
> You said earlier that you would wait for the next mmotm to be released and 
> could easily rebase on my patchset and now you're stopping development 
> entirely and allowing tasks to be needlessly oom killed via the old 
> pagefault_out_of_memory() which does not synchronize on parallel oom 
> kills.
> 
> I'm completely sure that you'll remove mem_cgroup_oom_called() entirely 
> yourself since it doesn't do anything but encourage VM_FAULT_OOM loops 
> itself, so please come up with some constructive criticism of my patch 
> that Andrew can use to decide whether to merge my work or not instead of 
> thinking you're the only one that can touch memcg.
> 

Your patch seems not to go earlier than mine.
And please avoid zone avoid locking. memcg requires memcg based locking.
I pointed out this beofre, but you ignore that as usual.
Then, I said I'll do by myself.

Bye,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

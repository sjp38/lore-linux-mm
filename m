Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BD5B66B00DD
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 20:49:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2I0n3qr018631
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Mar 2010 09:49:03 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7782545DE4D
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:49:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E8DB45DE51
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:49:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 27C121DB8049
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:49:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C6A87E38001
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:49:02 +0900 (JST)
Date: Thu, 18 Mar 2010 09:45:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100318094519.cd1eed72.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100317115855.GS18054@balbir.in.ibm.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Mar 2010 08:54:11 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 17 Mar 2010 17:28:55 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * Andrea Righi <arighi@develer.com> [2010-03-15 00:26:38]:
> > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > Now, file-mapped is maintaiend. But more generic update function
> > > will be needed for dirty page accounting.
> > > 
> > > For accountig page status, we have to guarantee lock_page_cgroup()
> > > will be never called under tree_lock held.
> > > To guarantee that, we use trylock at updating status.
> > > By this, we do fuzzy accounting, but in almost all case, it's correct.
> > >
> > 
> > I don't like this at all, but in almost all cases is not acceptable
> > for statistics, since decisions will be made on them and having them
> > incorrect is really bad. Could we do a form of deferred statistics and
> > fix this.
> > 
> 
> plz show your implementation which has no performance regresssion.
> For me, I don't neee file_mapped accounting, at all. If we can remove that,
> we can add simple migration lock.
> file_mapped is a feattue you added. please improve it.
> 

BTW, I should explain how acculate this accounting is in this patch itself.

Now, lock_page_cgroup/unlock_page_cgroup happens when
	- charge/uncharge/migrate/move accounting

Then, the lock contention (trylock failure) seems to occur in conflict
with
	- charge, uncharge, migarate. move accounting

About dirty accounting, charge/uncharge/migarate are operation in synchronous
manner with radix-tree (holding treelock etc). Then no account leak.
move accounting is only source for inacculacy...but I don't think this move-task
is ciritial....moreover, we don't move any file pages at task-move, now.
(But Nishimura-san has a plan to do so.)
So, contention will happen only at confliction with force_empty.

About FILE_MAPPED accounting, it's not synchronous with radix-tree operaton.
Then, accounting-miss seems to happen when charge/uncharge/migrate/account move.
But
	charge .... we don't account a page as FILE_MAPPED before it's charged.
	uncharge .. usual operation in turncation is unmap->remove-from-radix-tree.
		    Then, it's sequential in almost all case. The race exists when...
		    Assume there are 2 threads A and B. A truncate a file, B map/unmap that.
		    This is very unusal confliction.
	migrate.... we do try_to_unmap before migrating pages. Then, FILE_MAPPED
		    is properly handled.
	move account .... we don't have move-account-mapped-file, yet.

Then, this trylock contention happens at contention with force_empty and truncate.


Then, main issue for contention is force_empty. But it's called for removing memcg,
accounting for such memcg is not important.
Then, I say "this accounting is Okay."

To do more accurate, we may need another "migration lock". But to get better
performance for root cgroup, we have to call mem_cgroup_is_root() before
taking lock and there will be another complicated race.

Bye,
-Kame












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

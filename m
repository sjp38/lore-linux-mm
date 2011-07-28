Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF6B6B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 23:11:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DD50B3EE0C2
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 12:11:07 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 86AD045DEA0
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 12:11:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 62FC045DE97
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 12:11:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5582C1DB8041
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 12:11:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 133CA1DB802F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 12:11:07 +0900 (JST)
Date: Thu, 28 Jul 2011 12:03:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 39632] New: kernel BUG at
 arch/x86/mm/fault.c:395
Message-Id: <20110728120345.dc53e61f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110728092333.9ba574d6.kamezawa.hiroyu@jp.fujitsu.com>
References: <bug-39632-10286@https.bugzilla.kernel.org/>
	<20110727170148.0172a03c.akpm@linux-foundation.org>
	<20110728092333.9ba574d6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, greenhostnl@gmail.com, Tejun Heo <tj@kernel.org>

On Thu, 28 Jul 2011 09:23:33 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 27 Jul 2011 17:01:48 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Wed, 20 Jul 2011 15:25:32 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=39632
> > > 
> > >            Summary: kernel BUG at arch/x86/mm/fault.c:395
> > >            Product: Memory Management
> > >            Version: 2.5
> > >     Kernel Version: 3.0.0-RC7
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: Other
> > >         AssignedTo: akpm@linux-foundation.org
> > >         ReportedBy: greenhostnl@gmail.com
> > >         Regression: No
> > 
> > I think this is a plain old oops in mem_cgroup_charge_statistics(), but
> > for some reason it's treating the oopsing address as part of the
> > vmalloc arena.  Perhaps this is what a use-after-free looks like on the
> > new percpu area implementation?
> > 
> 
> > [426900.218491]  [<ffffffff81358bd9>] ? do_page_fault+0x339/0x4e0
> > [426900.218501]  [<ffffffff810b0d64>] ? __alloc_pages_nodemask+0x144/0x860
> > [426900.218510]  [<ffffffff81355915>] ? page_fault+0x25/0x30
> > [426900.218519]  [<ffffffff810df69a>] ? mem_cgroup_charge_statistics+0x3a/0x60
> 
> Hmm, touches unmapped vmalloc area and caused OOps.
> 
> And yes, mem_cgroup_charge_statistics() touches per-cpu area, which is allocated
> in vmalloc() area....
> 
> The percpu area is allocated at a cgroup creation and freed at destroy.
> 
> I wonder why oom-kill is a trigger for the issue...if there is 
> double-free or some other issue, other trouble can be seen...
> 

Sorry, I lost another view point.
page_cgroup->mem_cgroup may point a stale memcg.

IIUC, pre_destroy() checks res->usage == 0 before destroy(). So, I think
no page_cgroup points to destroyed cgroup, hmm. I'll check again.



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

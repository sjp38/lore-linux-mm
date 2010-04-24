Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 857BE6B021C
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 22:26:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3O2QGeG028858
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 24 Apr 2010 11:26:17 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A750945DE4F
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:26:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8687345DE4D
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:26:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C2C71DB804B
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:26:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2265A1DB8045
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:26:16 +0900 (JST)
Date: Sat, 24 Apr 2010 11:22:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100424112217.e2efb61b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1272056226.1821.41.camel@laptop>
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414140523.GC13535@redhat.com>
	<xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
	<20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
	<g2u49b004811004142148i3db9fefaje1f20760426e0c7e@mail.gmail.com>
	<20100415152104.62593f37.nishimura@mxp.nes.nec.co.jp>
	<20100415155432.cf1861d9.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93k4rxx6sd.fsf@ninji.mtv.corp.google.com>
	<1272056226.1821.41.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 22:57:06 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, 2010-04-23 at 13:17 -0700, Greg Thelen wrote:
> > +static void mem_cgroup_begin_page_cgroup_reassignment(void)
> > +{
> > +       VM_BUG_ON(mem_cgroup_account_move_ongoing);
> > +       mem_cgroup_account_move_ongoing = true;
> > +       synchronize_rcu();
> > +} 
> 
> btw, you know synchronize_rcu() is _really_ slow?
> 
IIUC, this is called once per an event when task is moved and we have
to move accouting information...and once per an event when we call
rmdir() to destroy cgroup. 

So, this is not frequenctly called.
(hooks to migration in this patch is removable.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

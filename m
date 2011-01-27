Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E0ADE8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 18:47:59 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4E5843EE0C1
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:47:56 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FBB745DE58
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:47:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1906845DE55
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:47:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AE0DE08001
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:47:56 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C678D1DB8044
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 08:47:55 +0900 (JST)
Date: Fri, 28 Jan 2011 08:41:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/3] memcg: prevent endless loop on huge page charge
Message-Id: <20110128084155.4189b4ff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110127141451.GA14512@cmpxchg.org>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110121154430.70d45f15.kamezawa.hiroyu@jp.fujitsu.com>
	<20110127103438.GC2401@cmpxchg.org>
	<20110127134645.GA14309@cmpxchg.org>
	<20110127140024.GR14750@redhat.com>
	<20110127141451.GA14512@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Gleb Natapov <gleb@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jan 2011 15:14:51 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hi Gleb,
> 
> On Thu, Jan 27, 2011 at 04:00:24PM +0200, Gleb Natapov wrote:
> > On Thu, Jan 27, 2011 at 02:46:45PM +0100, Johannes Weiner wrote:
> > > The charging code can encounter a charge size that is bigger than a
> > > regular page in two situations: one is a batched charge to fill the
> > > per-cpu stocks, the other is a huge page charge.
> > > 
> > > This code is distributed over two functions, however, and only the
> > > outer one is aware of huge pages.  In case the charging fails, the
> > > inner function will tell the outer function to retry if the charge
> > > size is bigger than regular pages--assuming batched charging is the
> > > only case.  And the outer function will retry forever charging a huge
> > > page.
> > > 
> > > This patch makes sure the inner function can distinguish between batch
> > > charging and a single huge page charge.  It will only signal another
> > > attempt if batch charging failed, and go into regular reclaim when it
> > > is called on behalf of a huge page.
> > > 
> > Yeah, that is exactly the case I am debugging right now. Came up with
> > different solution: pass page_size to __mem_cgroup_do_charge() and
> > compare csize with page_size (not CHARGE_SIZE). Not sure which solution
> > it more correct.
> 
> I guess it makes no difference, but using CHARGE_SIZE gets away
> without adding another parameter to __mem_cgroup_do_charge().
> 

My new one is similar to this ;)

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

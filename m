Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 024E96B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 20:26:54 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F0Qqlk011971
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Apr 2010 09:26:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DD4D45DE53
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 09:26:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6050845DE4E
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 09:26:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 407E31DB8042
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 09:26:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D12F91DB803C
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 09:26:51 +0900 (JST)
Date: Thu, 15 Apr 2010 09:22:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100415092258.9f837c12.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <p2k49b004811004140922v8b6c4c57j2dd435261ff2dd43@mail.gmail.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318041944.GA18054@balbir.in.ibm.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414182904.2f72a63d.kamezawa.hiroyu@jp.fujitsu.com>
	<p2k49b004811004140922v8b6c4c57j2dd435261ff2dd43@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 09:22:41 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Wed, Apr 14, 2010 at 2:29 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> >> A  A  A  if (irqs_disabled()) {
> >> A  A  A  A  A  A  A  if (! trylock_page_cgroup(pc))
> >> A  A  A  A  A  A  A  A  A  A  A  return;
> >> A  A  A  } else
> >> A  A  A  A  A  A  A  lock_page_cgroup(pc);
> >>
> >
> > I prefer trylock_page_cgroup() always.
> 
> What is your reason for preferring trylock_page_cgroup()?  I assume
> it's for code simplicity, but I wanted to check.
> 
> I had though about using trylock_page_cgroup() always, but I think
> that would make file_mapped accounting even more fuzzy that it already
> it is.  I was trying to retain the current accuracy of file_mapped and
> only make new counters, like writeback/dirty/etc (those obtained in
> interrupt), fuzzy.
> 

file_mapped should have different interface as mem_cgroup_update_stat_verrrry_safe().
or some.

I don't think accuracy is important (if it's doesn't go minus) but if people want,
I agree to keep it accurate.


> > I have another idea fixing this up _later_. (But I want to start from simple one.)
> >
> > My rough idea is following. A Similar to your idea which you gave me before.
> 
> Hi Kame-san,
> 
> I like the general approach.  The code I previously gave you appears
> to work and is faster than non-root memcgs using mmotm due to mostly
> being lockless.
> 
I hope so.

> > ==
> > DEFINE_PERCPU(account_move_ongoing);
> 
> What's the reason for having a per-cpu account_move_ongoing flag?
> Would a single system-wide global be sufficient?  I assume the
> majority of the time this value will not be changing because
> accounting moves are rare.
> 
> Perhaps all of the per-cpu variables are packed within a per-cpu
> cacheline making accessing it more likely to be local, but I'm not
> sure if this is true.
> 

Yes. this value is rarely updated but update is not enough rare to put
this value to read_mostly section. We see cacheline ping-pong by random
placement of global variables. This is performance critical.
Recent updates for percpu variables accessor makes access to percpu 
very efficient. I'd like to make use of it.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

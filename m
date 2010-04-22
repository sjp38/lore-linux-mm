Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 501656B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 06:31:14 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3MAVBtK015739
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Apr 2010 19:31:11 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E594245DE50
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 19:31:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B40A445DE51
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 19:31:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A63A1DB8019
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 19:31:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BFB51DB8015
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 19:31:10 +0900 (JST)
Date: Thu, 22 Apr 2010 19:27:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-Id: <20100422192714.da3fdccf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100422100944.GX5683@laptop>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
	<20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100407205418.FB90.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
	<20100421121758.af52f6e0.akpm@linux-foundation.org>
	<20100422072319.GW5683@laptop>
	<20100422162536.b904203e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100422100944.GX5683@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010 20:09:44 +1000
Nick Piggin <npiggin@suse.de> wrote:

> On Thu, Apr 22, 2010 at 04:25:36PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 22 Apr 2010 17:23:19 +1000
> > Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > On Wed, Apr 21, 2010 at 12:17:58PM -0700, Andrew Morton wrote:
> > > > 
> > > > fyi, I still consider these patches to be in the "stuck" state.  So we
> > > > need to get them unstuck.
> > > > 
> > > > 
> > > > Hiroyuki (and anyone else): could you please summarise in the briefest
> > > > way possible what your objections are to Daivd's oom-killer changes?
> > > > 
> > > > I'll start: we don't change the kernel ABI.  Ever.  And when we _do_
> > > > change it we don't change it without warning.
> > > 
> > > How is this turning into such a big issue? It is totally ridiculous.
> > > It is not even a "cleanup".
> > > 
> > > Just drop the ABI-changing patches, and I think the rest of them looked
> > > OK, didn't they?
> > > 
> > I agree with you.
> 
> Oh actually what happened with the pagefault OOM / panic on oom thing?
> We were talking around in circles about that too.
> 
Hmm...checking again.

Maybe related patches are:
 1: oom-remove-special-handling-for-pagefault-ooms.patch
 2: oom-default-to-killing-current-for-pagefault-ooms.patch

IIUC, (1) doesn't make change. But (2)...

Before(1)
 - pagefault-oom kills someone by out_of_memory().
After (1)
 - pagefault-oom calls out_of_memory() only when someone isn't being killed.

So, this patch helps to avoid double-kill and I like this change.

Before (2)
 At pagefault-out-of-memory
  - panic_on_oom==2, panic always.
  - panic_on_oom==1, panic when CONSITRAINT_NONE.
 
After (2)
  At pagefault-put-of-memory, if there is no running OOM-Kill,
  current is killed always. In this case, panic_on_oom doesn't work.

I think panic_on_oom==2 should work.. Hmm. why this behavior changes ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

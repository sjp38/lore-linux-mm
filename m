Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6F23B6B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:45:43 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1GNkA9N006016
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Feb 2010 08:46:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A075845DE52
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 08:46:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7537D45DE4C
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 08:46:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5269C1DB8040
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 08:46:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E030D1DB803A
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 08:46:08 +0900 (JST)
Date: Wed, 17 Feb 2010 08:42:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-Id: <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
	<20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
	<20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010 01:02:28 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 16 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > You don't understand that the behavior has changed ever since 
> > > mempolicy-constrained oom conditions are now affected by a compulsory 
> > > panic_on_oom mode, please see the patch description.  It's absolutely 
> > > insane for a single sysctl mode to panic the machine anytime a cpuset or 
> > > mempolicy runs out of memory and is more prone to user error from setting 
> > > it without fully understanding the ramifications than any use it will ever 
> > > do.  The kernel already provides a mechanism for doing this, OOM_DISABLE.  
> > > if you want your cpuset or mempolicy to risk panicking the machine, set 
> > > all tasks that share its mems or nodes, respectively, to OOM_DISABLE.  
> > > This is no different from the memory controller being immune to such 
> > > panic_on_oom conditions, stop believing that it is the only mechanism used 
> > > in the kernel to do memory isolation.
> > > 
> > You don't explain why "we _have to_ remove API which is used"
> > 
> 
> First, I'm not stating that we _have_ to remove anything, this is a patch 
> proposal that is open for review.
> 
> Second, I believe we _should_ remove panic_on_oom == 2 because it's no 
> longer being used as it was documented: as we've increased the exposure of 
> the oom killer (memory controller, pagefault ooms, now mempolicy tasklist 
> scanning), we constantly have to re-evaluate the semantics of this option 
> while a well-understood tunable with a long history, OOM_DISABLE, already 
> does the equivalent.  The downside of getting this wrong is that the 
> machine panics when it shouldn't have because of an unintended consequence 
> of the mode being enabled (a mempolicy ooms, for example, that was created 
> by the user).  When reconsidering its semantics, I'd personally opt on the 
> safe side and make sure the machine doesn't panic unnecessarily and 
> instead require users to use OOM_DISABLE for tasks they do not want to be 
> oom killed.
> 

Please don't. I had a chance to talk with customer support team and talked
about panic_on_oom briefly. I understood that panic_on_oom_alyways+kdump
is the strongest tool for investigating customer's OOM situtation and do
the best advice to them. panic_on_oom_always+kdump is the 100% information
as snapshot when oom-killer happens. Then, it's easy to investigate and
explain what is wront. They sometimes discover memory leak (by some prorietary
driver) or miss-configuration of the system (as using unnecessary bounce buffer.)

Then, please leave panic_on_oom=always.
Even with mempolicy or cpuset 's OOM, we need panic_on_oom=always option.
And yes, I'll add something similar to memcg. freeze_at_oom or something.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

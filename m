Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 433166B007D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 04:02:35 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o1G92Xp4001915
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:02:33 -0800
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by kpbe20.cbf.corp.google.com with ESMTP id o1G923Vq004208
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:02:32 -0800
Received: by pzk6 with SMTP id 6so631053pzk.18
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:02:31 -0800 (PST)
Date: Tue, 16 Feb 2010 01:02:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
 <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > You don't understand that the behavior has changed ever since 
> > mempolicy-constrained oom conditions are now affected by a compulsory 
> > panic_on_oom mode, please see the patch description.  It's absolutely 
> > insane for a single sysctl mode to panic the machine anytime a cpuset or 
> > mempolicy runs out of memory and is more prone to user error from setting 
> > it without fully understanding the ramifications than any use it will ever 
> > do.  The kernel already provides a mechanism for doing this, OOM_DISABLE.  
> > if you want your cpuset or mempolicy to risk panicking the machine, set 
> > all tasks that share its mems or nodes, respectively, to OOM_DISABLE.  
> > This is no different from the memory controller being immune to such 
> > panic_on_oom conditions, stop believing that it is the only mechanism used 
> > in the kernel to do memory isolation.
> > 
> You don't explain why "we _have to_ remove API which is used"
> 

First, I'm not stating that we _have_ to remove anything, this is a patch 
proposal that is open for review.

Second, I believe we _should_ remove panic_on_oom == 2 because it's no 
longer being used as it was documented: as we've increased the exposure of 
the oom killer (memory controller, pagefault ooms, now mempolicy tasklist 
scanning), we constantly have to re-evaluate the semantics of this option 
while a well-understood tunable with a long history, OOM_DISABLE, already 
does the equivalent.  The downside of getting this wrong is that the 
machine panics when it shouldn't have because of an unintended consequence 
of the mode being enabled (a mempolicy ooms, for example, that was created 
by the user).  When reconsidering its semantics, I'd personally opt on the 
safe side and make sure the machine doesn't panic unnecessarily and 
instead require users to use OOM_DISABLE for tasks they do not want to be 
oom killed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

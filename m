Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFC56B0082
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 19:14:29 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o1G0ERGx002718
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 16:14:27 -0800
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by wpaz29.hot.corp.google.com with ESMTP id o1G0EPC8000902
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 16:14:25 -0800
Received: by pzk11 with SMTP id 11so8794545pzk.30
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 16:14:25 -0800 (PST)
Date: Mon, 15 Feb 2010 16:14:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > If /proc/sys/vm/panic_on_oom is set to 2, the kernel will panic
> > regardless of whether the memory allocation is constrained by either a
> > mempolicy or cpuset.
> > 
> > Since mempolicy-constrained out of memory conditions now iterate through
> > the tasklist and select a task to kill, it is possible to panic the
> > machine if all tasks sharing the same mempolicy nodes (including those
> > with default policy, they may allocate anywhere) or cpuset mems have
> > /proc/pid/oom_adj values of OOM_DISABLE.  This is functionally equivalent
> > to the compulsory panic_on_oom setting of 2, so the mode is removed.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> NACK. In an enviroment which depends on cluster-fail-over, this is useful
> even if in such situation.
> 

You don't understand that the behavior has changed ever since 
mempolicy-constrained oom conditions are now affected by a compulsory 
panic_on_oom mode, please see the patch description.  It's absolutely 
insane for a single sysctl mode to panic the machine anytime a cpuset or 
mempolicy runs out of memory and is more prone to user error from setting 
it without fully understanding the ramifications than any use it will ever 
do.  The kernel already provides a mechanism for doing this, OOM_DISABLE.  
if you want your cpuset or mempolicy to risk panicking the machine, set 
all tasks that share its mems or nodes, respectively, to OOM_DISABLE.  
This is no different from the memory controller being immune to such 
panic_on_oom conditions, stop believing that it is the only mechanism used 
in the kernel to do memory isolation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

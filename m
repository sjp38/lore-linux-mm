Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E7BC96B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 17:11:58 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [10.3.21.3])
	by smtp-out.google.com with ESMTP id o3MLBsvh011665
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:11:54 +0200
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by hpaq3.eem.corp.google.com with ESMTP id o3MLBq5w030937
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:11:53 +0200
Received: by pzk35 with SMTP id 35so1045129pzk.0
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 14:11:52 -0700 (PDT)
Date: Thu, 22 Apr 2010 14:11:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100422192714.da3fdccf.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1004221409560.25350@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com> <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com> <20100407205418.FB90.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org> <20100422072319.GW5683@laptop> <20100422162536.b904203e.kamezawa.hiroyu@jp.fujitsu.com> <20100422100944.GX5683@laptop> <20100422192714.da3fdccf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010, KAMEZAWA Hiroyuki wrote:

> Hmm...checking again.
> 
> Maybe related patches are:
>  1: oom-remove-special-handling-for-pagefault-ooms.patch
>  2: oom-default-to-killing-current-for-pagefault-ooms.patch
> 
> IIUC, (1) doesn't make change. But (2)...
> 
> Before(1)
>  - pagefault-oom kills someone by out_of_memory().
> After (1)
>  - pagefault-oom calls out_of_memory() only when someone isn't being killed.
> 
> So, this patch helps to avoid double-kill and I like this change.
> 
> Before (2)
>  At pagefault-out-of-memory
>   - panic_on_oom==2, panic always.
>   - panic_on_oom==1, panic when CONSITRAINT_NONE.
>  
> After (2)
>   At pagefault-put-of-memory, if there is no running OOM-Kill,
>   current is killed always. In this case, panic_on_oom doesn't work.
> 
> I think panic_on_oom==2 should work.. Hmm. why this behavior changes ?
> 

We can readd the panic_on_oom code once Nick's patchset is merged that 
unifies all architectures in using pagefault_out_of_memory() for 
VM_FAULT_OOM.  Otherwise, some architectures would panic in this case and 
others would not (while they allow tasks to be SIGKILL'd even when 
panic_on_oom == 2 is set, including OOM_DISABLE tasks!) so I think it's 
better to be entirely consistent with sysctl semantics across 
architectures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

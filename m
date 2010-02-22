Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A3C856B0078
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 15:59:12 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o1MKxJvf015764
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 12:59:20 -0800
Received: from pxi16 (pxi16.prod.google.com [10.243.27.16])
	by wpaz5.hot.corp.google.com with ESMTP id o1MKwsBg003634
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 12:59:18 -0800
Received: by pxi16 with SMTP id 16so1564398pxi.29
        for <linux-mm@kvack.org>; Mon, 22 Feb 2010 12:59:18 -0800 (PST)
Date: Mon, 22 Feb 2010 12:59:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100222204237.61e3c615.d-nishimura@mtf.biglobe.ne.jp>
Message-ID: <alpine.DEB.2.00.1002221256470.14426@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com> <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com> <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com> <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com> <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com> <20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com>
 <20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com> <20100222143151.9e362c88.nishimura@mxp.nes.nec.co.jp> <20100222151513.0605d69e.kamezawa.hiroyu@jp.fujitsu.com> <20100222204237.61e3c615.d-nishimura@mtf.biglobe.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Feb 2010, Daisuke Nishimura wrote:

> hmm, I can agree with you. But I think we need some trick to distinguish normal VM_FAULT_OOM
> and memcg's VM_FAULT_OOM(the current itself was killed by memcg's oom, so exited the retry)
> at mem_cgroup_oom_called() to avoid the system from panic when panic_on_oom is enabled.
> (Mark the task which is being killed by memcg's oom ?).
> 

pagefault_out_of_memory() should use mem_cgroup_from_task(current) and 
then call mem_cgroup_out_of_memory() when it's non-NULL.  
select_bad_process() will return ERR_PTR(-1UL) if there is an already oom 
killed task attached to the memcg, so we can use that to avoid the 
panic_on_oom.  The setting of that sysctl doesn't imply that we can't scan 
the tasklist, it simply means we can't kill anything as a result of an 
oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

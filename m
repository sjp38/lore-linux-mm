Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2PBiarO016707
	for <linux-mm@kvack.org>; Tue, 25 Mar 2008 17:14:36 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2PBiaLm1347624
	for <linux-mm@kvack.org>; Tue, 25 Mar 2008 17:14:36 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2PBiZ9c014195
	for <linux-mm@kvack.org>; Tue, 25 Mar 2008 11:44:36 GMT
Message-ID: <47E8E4F3.6090604@linux.vnet.ibm.com>
Date: Tue, 25 Mar 2008 17:11:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] Memory controller add mm->owner
References: <20080324140142.28786.97267.sendpatchset@localhost.localdomain> <6599ad830803240803s5160101bi2bf68b36085f777f@mail.gmail.com> <47E7D51E.4050304@linux.vnet.ibm.com> <6599ad830803240934g2a70d904m1ca5548f8644c906@mail.gmail.com> <47E7E5D0.9020904@linux.vnet.ibm.com> <6599ad830803241046l61e2965t52fd28e165d5df7a@mail.gmail.com>
In-Reply-To: <6599ad830803241046l61e2965t52fd28e165d5df7a@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Mar 24, 2008 at 10:33 AM, Balbir Singh
> <balbir@linux.vnet.ibm.com> wrote:
>>  > OK, so we don't need to handle this for NPTL apps - but for anything
>>  > still using LinuxThreads or manually constructed clone() calls that
>>  > use CLONE_VM without CLONE_PID, this could still be an issue.
>>
>>  CLONE_PID?? Do you mean CLONE_THREAD?
> 
> Yes, sorry - CLONE_THREAD.
> 
>>  For the case you mentioned, mm->owner is a moving target and we don't want to
>>  spend time finding the successor, that can be expensive when threads start
>>  exiting one-by-one quickly and when the number of threads are high. I wonder if
>>  there is an efficient way to find mm->owner in that case.
>>
> 
> But:
> 
> - running a high-threadcount LinuxThreads process is by definition
> inefficient and expensive (hence the move to NPTL)
> 
> - any potential performance hit is only paid at exit time
> 
> - in the normal case, any of your children or one of your siblings
> will be a suitable alternate owner
> 
> - in the worst case, it's not going to be worse than doing a
> for_each_thread() loop
> 
> so I don't think this would be a major problem
> 

I've been looking at zap_threads, I suspect we'll end up implementing a similar
loop, which makes me very uncomfortable. Adding code for the least possible
scenario. It will not get invoked for CLONE_THREAD, but will get invoked for the
case when CLONE_VM is set without CLONE_THREAD.

I'll try and experiment a bit more and see what I come up with


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

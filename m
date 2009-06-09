Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F262F6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 20:28:53 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n590gpSI016286
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Jun 2009 09:42:51 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7396B45DE4E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 09:42:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 53B4F45DE51
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 09:42:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B7741DB8040
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 09:42:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EF1091DB8038
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 09:42:47 +0900 (JST)
Date: Tue, 9 Jun 2009 09:41:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: huge mem mmap eats all CPU when multiple processes
Message-Id: <20090609094117.8226c0ca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <8FDBF172-AAA8-4737-A6C6-50B468CA0CBF@thehive.com>
References: <8FDBF172-AAA8-4737-A6C6-50B468CA0CBF@thehive.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matthew Von Maszewski <matthew@thehive.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jun 2009 10:27:49 -0400
Matthew Von Maszewski <matthew@thehive.com> wrote:

> [note: not on kernel mailing list, please cc author]
> 
> Symptom:  9 processes mmap same 2 Gig memory section for a shared C  
> heap (lots of random access).  All process begin extreme CPU load in  
> top.
> 
> - Same code works well when only single process access huge mem.
Does this "huge mem" means HugeTLB(2M/4Mbytes) pages ?

> - Code works well with standard vm based mmap file and 9 processes.
> 

What is sys/user ratio in top ? Almost all cpus are used by "sys" ?

> Environment:
> 
> - Intel x86_64:  Dual core Xeon with hyperthreading (4 logical  
> processors)
> - 6 Gig ram, 2.5G allocated to huge mem
by boot option ?

> - tried with kernels 2.6.29.4 and 2.6.30-rc8
> - following mmap() call has base address as NULL on first process,  
> then returned address passed to subsequent processes (not threads,  
> processes)
> 
>             m_MemSize=((m_MemSize/(2048*1024))+1)*2048*1024;
>              m_BaseAddr=mmap(m_File->GetFixedBase(), m_MemSize,
>                              (PROT_READ | PROT_WRITE),
>                              MAP_SHARED, m_File->GetFileId(), m_Offset);
> 
> 
> I am not a kernel hacker so I have not attempted to debug.  Will be  
> able to spend time on a sample program for sharing later today or  
> tomorrow.  Sending this note now in case this is already known.
> 

IIUC, all page faults to hugetlb are serialized by system's mutex. Then, touching
in parallel doesn't do fast job..
Then, I wonder touching all necessary maps by one thread is good, in general.



> Don't suppose this is as simple as a Copy-On-Write flag being set wrong?
> 
I don't think, so.

> Please send notes as to things I need to capture to better describe  
> this bug.  Happy to do the work.
> 
Add cc to linux-mm.

Thanks,
-Kame


> Thanks,
> Matthew
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

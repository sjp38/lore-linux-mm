Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 25FF76B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 18:56:33 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so18359273pab.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 15:56:32 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id ba5si40717497pbb.193.2015.09.29.15.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 15:56:32 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so19171534pac.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 15:56:32 -0700 (PDT)
Date: Tue, 29 Sep 2015 15:56:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: can't oom-kill zap the victim's memory?
In-Reply-To: <201509291657.HHD73972.MOFVSHQtOJFOLF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1509291547560.3375@chino.kir.corp.google.com>
References: <20150922160608.GA2716@redhat.com> <20150923205923.GB19054@dhcp22.suse.cz> <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com> <20150925093556.GF16497@dhcp22.suse.cz> <alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
 <201509291657.HHD73972.MOFVSHQtOJFOLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Tue, 29 Sep 2015, Tetsuo Handa wrote:

> Is the story such simple? I think there are factors which disturb memory
> allocation with mmap_sem held for writing.
> 
>   down_write(&mm->mmap_sem);
>   kmalloc(GFP_KERNEL);
>   up_write(&mm->mmap_sem);
> 
> can involve locks inside __alloc_pages_slowpath().
> 
> Say, there are three userspace tasks named P1, P2T1, P2T2 and
> one kernel thread named KT1. Only P2T1 and P2T2 shares the same mm.
> KT1 is a kernel thread for fs writeback (maybe kswapd?).
> I think sequence shown below is possible.
> 
> (1) P1 enters into kernel mode via write() syscall.
> 
> (2) P1 allocates memory for buffered write.
> 
> (3) P2T1 enters into kernel mode and calls kmalloc().
> 
> (4) P2T1 arrives at __alloc_pages_may_oom() because there was no
>     reclaimable memory. (Memory allocated by P1 is not reclaimable
>     as of this moment.)
> 
> (5) P1 dirties memory allocated for buffered write.
> 
> (6) P2T2 enters into kernel mode and calls kmalloc() with
>     mmap_sem held for writing.
> 
> (7) KT1 finds dirtied memory.
> 
> (8) KT1 holds fs's unkillable lock for fs writeback.
> 
> (9) P2T2 is blocked at unkillable lock for fs writeback held by KT1.
> 
> (10) P2T1 calls out_of_memory() and the OOM killer chooses P2T1 and sets
>      TIF_MEMDIE on both P2T1 and P2T2.
> 
> (11) P2T2 got TIF_MEMDIE but is blocked at unkillable lock for fs writeback
>      held by KT1.
> 
> (12) KT1 is trying to allocate memory for fs writeback. But since P2T1 and
>      P2T2 cannot release memory because memory unmapping code cannot hold
>      mmap_sem for reading, KT1 waits forever.... OOM livelock completed!
> 
> I think sequence shown below is also possible. Say, there are three
> userspace tasks named P1, P2, P3 and one kernel thread named KT1.
> 
> (1) P1 enters into kernel mode via write() syscall.
> 
> (2) P1 allocates memory for buffered write.
> 
> (3) P2 enters into kernel mode and holds mmap_sem for writing.
> 
> (4) P3 enters into kernel mode and calls kmalloc().
> 
> (5) P3 arrives at __alloc_pages_may_oom() because there was no
>     reclaimable memory. (Memory allocated by P1 is not reclaimable
>     as of this moment.)
> 
> (6) P1 dirties memory allocated for buffered write.
> 
> (7) KT1 finds dirtied memory.
> 
> (8) KT1 holds fs's unkillable lock for fs writeback.
> 
> (9) P2 calls kmalloc() and is blocked at unkillable lock for fs writeback
>     held by KT1.
> 
> (10) P3 calls out_of_memory() and the OOM killer chooses P2 and sets
>      TIF_MEMDIE on P2.
> 
> (11) P2 got TIF_MEMDIE but is blocked at unkillable lock for fs writeback
>      held by KT1.
> 
> (12) KT1 is trying to allocate memory for fs writeback. But since P2 cannot
>      release memory because memory unmapping code cannot hold mmap_sem for
>      reading, KT1 waits forever.... OOM livelock completed!
> 
> So, allowing all OOM victim threads to use memory reserves does not guarantee
> that a thread which held mmap_sem for writing to make forward progress.
> 

Thank you for writing this all out, it definitely helps to understand the 
concerns.

This, in my understanding, is the same scenario that requires not only oom 
victims to be able to access memory reserves, but also any thread after an 
oom victim has failed to make a timely exit.

I point out mm->mmap_sem as a special case because we have had fixes in 
the past, such as the special fatal_signal_pending() handling in 
__get_user_pages(), that try to ensure forward progress since we know that 
we need exclusive mm->mmap_sem for the victim to make an exit.

I think both of your illustrations show why it is not helpful to kill 
additional processes after a time period has elapsed and a victim has 
failed to exit.  In both of your scenarios, it would require that KT1 be 
killed to allow forward progress and we know that's not possible.

Perhaps this is an argument that we need to provide access to memory 
reserves for threads even for !__GFP_WAIT and !__GFP_FS in such scenarios, 
but I would wait to make that extension until we see it in practice.

Killing all mm->mmap_sem threads certainly isn't meant to solve all oom 
killer livelocks, as you show.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

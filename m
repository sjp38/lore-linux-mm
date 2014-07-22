Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1DAE26B0035
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 08:09:59 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so7827080wev.27
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 05:09:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vl8si394990wjc.152.2014.07.22.05.09.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 05:09:57 -0700 (PDT)
Message-ID: <53CE5494.3030708@suse.cz>
Date: Tue, 22 Jul 2014 14:09:56 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz> <53C7F5FF.7010006@oracle.com> <53C8FAA6.9050908@oracle.com> <alpine.LSU.2.11.1407191628450.24073@eggly.anvils> <53CDD961.1080006@oracle.com> <alpine.LSU.2.11.1407220049140.1980@eggly.anvils> <53CE37A6.2060000@suse.cz>
In-Reply-To: <53CE37A6.2060000@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>

On 07/22/2014 12:06 PM, Vlastimil Babka wrote:
> So if this is true, the change to TASK_UNINTERRUPTIBLE will avoid the
> problem, but it would be nicer to keep the KILLABLE state.
> I think it could be done by testing if the wait queue still exists and
> is the same, before attempting finish wait. If it doesn't exist, that
> means the faulter can skip finish_wait altogether because it must be
> already TASK_RUNNING.
>
> shmem_falloc = inode->i_private;
> if (shmem_falloc && shmem_falloc->waitq == shmem_falloc_waitq)
> 	finish_wait(shmem_falloc_waitq, &shmem_fault_wait);
>
> It might still be theoretically possible that although it has the same
> address, it's not the same wait queue, but that doesn't hurt
> correctness. I might be uselessly locking some other waitq's lock, but
> the inode->i_lock still protects me from other faulters that are in the
> same situation. The puncher is already gone.

Actually, I was wrong and deleting from a different queue could corrupt 
the queue head. I don't know if trinity would be able to trigger this, 
but I wouldn't be comfortable knowing it's possible. Calling fallocate 
twice in quick succession from the same process could easily end up at 
the same address on the stack, no?

Another also somewhat ugly possibility is to make sure that the wait 
queue is empty before the puncher quits, regardless of the running state 
of the processes in the queue. I think the conditions here 
(serialization by i_lock) might allow us to do that without risking that 
we e.g. leave anyone sleeping. But it's bending the wait queue design...

> However it's quite ugly and if there is some wait queue debugging mode
> (I hadn't checked) that e.g. checks if wait queues and wait objects are
> empty before destruction, it wouldn't like this at all...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

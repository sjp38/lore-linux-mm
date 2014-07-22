Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id CFC7D6B0037
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 04:08:57 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so11006602pab.28
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 01:08:57 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ag5si16861723pbc.9.2014.07.22.01.08.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 01:08:56 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so11362122pab.26
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 01:08:56 -0700 (PDT)
Date: Tue, 22 Jul 2014 01:07:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
In-Reply-To: <53CDD961.1080006@oracle.com>
Message-ID: <alpine.LSU.2.11.1407220049140.1980@eggly.anvils>
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz> <53C7F5FF.7010006@oracle.com> <53C8FAA6.9050908@oracle.com> <alpine.LSU.2.11.1407191628450.24073@eggly.anvils> <53CDD961.1080006@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 21 Jul 2014, Sasha Levin wrote:
> On 07/19/2014 07:44 PM, Hugh Dickins wrote:
> >> Otherwise, I've been unable to reproduce the shmem_fallocate hang.
> > Great.  Andrew, I think we can say that it's now safe to send
> > 1/2 shmem: fix faulting into a hole, not taking i_mutex
> > 2/2 shmem: fix splicing from a hole while it's punched
> > on to Linus whenever suits you.
> > 
> > (You have some other patches in the mainline-later section of the
> > mmotm/series file: they're okay too, but not in doubt as these two were.)
> 
> I think we may need to hold off on sending them...
> 
> It seems that this code in shmem_fault():
> 
> 	/*
> 	 * shmem_falloc_waitq points into the shmem_fallocate()
> 	 * stack of the hole-punching task: shmem_falloc_waitq
> 	 * is usually invalid by the time we reach here, but
> 	 * finish_wait() does not dereference it in that case;
> 	 * though i_lock needed lest racing with wake_up_all().
> 	 */
> 	spin_lock(&inode->i_lock);
> 	finish_wait(shmem_falloc_waitq, &shmem_fault_wait);
> 	spin_unlock(&inode->i_lock);
> 
> Is problematic. I'm not sure what changed, but it seems to be causing everything
> from NULL ptr derefs:
> 
> [  169.922536] BUG: unable to handle kernel NULL pointer dereference at 0000000000000631
> 
> To memory corruptions:
> 
> [ 1031.264226] BUG: spinlock bad magic on CPU#1, trinity-c99/25740
> 
> And hangs:
> 
> [  212.010020] INFO: rcu_preempt detected stalls on CPUs/tasks:

Ugh.

I'm so tired of this, I'm flailing around here, and could use some help.

But there is one easy change which might do it: please would you try
changing the TASK_KILLABLE a few lines above to TASK_UNINTERRUPTIBLE.

I noticed when deciding on the i_lock'ing there, that a lot of the
difficulty in races between the two ends, came from allowing KILLABLE
at the faulting end.  Which was a nice courtesy, but one I'll gladly
give up on now, if it is responsible for these troubles.

Please give it a try, I don't know what else to suggest.  And I've
no idea why the problem should emerge only now.  If this change
does appear to fix it, please go back and forth with and without,
to gather confidence that the problem is still reproducible without
the fix.  If fix it turns out to be - touch wood.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

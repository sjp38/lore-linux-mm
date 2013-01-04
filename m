Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id D2ACF6B006E
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 10:39:57 -0500 (EST)
Date: Fri, 4 Jan 2013 16:39:51 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: 3.8-rc2: lockdep is complaining about mm_take_all_locks()
In-Reply-To: <alpine.LNX.2.00.1301041317150.9143@pobox.suse.cz>
Message-ID: <alpine.LNX.2.00.1301041639130.9143@pobox.suse.cz>
References: <alpine.LNX.2.00.1301041317150.9143@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 4 Jan 2013, Jiri Kosina wrote:

> This is almost certainly because
> 
> commit 5a505085f043e8380f83610f79642853c051e2f1
> Author: Ingo Molnar <mingo@kernel.org>
> Date:   Sun Dec 2 19:56:46 2012 +0000
> 
>     mm/rmap: Convert the struct anon_vma::mutex to an rwsem
> 
> did this to mm_take_all_locks():
> 
> 	-               mutex_lock_nest_lock(&anon_vma->root->mutex, &mm->mmap_sem);
> 	+               down_write(&anon_vma->root->rwsem);
> 
> killing the lockdep annotation that has been there since 
> 
> commit 454ed842d55740160334efc9ad56cfef54ed37bc
> Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date:   Mon Aug 11 09:30:25 2008 +0200
> 
>     lockdep: annotate mm_take_all_locks()
> 
> The locking is obviously correct due to mmap_sem being held throughout the 
> whole operation, but I am not completely sure how to annotate this 
> properly for lockdep in down_write() case though. Ingo, please?

OK, I think the only solution is to introduce down_read_nest_lock(). I 
will prepare a patch.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

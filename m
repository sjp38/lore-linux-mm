Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 069466B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 14:07:11 -0400 (EDT)
Message-ID: <1378231630.17792.6.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc/msg.c: Fix lost wakeup in msgsnd().
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 03 Sep 2013 11:07:10 -0700
In-Reply-To: <1378216808-2564-1-git-send-email-manfred@colorfullife.com>
References: <1378216808-2564-1-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave.bueso@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Jonathan Gonzalez <jgonzalez@linets.cl>, Vineet Gupta <Vineet.Gupta1@synopsys.com>

On Tue, 2013-09-03 at 16:00 +0200, Manfred Spraul wrote:
> The check if the queue is full and adding current to the wait queue of pending
> msgsnd() operations (ss_add()) must be atomic.
> 
> Otherwise:
> - the thread that performs msgsnd() finds a full queue and decides to sleep.
> - the thread that performs msgrcv() calls first reads all messages from the
>   queue and then sleep, because the queue is empty.
> - the msgrcv() calls do not perform any wakeups, because the msgsnd() task
>   has not yet called ss_add().
> - then the msgsnd()-thread first calls ss_add() and then sleeps.
> Net result: msgsnd() and msgrcv() both sleep forever.
> 
> Observed with msgctl08 from ltp with a preemptible kernel.

Good catch, thanks for looking into this Manfred. 

FWIW similar changes that aim at reducing the kern_ipc_perm.lock
contention in shm have already been in linux-next for a good while and
should be going into 3.12. While both Sedat and I have tested them
through LTP, I will keep an eye open for regressions so that we don't
run into issues like this, late in the release cycle.

> 
> Fix: Call ipc_lock_object() before performing the check.
> 
> The patch also moves security_msg_queue_msgsnd() under ipc_lock_object:
> - msgctl(IPC_SET) explicitely mentions that it tries to expunge any pending
>   operations that are not allowed anymore with the new permissions.
>   If security_msg_queue_msgsnd() is called without locks, then there might be
>   races.

Right.

> - it makes the patch much simpler.
> 
> Reported-by: Vineet Gupta <Vineet.Gupta1@synopsys.com>
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>

> ---
>  ipc/msg.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/ipc/msg.c b/ipc/msg.c
> index 9f29d9e..b65fdf1 100644
> --- a/ipc/msg.c
> +++ b/ipc/msg.c
> @@ -680,16 +680,18 @@ long do_msgsnd(int msqid, long mtype, void __user *mtext,
>  		goto out_unlock1;
>  	}
>  
> +	ipc_lock_object(&msq->q_perm);
> +
>  	for (;;) {
>  		struct msg_sender s;
>  
>  		err = -EACCES;
>  		if (ipcperms(ns, &msq->q_perm, S_IWUGO))
> -			goto out_unlock1;
> +			goto out_unlock0;
>  
>  		err = security_msg_queue_msgsnd(msq, msg, msgflg);
>  		if (err)
> -			goto out_unlock1;
> +			goto out_unlock0;
>  
>  		if (msgsz + msq->q_cbytes <= msq->q_qbytes &&
>  				1 + msq->q_qnum <= msq->q_qbytes) {
> @@ -699,10 +701,9 @@ long do_msgsnd(int msqid, long mtype, void __user *mtext,
>  		/* queue full, wait: */
>  		if (msgflg & IPC_NOWAIT) {
>  			err = -EAGAIN;
> -			goto out_unlock1;
> +			goto out_unlock0;
>  		}
>  
> -		ipc_lock_object(&msq->q_perm);
>  		ss_add(msq, &s);
>  
>  		if (!ipc_rcu_getref(msq)) {
> @@ -730,10 +731,7 @@ long do_msgsnd(int msqid, long mtype, void __user *mtext,
>  			goto out_unlock0;
>  		}
>  
> -		ipc_unlock_object(&msq->q_perm);
>  	}
> -
> -	ipc_lock_object(&msq->q_perm);
>  	msq->q_lspid = task_tgid_vnr(current);
>  	msq->q_stime = get_seconds();
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

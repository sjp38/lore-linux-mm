Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D78576B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 19:29:46 -0400 (EDT)
Message-ID: <1372202983.1888.22.camel@buesod1.americas.hpqcorp.net>
Subject: Re: linux-next: Tree for Jun 21 [ BROKEN ipc/ipc-msg ]
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Tue, 25 Jun 2013 16:29:43 -0700
In-Reply-To: <CA+icZUXgOd=URJBH5MGAZKdvdkMpFt+5mRxtzuDzq_vFHpoc2A@mail.gmail.com>
References: 
	<CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
	 <CA+icZUVbUD1tUa_ORtn_ZZebpp3gXXHGAcNe0NdYPXPMPoABuA@mail.gmail.com>
	 <1372192414.1888.8.camel@buesod1.americas.hpqcorp.net>
	 <CA+icZUXgOd=URJBH5MGAZKdvdkMpFt+5mRxtzuDzq_vFHpoc2A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Manfred Spraul <manfred@colorfullife.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

On Tue, 2013-06-25 at 23:41 +0200, Sedat Dilek wrote:
> On Tue, Jun 25, 2013 at 10:33 PM, Davidlohr Bueso
> <davidlohr.bueso@hp.com> wrote:
> > On Tue, 2013-06-25 at 18:10 +0200, Sedat Dilek wrote:
> > [...]
> >
> >> I did some more testing with Linux-Testing-Project (release:
> >> ltp-full-20130503) and next-20130624 (Monday) which has still the
> >> issue, here.
> >>
> >> If I revert the mentioned two commits from my local
> >> revert-ipc-next20130624-5089fd1c6a6a-ab9efc2d0db5 GIT repo, everything
> >> is fine.
> >>
> >> I have tested the LTP ***IPC*** and ***SYSCALLS*** testcases.
> >>
> >>    root# ./runltp -f ipc
> >>
> >>    root# ./runltp -f syscalls
> >
> > These are nice test cases!
> >
> > So I was able to reproduce the issue with LTP and manually running
> > msgctl08. We seemed to be racing at find_msg(), so take to q_perm lock
> > before calling it. The following changes fixes the issue and passes all
> > 'runltp -f syscall' tests, could you give it a try?
> >
> 
> Cool, that fixes the issues here.
> 
> Building with fakeroot & make deb-pkg is now OK, again.
> 
> The syscalls/msgctl08 test-case ran successfully!

Andrew, could you pick this one up? I've made the patch on top of
3.10.0-rc7-next-20130625

Thanks.
Davidlohr

8<---------------------------------

From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH] ipc,msq: fix race in msgrcv(2)

Sedat reported the following issue when building the latest linux-next:

Building via 'make deb-pkg' with fakeroot fails here like this:

make: *** [deb-pkg] Terminated
/usr/bin/fakeroot: line 181:  2386 Terminated
FAKEROOTKEY=$FAKEROOTKEY LD_LIBRARY_PATH="$PATHS" LD_PRELOAD="$LIB"
"$@"
semop(1): encountered an error: Identifier removed
semop(2): encountered an error: Invalid argument
semop(1): encountered an error: Identifier removed
semop(1): encountered an error: Identifier removed
semop(1): encountered an error: Invalid argument
semop(1): encountered an error: Invalid argument
semop(1): encountered an error: Invalid argument

The issue was caused by a race in find_msg(), so acquire the q_perm.lock
before calling the function. This also broke some LTP test cases:

<<<test_start>>>
tag=msgctl08 stime=1372174954
cmdline="msgctl08"
contacts=""
analysis=exit
<<<test_output>>>
msgctl08    0  TWARN  :  Verify error in child 0, *buf = 28, val = 27, size = 8
msgctl08    1  TFAIL  :  in child 0 read # = 73,key =  127
msgctl08    0  TWARN  :  Verify error in child 3, *buf = ffffff8a, val
= ffffff89, size = 52
msgctl08    1  TFAIL  :  in child 3 read # = 157,key =  189
msgctl08    0  TWARN  :  Verify error in child 2, *buf = ffffff87, val
= ffffff86, size = 71
msgctl08    1  TFAIL  :  in child 2 read # = 15954,key =  3e86
msgctl08    0  TWARN  :  Verify error in child 12, *buf = ffffffa9,
val = ffffffa8, size = 22
msgctl08    1  TFAIL  :  in child 12 read # = 12904,key =  32a8
msgctl08    0  TWARN  :  Verify error in child 13, *buf = 36, val =
35, size = 27
...

Also update a comment referring to ipc_lock_by_ptr(), which has already been deleted
and no longer applies to this context.

Reported-and-tested-by: Sedat Dilek <sedat.dilek@gmail.com>
Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 ipc/msg.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/ipc/msg.c b/ipc/msg.c
index a1cf70e..bd60d7e 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -895,6 +895,7 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
 		if (ipcperms(ns, &msq->q_perm, S_IRUGO))
 			goto out_unlock1;
 
+		ipc_lock_object(&msq->q_perm);
 		msg = find_msg(msq, &msgtyp, mode);
 		if (!IS_ERR(msg)) {
 			/*
@@ -903,7 +904,7 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
 			 */
 			if ((bufsz < msg->m_ts) && !(msgflg & MSG_NOERROR)) {
 				msg = ERR_PTR(-E2BIG);
-				goto out_unlock1;
+				goto out_unlock0;
 			}
 			/*
 			 * If we are copying, then do not unlink message and do
@@ -911,10 +912,9 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
 			 */
 			if (msgflg & MSG_COPY) {
 				msg = copy_msg(msg, copy);
-				goto out_unlock1;
+				goto out_unlock0;
 			}
 
-			ipc_lock_object(&msq->q_perm);
 			list_del(&msg->m_list);
 			msq->q_qnum--;
 			msq->q_rtime = get_seconds();
@@ -930,10 +930,9 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
 		/* No message waiting. Wait for a message */
 		if (msgflg & IPC_NOWAIT) {
 			msg = ERR_PTR(-ENOMSG);
-			goto out_unlock1;
+			goto out_unlock0;
 		}
 
-		ipc_lock_object(&msq->q_perm);
 		list_add_tail(&msr_d.r_list, &msq->q_receivers);
 		msr_d.r_tsk = current;
 		msr_d.r_msgtype = msgtyp;
@@ -957,7 +956,7 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
 		 * Prior to destruction, expunge_all(-EIRDM) changes r_msg.
 		 * Thus if r_msg is -EAGAIN, then the queue not yet destroyed.
 		 * rcu_read_lock() prevents preemption between reading r_msg
-		 * and the spin_lock() inside ipc_lock_by_ptr().
+		 * and acquiring the q_perm.lock in ipc_lock_object().
 		 */
 		rcu_read_lock();
 
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

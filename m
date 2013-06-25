Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 805076B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 16:33:39 -0400 (EDT)
Message-ID: <1372192414.1888.8.camel@buesod1.americas.hpqcorp.net>
Subject: Re: linux-next: Tree for Jun 21 [ BROKEN ipc/ipc-msg ]
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Tue, 25 Jun 2013 13:33:34 -0700
In-Reply-To: <CA+icZUVbUD1tUa_ORtn_ZZebpp3gXXHGAcNe0NdYPXPMPoABuA@mail.gmail.com>
References: 
	<CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
	 <CA+icZUVbUD1tUa_ORtn_ZZebpp3gXXHGAcNe0NdYPXPMPoABuA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Manfred Spraul <manfred@colorfullife.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

On Tue, 2013-06-25 at 18:10 +0200, Sedat Dilek wrote:
[...]

> I did some more testing with Linux-Testing-Project (release:
> ltp-full-20130503) and next-20130624 (Monday) which has still the
> issue, here.
> 
> If I revert the mentioned two commits from my local
> revert-ipc-next20130624-5089fd1c6a6a-ab9efc2d0db5 GIT repo, everything
> is fine.
> 
> I have tested the LTP ***IPC*** and ***SYSCALLS*** testcases.
> 
>    root# ./runltp -f ipc
> 
>    root# ./runltp -f syscalls

These are nice test cases!

So I was able to reproduce the issue with LTP and manually running
msgctl08. We seemed to be racing at find_msg(), so take to q_perm lock
before calling it. The following changes fixes the issue and passes all
'runltp -f syscall' tests, could you give it a try?

Thanks,
Davidlohr

diff --git a/ipc/msg.c b/ipc/msg.c
index a1cf70e..a1f7d84 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -895,6 +895,7 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
                if (ipcperms(ns, &msq->q_perm, S_IRUGO))
                        goto out_unlock1;
 
+               ipc_lock_object(&msq->q_perm);
                msg = find_msg(msq, &msgtyp, mode);
                if (!IS_ERR(msg)) {
                        /*
@@ -903,7 +904,7 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
                         */
                        if ((bufsz < msg->m_ts) && !(msgflg & MSG_NOERROR)) {
                                msg = ERR_PTR(-E2BIG);
-                               goto out_unlock1;
+                               goto out_unlock0;
                        }
                        /*
                         * If we are copying, then do not unlink message and do
@@ -911,10 +912,9 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
                         */
                        if (msgflg & MSG_COPY) {
                                msg = copy_msg(msg, copy);
-                               goto out_unlock1;
+                               goto out_unlock0;
                        }
 
-                       ipc_lock_object(&msq->q_perm);
                        list_del(&msg->m_list);
                        msq->q_qnum--;
                        msq->q_rtime = get_seconds();
@@ -930,10 +930,9 @@ long do_msgrcv(int msqid, void __user *buf, size_t bufsz, long msgtyp, int msgfl
                /* No message waiting. Wait for a message */
                if (msgflg & IPC_NOWAIT) {
                        msg = ERR_PTR(-ENOMSG);
-                       goto out_unlock1;
+                       goto out_unlock0;
                }
 
-               ipc_lock_object(&msq->q_perm);
                list_add_tail(&msr_d.r_list, &msq->q_receivers);
                msr_d.r_tsk = current;
                msr_d.r_msgtype = msgtyp;


Thanks,
Davidlohr
> 
> IPC seems to be fine for both -1 (UNPATCHED) and -2 (with attached two
> REVERTED patches) kernel, but -1 hangs in the SYSCALLS/msgctl08 test.
> 
> Previous msgctl07 is OK, but ***msgctl08*** produces this:
> ...
> <<<test_start>>>
> tag=msgctl07 stime=1372174934
> cmdline="msgctl07"
> contacts=""
> analysis=exit
> <<<test_output>>>
> msgctl07    1  TPASS  :  msgctl07 ran successfully!
> <<<execution_status>>>
> initiation_status="ok"
> duration=20 termination_type=exited termination_id=0 corefile=no
> cutime=1995 cstime=3
> <<<test_end>>>
> <<<test_start>>>
> tag=msgctl08 stime=1372174954
> cmdline="msgctl08"
> contacts=""
> analysis=exit
> <<<test_output>>>
> msgctl08    0  TWARN  :  Verify error in child 0, *buf = 28, val = 27, size = 8
> msgctl08    1  TFAIL  :  in child 0 read # = 73,key =  127
> msgctl08    0  TWARN  :  Verify error in child 3, *buf = ffffff8a, val
> = ffffff89, size = 52
> msgctl08    1  TFAIL  :  in child 3 read # = 157,key =  189
> msgctl08    0  TWARN  :  Verify error in child 2, *buf = ffffff87, val
> = ffffff86, size = 71
> msgctl08    1  TFAIL  :  in child 2 read # = 15954,key =  3e86
> msgctl08    0  TWARN  :  Verify error in child 12, *buf = ffffffa9,
> val = ffffffa8, size = 22
> msgctl08    1  TFAIL  :  in child 12 read # = 12904,key =  32a8
> msgctl08    0  TWARN  :  Verify error in child 13, *buf = 36, val =
> 35, size = 27
> msgctl08    1  TFAIL  :  in child 13 read # = 10442,key =  2935
> msgctl08    0  TWARN  :  Verify error in child 10, *buf = ffffff86,
> val = ffffff85, size = 63
> msgctl08    1  TFAIL  :  in child 10 read # = 19713,key =  4d85
> msgctl08    0  TWARN  :  Verify error in child 4, *buf = 4c, val = 4b, size = 83
> msgctl08    1  TFAIL  :  in child 4 read # = 23082,key =  5a4b
> msgctl08    0  TWARN  :  Verify error in child 15, *buf = 61, val =
> 60, size = 94
> msgctl08    1  TFAIL  :  in child 15 read # = 23554,key =  5c60
> msgctl08    0  TWARN  :  Verify error in child 11, *buf = 3b, val =
> 3a, size = 22
> msgctl08    1  TFAIL  :  in child 11 read # = 26468,key =  683a
> msgctl08    0  TWARN  :  Verify error in child 5, *buf = ffffffb5, val
> = ffffffb4, size = 41
> msgctl08    1  TFAIL  :  in child 5 read # = 31867,key =  7cb4
> msgctl08    0  TWARN  :  Verify error in child 1, *buf = 7d, val = 7c, size = 59
> msgctl08    1  TFAIL  :  in child 1 read # = 41063,key =  a07c
> msgctl08    0  TWARN  :  Verify error in child 7, *buf = fffffff2, val
> = fffffff1, size = 83
> msgctl08    1  TFAIL  :  in child 7 read # = 38476,key =  96f1
> msgctl08    0  TWARN  :  Verify error in child 9, *buf = ffffff8b, val
> = ffffff8a, size = 40
> msgctl08    1  TFAIL  :  in child 9 read # = 90438,key =  1618a
> msgctl08    0  TWARN  :  Verify error in child 8, *buf = ffffffcd, val
> = ffffffcc, size = 38
> msgctl08    1  TFAIL  :  in child 8 read # = 88712,key =  15acc
> msgctl08    0  TWARN  :  Verify error in child 6, *buf = 6, val = 5, size = 1
> msgctl08    1  TFAIL  :  in child 6 read # = 83297,key =  14605
> ***** STOPPED *****
> 
> See "ltp-full-20130503.git/testcases/kernel/syscalls/ipc/msgctl/msgctl08.c" [1].
> 
> NOTE: Debian/Ubuntu users with dash as default shell require the patch from [2].
> 
> - Sedat -
> 
> P.S.: Unfortunately, fakeroot DEBUG doc file is outdated.
> 
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/ipc/msgctl/msgctl08.c
> [2] https://github.com/linux-test-project/ltp/commit/b88fa5b6ec5a29834a0e52df7b22b9bb47fe0379


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

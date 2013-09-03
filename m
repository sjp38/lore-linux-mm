Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 3AE246B0033
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 06:17:00 -0400 (EDT)
Received: by mail-bk0-f52.google.com with SMTP id e11so1997322bkh.39
        for <linux-mm@kvack.org>; Tue, 03 Sep 2013 03:16:58 -0700 (PDT)
Message-ID: <5225B716.3090708@colorfullife.com>
Date: Tue, 03 Sep 2013 12:16:54 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: ipc-msg broken again on 3.11-rc7?
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com> <CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com> <52205597.3090609@synopsys.com> <CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com> <C2D7FE5348E1B147BCA15975FBA230751411CB@IN01WEMBXA.internal.synopsys.com> <CALE5RAvaa4bb-9xAnBe07Yp2n+Nn4uGEgqpLrKMuOE8hhZv00Q@mail.gmail.com> <CAMJEocr1SgxQw0bEzB3Ti9bvRY74TE5y9e+PLUsAL1mJbK=-ew@mail.gmail.com> <CA+55aFy8tbBpac57fU4CN3jMDz46kCKT7+7GCpb18CscXuOnGA@mail.gmail.com> <C2D7FE5348E1B147BCA15975FBA230751413F4@IN01WEMBXA.internal.synopsys.com> <5224BCF6.2080401@colorfullife.com> <C2D7FE5348E1B147BCA15975FBA23075141642@IN01WEMBXA.internal.synopsys.com> <5225A466.2080303@colorfullife.com> <C2D7FE5348E1B147BCA15975FBA2307514165E@IN01WEMBXA.internal.synopsys.com> <5225AA8D.6080403@colorfullife.com> <C2D7FE5348E1B147BCA15975FBA2307514168F@IN01WEMBXA.internal.synopsys.com>
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA2307514168F@IN01WEMBXA.internal.synopsys.com>
Content-Type: multipart/mixed;
 boundary="------------030608050605010303060001"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave.bueso@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

This is a multi-part message in MIME format.
--------------030608050605010303060001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Vineet,

On 09/03/2013 11:51 AM, Vineet Gupta wrote:
> On 09/03/2013 02:53 PM, Manfred Spraul wrote:
>>
>> The access to msq->q_cbytes is not protected.
>>
>> Vineet, could you try to move the test for free space after ipc_lock?
>> I.e. the lock must not get dropped between testing for free space and
>> enqueueing the messages.
> Hmm, the code movement is not trivial. I broke even the simplest of cases (patch
> attached). This includes the additional change which Linus/Davidlohr had asked for.
The attached patch should work. Could you try it?

--
     Manfred

--------------030608050605010303060001
Content-Type: text/plain; charset=UTF-8;
 name="patch-ipcmsg-wip"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch-ipcmsg-wip"

diff --git a/ipc/msg.c b/ipc/msg.c
index 9f29d9e..b65fdf1 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -680,16 +680,18 @@ long do_msgsnd(int msqid, long mtype, void __user *mtext,
 		goto out_unlock1;
 	}
 
+	ipc_lock_object(&msq->q_perm);
+
 	for (;;) {
 		struct msg_sender s;
 
 		err = -EACCES;
 		if (ipcperms(ns, &msq->q_perm, S_IWUGO))
-			goto out_unlock1;
+			goto out_unlock0;
 
 		err = security_msg_queue_msgsnd(msq, msg, msgflg);
 		if (err)
-			goto out_unlock1;
+			goto out_unlock0;
 
 		if (msgsz + msq->q_cbytes <= msq->q_qbytes &&
 				1 + msq->q_qnum <= msq->q_qbytes) {
@@ -699,10 +701,9 @@ long do_msgsnd(int msqid, long mtype, void __user *mtext,
 		/* queue full, wait: */
 		if (msgflg & IPC_NOWAIT) {
 			err = -EAGAIN;
-			goto out_unlock1;
+			goto out_unlock0;
 		}
 
-		ipc_lock_object(&msq->q_perm);
 		ss_add(msq, &s);
 
 		if (!ipc_rcu_getref(msq)) {
@@ -730,10 +731,7 @@ long do_msgsnd(int msqid, long mtype, void __user *mtext,
 			goto out_unlock0;
 		}
 
-		ipc_unlock_object(&msq->q_perm);
 	}
-
-	ipc_lock_object(&msq->q_perm);
 	msq->q_lspid = task_tgid_vnr(current);
 	msq->q_stime = get_seconds();
 

--------------030608050605010303060001--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

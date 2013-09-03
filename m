Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 4484A6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 05:23:30 -0400 (EDT)
Received: by mail-bk0-f42.google.com with SMTP id my10so1988375bkb.15
        for <linux-mm@kvack.org>; Tue, 03 Sep 2013 02:23:28 -0700 (PDT)
Message-ID: <5225AA8D.6080403@colorfullife.com>
Date: Tue, 03 Sep 2013 11:23:25 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: ipc-msg broken again on 3.11-rc7?
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com> <CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com> <C2D7FE5348E1B147BCA15975FBA23075140FA3@IN01WEMBXA.internal.synopsys.com> <CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com> <52205597.3090609@synopsys.com> <CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com> <C2D7FE5348E1B147BCA15975FBA230751411CB@IN01WEMBXA.internal.synopsys.com> <CALE5RAvaa4bb-9xAnBe07Yp2n+Nn4uGEgqpLrKMuOE8hhZv00Q@mail.gmail.com> <CAMJEocr1SgxQw0bEzB3Ti9bvRY74TE5y9e+PLUsAL1mJbK=-ew@mail.gmail.com> <CA+55aFy8tbBpac57fU4CN3jMDz46kCKT7+7GCpb18CscXuOnGA@mail.gmail.com> <C2D7FE5348E1B147BCA15975FBA230751413F4@IN01WEMBXA.internal.synopsys.com> <5224BCF6.2080401@colorfullife.com> <C2D7FE5348E1B147BCA15975FBA23075141642@IN01WEMBXA.internal.synopsys.com> <5225A466.2080303@colorfullife.com> <C2D7FE5348E1B147BCA15975FBA2307514165E@IN01WEMBXA.internal.synopsys.com>
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA2307514165E@IN01WEMBXA.internal.synopsys.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave.bueso@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

On 09/03/2013 11:16 AM, Vineet Gupta wrote:
> On 09/03/2013 02:27 PM, Manfred Spraul wrote:
>> On 09/03/2013 10:44 AM, Vineet Gupta wrote:
>>>> b) Could you check that it is not just a performance regression?
>>>>        Does ./msgctl08 1000 16 hang, too?
>>> Nope that doesn't hang. The minimal configuration that hangs reliably is msgctl
>>> 50000 2
>>>
>>> With this config there are 3 processes.
>>> ...
>>>     555   554 root     S     1208  0.4   0  0.0 ./msgctl08 50000 2
>>>     554   551 root     S     1208  0.4   0  0.0 ./msgctl08 50000 2
>>>     551   496 root     S     1208  0.4   0  0.0 ./msgctl08 50000 2
>>> ...
>>>
>>> [ARCLinux]$ cat /proc/551/stack
>>> [<80aec3c6>] do_wait+0xa02/0xc94
>>> [<80aecad2>] SyS_wait4+0x52/0xa4
>>> [<80ae24fc>] ret_from_system_call+0x0/0x4
>>>
>>> [ARCLinux]$ cat /proc/555/stack
>>> [<80c2950e>] SyS_msgrcv+0x252/0x420
>>> [<80ae24fc>] ret_from_system_call+0x0/0x4
>>>
>>> [ARCLinux]$ cat /proc/554/stack
>>> [<80c28c82>] do_msgsnd+0x116/0x35c
>>> [<80ae24fc>] ret_from_system_call+0x0/0x4
>>>
>>> Is this a case of lost wakeup or some such. I'm running with some more diagnostics
>>> and will report soon ...
>> What is the output of ipcs -q? Is the queue full or empty when it hangs?
>> I.e. do we forget to wake up a receiver or forget to wake up a sender?
> / # ipcs -q
>
> ------ Message Queues --------
> key        msqid      owner      perms      used-bytes   messages
> 0x72d83160 163841     root       600        0            0
>
>
Ok, a sender is sleeping - even though there are no messages in the queue.
Perhaps it is the race that I mentioned in a previous mail:
>       for (;;) {
>                 struct msg_sender s;
>
>                 err = -EACCES;
>                 if (ipcperms(ns, &msq->q_perm, S_IWUGO))
>                         goto out_unlock1;
>
>                 err = security_msg_queue_msgsnd(msq, msg, msgflg);
>                 if (err)
>                         goto out_unlock1;
>
>                 if (msgsz + msq->q_cbytes <= msq->q_qbytes &&
>                                 1 + msq->q_qnum <= msq->q_qbytes) {
>                         break;
>                 }
>
[snip]
>         if (!pipelined_send(msq, msg)) {
>                 /* no one is waiting for this message, enqueue it */
>                 list_add_tail(&msg->m_list, &msq->q_messages);
>                 msq->q_cbytes += msgsz;
>                 msq->q_qnum++;
>                 atomic_add(msgsz, &ns->msg_bytes);

The access to msq->q_cbytes is not protected.

Vineet, could you try to move the test for free space after ipc_lock?
I.e. the lock must not get dropped between testing for free space and 
enqueueing the messages.

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

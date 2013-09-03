Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 7E0F06B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 03:16:50 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q57so4521648wes.12
        for <linux-mm@kvack.org>; Tue, 03 Sep 2013 00:16:48 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <5224BCF6.2080401@colorfullife.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
	<1372192414.1888.8.camel@buesod1.americas.hpqcorp.net>
	<CA+icZUXgOd=URJBH5MGAZKdvdkMpFt+5mRxtzuDzq_vFHpoc2A@mail.gmail.com>
	<1372202983.1888.22.camel@buesod1.americas.hpqcorp.net>
	<521DE5D7.4040305@synopsys.com>
	<CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA23075140FA3@IN01WEMBXA.internal.synopsys.com>
	<CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com>
	<52205597.3090609@synopsys.com>
	<CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA230751411CB@IN01WEMBXA.internal.synopsys.com>
	<CALE5RAvaa4bb-9xAnBe07Yp2n+Nn4uGEgqpLrKMuOE8hhZv00Q@mail.gmail.com>
	<CAMJEocr1SgxQw0bEzB3Ti9bvRY74TE5y9e+PLUsAL1mJbK=-ew@mail.gmail.com>
	<CA+55aFy8tbBpac57fU4CN3jMDz46kCKT7+7GCpb18CscXuOnGA@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA230751413F4@IN01WEMBXA.internal.synopsys.com>
	<5224BCF6.2080401@colorfullife.com>
Date: Tue, 3 Sep 2013 09:16:48 +0200
Message-ID: <CA+icZUVc6fhW+TTB56x68LooS8DqhA8n3CQzgKkXQmbyH+ryUQ@mail.gmail.com>
Subject: Re: ipc-msg broken again on 3.11-rc7?
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave.bueso@gmail.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

On Mon, Sep 2, 2013 at 6:29 PM, Manfred Spraul <manfred@colorfullife.com> wrote:
> Hi,
>
> [forgot to cc everyone, thus I'll summarize some mails...]
>
> On 09/02/2013 06:58 AM, Vineet Gupta wrote:
>>
>> On 08/31/2013 11:20 PM, Linus Torvalds wrote:
>>>
>>> Vineet, actual patch for what Davidlohr suggests attached. Can you try
>>> it?
>>>
>>>               Linus
>>
>> Apologies for late in getting back to this - I was away from my computer
>> for a bit.
>>
>> Unfortunately, with a quick test, this patch doesn't help.
>> FWIW, this is latest mainline (.config attached).
>>
>> Let me know what diagnostics I can add to help with this.
>
>
> msgctl08 is a bulk message send/receive test. I had to look at it once
> before, then it was a broken hardware:
> https://lkml.org/lkml/2008/6/12/365
> This can be ruled out, because it works with 3.10.
>
> msgctl08 uses pairs of threads: one thread does msgsnd(), the other one
> msgrcv().
> There is no synchronization, i.e. the msgsnd() can race ahead until the
> kernel buffer is full and then a block with msgrcv() follows or it could be
> pairs of alternating msgsnd()/msgrcv() operations.
> No special features are used: each pair of threads has it's own message
> queues, all messages have type=1.
>
> Vineet ran strace - and just before the signal from killing msgctl08, there
> are only msgsnd()/msgrcv() calls.
> Vineet:
> a) could you run strace tomorrow again, with '-ttt' as an additional option?
> I don't see where exactly it hangs.
> b) Could you check that it is not just a performance regression?
>     Does ./msgctl08 1000 16 hang, too?
>
> In ipc/msg.c, I haven't seen any obvious reason why it should hang.
> The only race I spotted so far is this one:
>>
>>       for (;;) {
>>                 struct msg_sender s;
>>
>>                 err = -EACCES;
>>                 if (ipcperms(ns, &msq->q_perm, S_IWUGO))
>>                         goto out_unlock1;
>>
>>
>>                 err = security_msg_queue_msgsnd(msq, msg, msgflg);
>>                 if (err)
>>                         goto out_unlock1;
>>
>>                 if (msgsz + msq->q_cbytes <= msq->q_qbytes &&
>>                                 1 + msq->q_qnum <= msq->q_qbytes) {
>>                         break;
>>                 }
>>
> [snip]
>>
>>         if (!pipelined_send(msq, msg)) {
>>                 /* no one is waiting for this message, enqueue it */
>>                 list_add_tail(&msg->m_list, &msq->q_messages);
>>                 msq->q_cbytes += msgsz;
>>                 msq->q_qnum++;
>>                 atomic_add(msgsz, &ns->msg_bytes);
>
>
> The access to msq->q_cbytes is not protected. Thus two parallel msgsnd()
> calls could succeed, even if both together brings the queue length above the
> limit.
> But it can't explain why 3.11-rc7 hangs: As explained above, msgctl08 uses
> one queue for each thread pair.
>

Just FYI:

Linux Testing Project (LTP) will do a new release in the 1st September week.
Some IPC test-suites were reworked.
Manfred can you look at them ("...msgctl08 uses one queue for each
thread pair.").
( Might be worth to throw some words at the LTP mailing-list (that
test-case is not ideal, etc.)? )

- Sedat -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

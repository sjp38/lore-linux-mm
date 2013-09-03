Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id AA2116B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 05:52:04 -0400 (EDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: ipc-msg broken again on 3.11-rc7?
Date: Tue, 3 Sep 2013 09:51:58 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA2307514168F@IN01WEMBXA.internal.synopsys.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
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
 <C2D7FE5348E1B147BCA15975FBA23075141642@IN01WEMBXA.internal.synopsys.com>
 <5225A466.2080303@colorfullife.com>
 <C2D7FE5348E1B147BCA15975FBA2307514165E@IN01WEMBXA.internal.synopsys.com>
 <5225AA8D.6080403@colorfullife.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_C2D7FE5348E1B147BCA15975FBA2307514168FIN01WEMBXAinterna_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave.bueso@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Jonathan
 Gonzalez <jgonzalez@linets.cl>

--_002_C2D7FE5348E1B147BCA15975FBA2307514168FIN01WEMBXAinterna_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On 09/03/2013 02:53 PM, Manfred Spraul wrote:=0A=
> On 09/03/2013 11:16 AM, Vineet Gupta wrote:=0A=
>> On 09/03/2013 02:27 PM, Manfred Spraul wrote:=0A=
>>> On 09/03/2013 10:44 AM, Vineet Gupta wrote:=0A=
>>>>> b) Could you check that it is not just a performance regression?=0A=
>>>>>        Does ./msgctl08 1000 16 hang, too?=0A=
>>>> Nope that doesn't hang. The minimal configuration that hangs reliably =
is msgctl=0A=
>>>> 50000 2=0A=
>>>>=0A=
>>>> With this config there are 3 processes.=0A=
>>>> ...=0A=
>>>>     555   554 root     S     1208  0.4   0  0.0 ./msgctl08 50000 2=0A=
>>>>     554   551 root     S     1208  0.4   0  0.0 ./msgctl08 50000 2=0A=
>>>>     551   496 root     S     1208  0.4   0  0.0 ./msgctl08 50000 2=0A=
>>>> ...=0A=
>>>>=0A=
>>>> [ARCLinux]$ cat /proc/551/stack=0A=
>>>> [<80aec3c6>] do_wait+0xa02/0xc94=0A=
>>>> [<80aecad2>] SyS_wait4+0x52/0xa4=0A=
>>>> [<80ae24fc>] ret_from_system_call+0x0/0x4=0A=
>>>>=0A=
>>>> [ARCLinux]$ cat /proc/555/stack=0A=
>>>> [<80c2950e>] SyS_msgrcv+0x252/0x420=0A=
>>>> [<80ae24fc>] ret_from_system_call+0x0/0x4=0A=
>>>>=0A=
>>>> [ARCLinux]$ cat /proc/554/stack=0A=
>>>> [<80c28c82>] do_msgsnd+0x116/0x35c=0A=
>>>> [<80ae24fc>] ret_from_system_call+0x0/0x4=0A=
>>>>=0A=
>>>> Is this a case of lost wakeup or some such. I'm running with some more=
 diagnostics=0A=
>>>> and will report soon ...=0A=
>>> What is the output of ipcs -q? Is the queue full or empty when it hangs=
?=0A=
>>> I.e. do we forget to wake up a receiver or forget to wake up a sender?=
=0A=
>> / # ipcs -q=0A=
>>=0A=
>> ------ Message Queues --------=0A=
>> key        msqid      owner      perms      used-bytes   messages=0A=
>> 0x72d83160 163841     root       600        0            0=0A=
>>=0A=
>>=0A=
> Ok, a sender is sleeping - even though there are no messages in the queue=
.=0A=
> Perhaps it is the race that I mentioned in a previous mail:=0A=
>>       for (;;) {=0A=
>>                 struct msg_sender s;=0A=
>>=0A=
>>                 err =3D -EACCES;=0A=
>>                 if (ipcperms(ns, &msq->q_perm, S_IWUGO))=0A=
>>                         goto out_unlock1;=0A=
>>=0A=
>>                 err =3D security_msg_queue_msgsnd(msq, msg, msgflg);=0A=
>>                 if (err)=0A=
>>                         goto out_unlock1;=0A=
>>=0A=
>>                 if (msgsz + msq->q_cbytes <=3D msq->q_qbytes &&=0A=
>>                                 1 + msq->q_qnum <=3D msq->q_qbytes) {=0A=
>>                         break;=0A=
>>                 }=0A=
>>=0A=
> [snip]=0A=
>>         if (!pipelined_send(msq, msg)) {=0A=
>>                 /* no one is waiting for this message, enqueue it */=0A=
>>                 list_add_tail(&msg->m_list, &msq->q_messages);=0A=
>>                 msq->q_cbytes +=3D msgsz;=0A=
>>                 msq->q_qnum++;=0A=
>>                 atomic_add(msgsz, &ns->msg_bytes);=0A=
> The access to msq->q_cbytes is not protected.=0A=
>=0A=
> Vineet, could you try to move the test for free space after ipc_lock?=0A=
> I.e. the lock must not get dropped between testing for free space and =0A=
> enqueueing the messages.=0A=
=0A=
Hmm, the code movement is not trivial. I broke even the simplest of cases (=
patch=0A=
attached). This includes the additional change which Linus/Davidlohr had as=
ked for.=0A=
=0A=
-Vineet=0A=
=0A=

--_002_C2D7FE5348E1B147BCA15975FBA2307514168FIN01WEMBXAinterna_
Content-Type: text/plain; name="patch-ipc-2"
Content-Description: patch-ipc-2
Content-Disposition: attachment; filename="patch-ipc-2"; size=1075;
	creation-date="Tue, 03 Sep 2013 09:51:56 GMT";
	modification-date="Tue, 03 Sep 2013 09:51:56 GMT"
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL2lwYy9tc2cuYyBiL2lwYy9tc2cuYwppbmRleCA5ZjI5ZDllLi5hNTEyODI5
IDEwMDY0NAotLS0gYS9pcGMvbXNnLmMKKysrIGIvaXBjL21zZy5jCkBAIC02ODcsMTQgKzY4Nyw2
IEBAIGxvbmcgZG9fbXNnc25kKGludCBtc3FpZCwgbG9uZyBtdHlwZSwgdm9pZCBfX3VzZXIgKm10
ZXh0LAogCQlpZiAoaXBjcGVybXMobnMsICZtc3EtPnFfcGVybSwgU19JV1VHTykpCiAJCQlnb3Rv
IG91dF91bmxvY2sxOwogCi0JCWVyciA9IHNlY3VyaXR5X21zZ19xdWV1ZV9tc2dzbmQobXNxLCBt
c2csIG1zZ2ZsZyk7Ci0JCWlmIChlcnIpCi0JCQlnb3RvIG91dF91bmxvY2sxOwotCi0JCWlmICht
c2dzeiArIG1zcS0+cV9jYnl0ZXMgPD0gbXNxLT5xX3FieXRlcyAmJgotCQkJCTEgKyBtc3EtPnFf
cW51bSA8PSBtc3EtPnFfcWJ5dGVzKSB7Ci0JCQlicmVhazsKLQkJfQogCiAJCS8qIHF1ZXVlIGZ1
bGwsIHdhaXQ6ICovCiAJCWlmIChtc2dmbGcgJiBJUENfTk9XQUlUKSB7CkBAIC03MDMsNiArNjk1
LDEwIEBAIGxvbmcgZG9fbXNnc25kKGludCBtc3FpZCwgbG9uZyBtdHlwZSwgdm9pZCBfX3VzZXIg
Km10ZXh0LAogCQl9CiAKIAkJaXBjX2xvY2tfb2JqZWN0KCZtc3EtPnFfcGVybSk7CisJCWVyciA9
IHNlY3VyaXR5X21zZ19xdWV1ZV9tc2dzbmQobXNxLCBtc2csIG1zZ2ZsZyk7CisJCWlmIChlcnIp
CisJCQlnb3RvIG91dF91bmxvY2swOworCiAJCXNzX2FkZChtc3EsICZzKTsKIAogCQlpZiAoIWlw
Y19yY3VfZ2V0cmVmKG1zcSkpIHsKQEAgLTczNCw2ICs3MzAsMTIgQEAgbG9uZyBkb19tc2dzbmQo
aW50IG1zcWlkLCBsb25nIG10eXBlLCB2b2lkIF9fdXNlciAqbXRleHQsCiAJfQogCiAJaXBjX2xv
Y2tfb2JqZWN0KCZtc3EtPnFfcGVybSk7CisKKwlpZiAoIShtc2dzeiArIG1zcS0+cV9jYnl0ZXMg
PD0gbXNxLT5xX3FieXRlcyAmJgorCQkJMSArIG1zcS0+cV9xbnVtIDw9IG1zcS0+cV9xYnl0ZXMp
KSB7CisJCWdvdG8gb3V0X3VubG9jazA7CisJfQorCiAJbXNxLT5xX2xzcGlkID0gdGFza190Z2lk
X3ZucihjdXJyZW50KTsKIAltc3EtPnFfc3RpbWUgPSBnZXRfc2Vjb25kcygpOwogCg==

--_002_C2D7FE5348E1B147BCA15975FBA2307514168FIN01WEMBXAinterna_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2816B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 18:03:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g32so32855887qta.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 15:03:21 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id u57si25637716qtb.40.2016.10.19.15.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 15:03:20 -0700 (PDT)
Received: by mail-qk0-x22f.google.com with SMTP id n189so62797800qke.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 15:03:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1610191329500.29288@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1610191311010.24555@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1610191329500.29288@file01.intranet.prod.int.rdu2.redhat.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Thu, 20 Oct 2016 01:02:59 +0300
Message-ID: <CAJwJo6Z8ZWPqNfT6t-i8GW1MKxQrKDUagQqnZ+0+697=MyVeGg@mail.gmail.com>
Subject: Re: x32 is broken in 4.9-rc1 due to "x86/signal: Add
 SA_{X32,IA32}_ABI sa_flags"
Content-Type: multipart/mixed; boundary=047d7b604d2e204b13053f3efaa9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, open list <linux-kernel@vger.kernel.org>

--047d7b604d2e204b13053f3efaa9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

2016-10-19 20:33 GMT+03:00 Mikulas Patocka <mpatocka@redhat.com>:
>
>
> On Wed, 19 Oct 2016, Mikulas Patocka wrote:
>
>> Hi
>>
>> In the kernel 4.9-rc1, the x32 support is seriously broken, a x32 proces=
s
>> is killed with SIGKILL after returning from any signal handler.
>
> I should have said they are killed with SIGSEGV, not SIGKILL.
>
>> I use Debian sid x64-64 distribution with x32 architecture added from
>> debian-ports.
>>
>> I bisected the bug and found out that it is caused by the patch
>> 6846351052e685c2d1428e80ead2d7ca3d7ed913 ("x86/signal: Add
>> SA_{X32,IA32}_ABI sa_flags").
>>
>> example (strace of a process after receiving the SIGWINCH signal):
>>
>> epoll_wait(10, 0xef6890, 32, -1)        =3D -1 EINTR (Interrupted system=
 call)
>> --- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_USER, si_pid=3D1772, si_=
uid=3D0} ---
>> poll([{fd=3D4, events=3DPOLLOUT}], 1, 0)    =3D 1 ([{fd=3D4, revents=3DP=
OLLOUT}])
>> write(4, "\0", 1)                       =3D 1
>> rt_sigreturn({mask=3D[INT QUIT ILL TRAP BUS KILL SEGV USR2 PIPE ALRM STK=
FLT TSTP TTOU URG XCPU XFSZ VTALRM IO PWR SYS RTMIN]}) =3D 0
>> --- SIGSEGV {si_signo=3DSIGSEGV, si_code=3DSI_KERNEL, si_addr=3DNULL} --=
-
>> +++ killed by SIGSEGV +++
>> Neopr=C3=A1vn=C3=ACn=C3=BD p=C3=B8=C3=ADstup do pam=C3=ACti (SIGSEGV)
>>
>> Mikulas
>
> BTW. when I take core dump of the killed x32 process, it shows:
>
> ELF Header:
>   Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
>   Class:                             ELF32
>   Data:                              2's complement, little endian
>   Version:                           1 (current)
>   OS/ABI:                            UNIX - System V
>   ABI Version:                       0
>   Type:                              CORE (Core file)
>   Machine:                           Intel 80386
>                                 ^^^^^^^^^^^^^^^^^^^
>
> So, the kernel somehow thinks that it is i386 process, not x32 process. A
> core dump of a real x32 process shows "Class: ELF32, Machine: Advanced
> Micro Devices X86-64".

Hi Mikulas,

could you give attached patch a shot?
In about 10 hours I'll be at work and will have debian-x32 install,
but for now, I can't test it.
Thanks again on catching that.

--=20
             Dmitry

--047d7b604d2e204b13053f3efaa9
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-x86-signal-set-SA_X32_ABI-flag-for-x32-programs.patch"
Content-Disposition: attachment;
	filename="0001-x86-signal-set-SA_X32_ABI-flag-for-x32-programs.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iuhgsn1x0

RnJvbSBhNTQ2ZjhkYTFkMTI2NzZmZTc5Yzc0NmQ4NTllYjFlMTdhYTRjMzMxIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBEbWl0cnkgU2Fmb25vdiA8MHg3ZjQ1NGM0NkBnbWFpbC5jb20+
CkRhdGU6IFRodSwgMjAgT2N0IDIwMTYgMDA6NTM6MDggKzAzMDAKU3ViamVjdDogW1BBVENIXSB4
ODYvc2lnbmFsOiBzZXQgU0FfWDMyX0FCSSBmbGFnIGZvciB4MzIgcHJvZ3JhbXMKCkZvciB4MzIg
cHJvZ3JhbXMgY3MgcmVnaXN0ZXIgaXMgX19VU0VSX0NTLCBzbyBpdCByZXR1cm5zIGhlcmUKdW5j
b25kaXRpb25hbGx5IC0gcmVtb3ZlIHRoaXMgY2hlY2sgY29tcGxldGVseSBoZXJlLgoKRml4ZXM6
IGNvbW1pdCA2ODQ2MzUxMDUyZTYgKCJ4ODYvc2lnbmFsOiBBZGQgU0Ffe1gzMixJQTMyfV9BQkkg
c2FfZmxhZ3MiKQoKUmVwb3J0ZWQtYnk6IE1pa3VsYXMgUGF0b2NrYSA8bXBhdG9ja2FAcmVkaGF0
LmNvbT4KU2lnbmVkLW9mZi1ieTogRG1pdHJ5IFNhZm9ub3YgPDB4N2Y0NTRjNDZAZ21haWwuY29t
PgotLS0KIGFyY2gveDg2L2tlcm5lbC9zaWduYWxfY29tcGF0LmMgfCAzIC0tLQogMSBmaWxlIGNo
YW5nZWQsIDMgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvYXJjaC94ODYva2VybmVsL3NpZ25h
bF9jb21wYXQuYyBiL2FyY2gveDg2L2tlcm5lbC9zaWduYWxfY29tcGF0LmMKaW5kZXggNDBkZjMz
NzUzYmFlLi5lYzFmNzU2ZjlkYzkgMTAwNjQ0Ci0tLSBhL2FyY2gveDg2L2tlcm5lbC9zaWduYWxf
Y29tcGF0LmMKKysrIGIvYXJjaC94ODYva2VybmVsL3NpZ25hbF9jb21wYXQuYwpAQCAtMTA1LDkg
KzEwNSw2IEBAIHZvaWQgc2lnYWN0aW9uX2NvbXBhdF9hYmkoc3RydWN0IGtfc2lnYWN0aW9uICph
Y3QsIHN0cnVjdCBrX3NpZ2FjdGlvbiAqb2FjdCkKIAkvKiBEb24ndCBsZXQgZmxhZ3MgdG8gYmUg
c2V0IGZyb20gdXNlcnNwYWNlICovCiAJYWN0LT5zYS5zYV9mbGFncyAmPSB+KFNBX0lBMzJfQUJJ
IHwgU0FfWDMyX0FCSSk7CiAKLQlpZiAodXNlcl82NGJpdF9tb2RlKGN1cnJlbnRfcHRfcmVncygp
KSkKLQkJcmV0dXJuOwotCiAJaWYgKGluX2lhMzJfc3lzY2FsbCgpKQogCQlhY3QtPnNhLnNhX2Zs
YWdzIHw9IFNBX0lBMzJfQUJJOwogCWlmIChpbl94MzJfc3lzY2FsbCgpKQotLSAKMi4xMC4wCgo=
--047d7b604d2e204b13053f3efaa9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

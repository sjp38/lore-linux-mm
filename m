Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A25386B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 09:19:47 -0500 (EST)
Received: by bkbzt12 with SMTP id zt12so3367189bkb.14
        for <linux-mm@kvack.org>; Sun, 04 Dec 2011 06:19:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111121104313.63c7f796@cyeoh-System-Product-Name>
References: <20110719003537.16b189ae@lilo>
	<CAMuHMdWAhn7M8o0qY4pz3W1tyyKEcNY_YQL_6JuAPCcjL5vS1A@mail.gmail.com>
	<20111121104313.63c7f796@cyeoh-System-Product-Name>
Date: Sun, 4 Dec 2011 15:19:44 +0100
Message-ID: <CAMuHMdXfWoHx4GA3L8T6-6PFw9fdCVbooayR3La2Woe-0V2koA@mail.gmail.com>
Subject: Re: Cross Memory Attach v3
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, linux-arch@vger.kernel.org, Linux/m68k <linux-m68k@vger.kernel.org>, Debian m68k <debian-68k@lists.debian.org>

Hi Christopher,

On Mon, Nov 21, 2011 at 01:13, Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> On Sun, 20 Nov 2011 11:16:17 +0100
> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>> On Mon, Jul 18, 2011 at 17:05, Christopher Yeoh <cyeoh@au1.ibm.com>
>> wrote:
>> > For arch maintainers there are some simple tests to be able to
>> > quickly verify that the syscalls are working correctly here:
>>
>> I'm wiring up these new syscalls on m68k.
>>
>> On m68k (ARAnyM), the first and third test succeed. The second one
>> fails, though:
>>
>> # Setting up target with num iovecs 10, test buffer size 100000
>> Target process is setup
>> Run the following to test:
>> ./t_process_vm_readv_iovec 1574 10 0x800030b0 89 0x80003110 38302
>> 0x8000c6b8 22423 0x80011e58 18864 0x80016810 583 0x80016a60 8054
>> 0x800189e0 3417 0x80019740 368 0x800198b8 897 0x80019c40 7003
>>
>> and in the other window:
>>
>> # ./t_process_vm_readv_iovec 1574 10 0x800030b0 89 0x80003110 38302
>> 0x8000c6b8 22423 0x80011e58 18864 0x80016810 583 0x80016a60 8054
>> 0x800189e0 3417 0x80019740 368 0x800198b8 897 0x80019c40 7003
>> copy_from_process failed: Invalid argument
>
> That should say process_vm_readv instead of copy_from_process. The
> error message is fixed in the just updated test.
>
>> error code: 29
>> #
>>
>> Any suggestions?
>
> Given that the first and third tests succeed, I think the problem is
> with the iovec parameters. The -EINVAL is most likely coming from
> rw_copy_check_uvector. Any chance that something bad is
> happening to lvec/liovcnt or rvec/riovcnt in the wireup?
>
> The iovecs are checked in process_vm_rw before the core of the
> process_vm_readv/writev code is called so should be easy to confirm if
> this is the problem.
>
> The other couple of places where it could possibly come from is that
> for some reason the flags parameter ends up being non zero or when
> looking up the task the mm is NULL. But given that the first and second
> tests succeed I think its unlikely that either of these is the cause.

It turned out the flags parameter was non-zero, due to syscall() only suppo=
rting
up to 5 parameters in the glibc I was using for testing.

I checked the eglibc sources (2.11.1-0ubuntu7.8), and it's still not
fixed there,
although I could find a fix for a similar issue in klibc
(http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D334917).

When forcing flags to zero, it works ;-)
So sorry for bothering you.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

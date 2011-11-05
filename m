Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 017CD6B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 22:21:17 -0400 (EDT)
Received: by vcbfo13 with SMTP id fo13so106162vcb.14
        for <linux-mm@kvack.org>; Fri, 04 Nov 2011 19:21:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6389467.vmEs7mxtWt@pawels>
References: <20111031171441.GD3466@redhat.com>
	<alpine.LSU.2.00.1111032318290.2058@sister.anvils>
	<CAPQyPG4DNofTw=rqJXPTbo3w4xGMdPF3SYt3qyQCWXYsDLa08A@mail.gmail.com>
	<6389467.vmEs7mxtWt@pawels>
Date: Sat, 5 Nov 2011 10:21:15 +0800
Message-ID: <CAPQyPG5FUsibQo0B_VHBSkDKJWc7QqZ3NLTTSwZfAKqSvjLO5A@mail.gmail.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pawel Sikora <pluto@agmk.net>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Nov 4, 2011 at 11:59 PM, Pawel Sikora <pluto@agmk.net> wrote:
> On Friday 04 of November 2011 22:34:54 Nai Xia wrote:
>> On Fri, Nov 4, 2011 at 3:31 PM, Hugh Dickins <hughd@google.com> wrote:
>> > On Mon, 31 Oct 2011, Andrea Arcangeli wrote:
>> >
>> >> migrate was doing a rmap_walk with speculative lock-less access on
>> >> pagetables. That could lead it to not serialize properly against
>> >> mremap PT locks. But a second problem remains in the order of vmas in
>> >> the same_anon_vma list used by the rmap_walk.
>> >
>> > I do think that Nai Xia deserves special credit for thinking deeper
>> > into this than the rest of us (before you came back): something like
>> >
>> > Issue-conceived-by: Nai Xia <nai.xia@gmail.com>
>>
>> Thanks! ;-)
>
> hi all,
>
> i'm still testing anon_vma_order_tail() patch. 10 days of heavy processin=
g
> and machine is still stable but i've recorded some interesting thing:
>
> $ uname -a
> Linux hal 3.0.8-vs2.3.1-dirty #6 SMP Tue Oct 25 10:07:50 CEST 2011 x86_64=
 AMD_Opteron(tm)_Processor_6128 PLD Linux
> $ uptime
> =C2=A016:47:44 up 10 days, =C2=A04:21, =C2=A05 users, =C2=A0load average:=
 19.55, 19.15, 18.76
> $ ps aux|grep migration
> root =C2=A0 =C2=A0 =C2=A0 =C2=A0 6 =C2=A00.0 =C2=A00.0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 =C2=
=A0 0:00 [migration/0]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A0 8 68.0 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 9974:01 [=
migration/1]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A013 35.4 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 5202:15 [=
migration/2]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A017 71.4 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 10479:10 =
[migration/3]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A021 70.7 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 10370:14 =
[migration/4]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A025 66.1 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 9698:11 [=
migration/5]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A029 70.1 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 10283:22 =
[migration/6]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A033 62.6 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 9190:28 [=
migration/7]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A037 =C2=A00.0 =C2=A00.0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 =C2=
=A0 0:00 [migration/8]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A041 97.7 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 14338:30 =
[migration/9]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A045 29.2 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 4290:00 [=
migration/10]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A049 68.7 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 10081:38 =
[migration/11]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A053 98.7 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 14477:25 =
[migration/12]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A057 70.0 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 10272:57 =
[migration/13]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A061 69.7 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 10232:29 =
[migration/14]
> root =C2=A0 =C2=A0 =C2=A0 =C2=A065 70.9 =C2=A00.0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 0 ? =C2=A0 =C2=A0 =C2=A0 =C2=A0S =C2=A0 =C2=A0Oct25 10403:09 =
[migration/15]
>
> wow, 71..241 hours in migration processes after 10 days of uptime?
> machine has 2 opteron nodes with 32GB ram paired with each processor.
> i suppose that it spends a lot of time on migration (processes + memory p=
ages).

Hi Pawe=C5=82, it seems to me an issue related to load balancing but might
not directly
related to this bug or even not related to abnormal page migration.
Can this be a scheduler & interrupts issue?

But oh, well, actually I never ever had touch a 16-core machine
and do heavy processing. So I cannot tell if this result is normal or not.

Maybe you should ask for a broader range of people?

BR,
Nai

>
> BR,
> Pawe=C5=82.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

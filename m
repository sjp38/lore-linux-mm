Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id ABB1C6B006E
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 11:59:38 -0400 (EDT)
From: Pawel Sikora <pluto@agmk.net>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of vma_merge succeeding in copy_vma
Date: Fri, 04 Nov 2011 16:59:26 +0100
Message-ID: <6389467.vmEs7mxtWt@pawels>
In-Reply-To: <CAPQyPG4DNofTw=rqJXPTbo3w4xGMdPF3SYt3qyQCWXYsDLa08A@mail.gmail.com>
References: <20111031171441.GD3466@redhat.com> <alpine.LSU.2.00.1111032318290.2058@sister.anvils> <CAPQyPG4DNofTw=rqJXPTbo3w4xGMdPF3SYt3qyQCWXYsDLa08A@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Friday 04 of November 2011 22:34:54 Nai Xia wrote:
> On Fri, Nov 4, 2011 at 3:31 PM, Hugh Dickins <hughd@google.com> wrote=
:
> > On Mon, 31 Oct 2011, Andrea Arcangeli wrote:
> >
> >> migrate was doing a rmap_walk with speculative lock-less access on=

> >> pagetables. That could lead it to not serialize properly against
> >> mremap PT locks. But a second problem remains in the order of vmas=
 in
> >> the same_anon_vma list used by the rmap_walk.
> >
> > I do think that Nai Xia deserves special credit for thinking deeper=

> > into this than the rest of us (before you came back): something lik=
e
> >
> > Issue-conceived-by: Nai Xia <nai.xia@gmail.com>
>=20
> Thanks! ;-)

hi all,

i'm still testing anon_vma_order_tail() patch. 10 days of heavy process=
ing
and machine is still stable but i've recorded some interesting thing:

$ uname -a
Linux hal 3.0.8-vs2.3.1-dirty #6 SMP Tue Oct 25 10:07:50 CEST 2011 x86_=
64 AMD_Opteron(tm)_Processor_6128 PLD Linux
$ uptime
 16:47:44 up 10 days,  4:21,  5 users,  load average: 19.55, 19.15, 18.=
76
$ ps aux|grep migration
root         6  0.0  0.0      0     0 ?        S    Oct25   0:00 [migra=
tion/0]
root         8 68.0  0.0      0     0 ?        S    Oct25 9974:01 [migr=
ation/1]
root        13 35.4  0.0      0     0 ?        S    Oct25 5202:15 [migr=
ation/2]
root        17 71.4  0.0      0     0 ?        S    Oct25 10479:10 [mig=
ration/3]
root        21 70.7  0.0      0     0 ?        S    Oct25 10370:14 [mig=
ration/4]
root        25 66.1  0.0      0     0 ?        S    Oct25 9698:11 [migr=
ation/5]
root        29 70.1  0.0      0     0 ?        S    Oct25 10283:22 [mig=
ration/6]
root        33 62.6  0.0      0     0 ?        S    Oct25 9190:28 [migr=
ation/7]
root        37  0.0  0.0      0     0 ?        S    Oct25   0:00 [migra=
tion/8]
root        41 97.7  0.0      0     0 ?        S    Oct25 14338:30 [mig=
ration/9]
root        45 29.2  0.0      0     0 ?        S    Oct25 4290:00 [migr=
ation/10]
root        49 68.7  0.0      0     0 ?        S    Oct25 10081:38 [mig=
ration/11]
root        53 98.7  0.0      0     0 ?        S    Oct25 14477:25 [mig=
ration/12]
root        57 70.0  0.0      0     0 ?        S    Oct25 10272:57 [mig=
ration/13]
root        61 69.7  0.0      0     0 ?        S    Oct25 10232:29 [mig=
ration/14]
root        65 70.9  0.0      0     0 ?        S    Oct25 10403:09 [mig=
ration/15]

wow, 71..241 hours in migration processes after 10 days of uptime?
machine has 2 opteron nodes with 32GB ram paired with each processor.
i suppose that it spends a lot of time on migration (processes + memory=
 pages).

BR,
Pawe=C5=82.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

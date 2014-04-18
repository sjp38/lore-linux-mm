Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 24E7A6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:29:37 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id wp18so1901352obc.8
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:29:36 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id sm4si23453099obb.40.2014.04.18.09.29.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 09:29:36 -0700 (PDT)
Message-ID: <1397838572.19331.1.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2] ipc,shm: disable shmmax and shmall by default
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 18 Apr 2014 09:29:32 -0700
In-Reply-To: <CAKgNAkh5s+U4hYhpCwMcFpKmxen9ztd8aAPoyGQOWyadTMYfOw@mail.gmail.com>
References: <1397272942.2686.4.camel@buesod1.americas.hpqcorp.net>
	 <CAHO5Pa3BOgJGCm7NvE4xbm3O1WbRLRBS0pgvErPudypP_iiZ3g@mail.gmail.com>
	 <534FFFC2.6050601@colorfullife.com>
	 <CAKgNAkjCenvWr9A69-=j-55nyW1EM1Fy+=rSDWSxXvq5qFtGTw@mail.gmail.com>
	 <1397773919.2556.22.camel@buesod1.americas.hpqcorp.net>
	 <CAKgNAkh5s+U4hYhpCwMcFpKmxen9ztd8aAPoyGQOWyadTMYfOw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2014-04-18 at 07:28 +0200, Michael Kerrisk (man-pages) wrote:
> Hello Davidlohr,
> 
> On Fri, Apr 18, 2014 at 12:31 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > On Thu, 2014-04-17 at 22:23 +0200, Michael Kerrisk (man-pages) wrote:
> >> Hi Manfred!
> >>
> >> On Thu, Apr 17, 2014 at 6:22 PM, Manfred Spraul
> >> <manfred@colorfullife.com> wrote:
> >> > Hi Michael,
> >> >
> >> >
> >> > On 04/17/2014 12:53 PM, Michael Kerrisk wrote:
> >> >>
> >> >> On Sat, Apr 12, 2014 at 5:22 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
> [...]
> 
> >> >> Of the two proposed approaches (the other being
> >> >> marc.info/?l=linux-kernel&m=139730332306185), this looks preferable to
> >> >> me, since it allows strange users to maintain historical behavior
> >> >> (i.e., the ability to set a limit) if they really want it, so:
> >> >>
> >> >> Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>
> >> >>
> >> >> One or two comments below, that you might consider for your v3 patch.
> >> >
> >> > I don't understand what you mean.
> >>
> >> As noted in the other mail, you don't understand, because I was being
> >> dense (and misled a little by the commit message).
> >>
> >> > After a
> >> >     # echo 33554432 > /proc/sys/kernel/shmmax
> >> >     # echo 2097152 > /proc/sys/kernel/shmmax
> >> >
> >> > both patches behave exactly identical.
> >>
> >> Yes.
> >>
> >> > There are only two differences:
> >> > - Davidlohr's patch handles
> >> >     # echo <really huge number that doesn't fit into 64-bit> >
> >> > /proc/sys/kernel/shmmax
> >> >    With my patch, shmmax would end up as 0 and all allocations fail.
> >> >
> >> > - My patch handles the case if some startup code/installer checks
> >> >    shmmax and complains if it is below the requirement of the application.
> >>
> >> Thanks for that clarification. I withdraw my Ack.
> >
> > :(
> >
> >> In fact, maybe I
> >> even like your approach a little more, because of that last point.
> >
> > And it is a fair point. However, this is my counter argument: if users
> > are checking shmmax then they sure better be checking shmmin as well! So
> > if my patch causes shmctl(,IPC_INFO,) to return shminfo.shmmax = 0 and a
> > user only checks this value and breaks the application, then *he's*
> > doing it wrong. Checking shmmin is just as important...  0 value is
> > *bogus*,
> 
> That counter-argument sounds bogus. On all systems that I know/knew
> of, SHMIN always defaulted to 1. (Stevens APUE 1e documents this as
> the typical default even as far back as 1992.) Furthermore, the limit
> was always 1 on Linux, and as far as I know it has always been
> immutable. I very much doubt any sysadmin ever changed SHMMIN (why
> would they?), even on those systems where it was possible (and both
> SHMMIN and SHMMAX seem to have been obsolete on Solaris for some time
> now), or that any application ever checked the limit.

I'm not talking about *changing* SHMMIN, but checking for the value...
anything less than 1 is of course complete crap. And that's not the
kernel's fault.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

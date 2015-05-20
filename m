Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 266526B00F0
	for <linux-mm@kvack.org>; Wed, 20 May 2015 01:51:52 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so54497709pad.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 22:51:51 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id kt9si24897485pab.4.2015.05.19.22.51.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 19 May 2015 22:51:51 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: linux-next: Tree for May 18 (mm/memory-failure.c)
Date: Wed, 20 May 2015 05:36:15 +0000
Message-ID: <20150520053614.GA6236@hori1.linux.bs1.fc.nec.co.jp>
References: <20150518185226.23154d47@canb.auug.org.au>
 <555A0327.9060709@infradead.org>
 <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
 <20150519094636.67c9a4a3@gandalf.local.home>
In-Reply-To: <20150519094636.67c9a4a3@gandalf.local.home>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <56B25FA28FD4A84F86BB48F7605F9912@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

On Tue, May 19, 2015 at 09:46:36AM -0400, Steven Rostedt wrote:
...
> > diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
> > index 1443d79e4fe6..43054c0fcf65 100644
> > --- a/include/ras/ras_event.h
> > +++ b/include/ras/ras_event.h
> > @@ -1,6 +1,8 @@
> >  #undef TRACE_SYSTEM
> >  #define TRACE_SYSTEM ras
> >  #define TRACE_INCLUDE_FILE ras_event
> > +#undef TRACE_INCLUDE_PATH
> > +#define TRACE_INCLUDE_PATH ../../include/ras
>=20
> Note, ideally, you want:
>=20
> #define TRACE_INCLUDE_PATH .

OK, so we had better move include/ras/ras_event.h under include/trace/event=
s.
I'll do this in a separate work.

> and change the Makefile to have:
>=20
> CFLAGS_ras.o :=3D -I$(src)

It seems that if we do both of these, I hit the following error:

    CC      drivers/ras/ras.o
  In file included from include/trace/events/ras_event.h:327,
                   from drivers/ras/ras.c:13:
  include/trace/define_trace.h:83:43: error: ./ras_event.h: No such file or=
 directory

, so I guess it's enough to do either.

> ...
>=20
>=20
> > =20
> >  #if !defined(_TRACE_HW_EVENT_MC_H) || defined(TRACE_HEADER_MULTI_READ)
> >  #define _TRACE_HW_EVENT_MC_H
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index 8cbe23ac1056..e88e14d87571 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -57,6 +57,7 @@
> >  #include <linux/mm_inline.h>
> >  #include <linux/kfifo.h>
> >  #include "internal.h"
> > +#define CREATE_TRACE_POINTS
> >  #include "ras/ras_event.h"
>=20
> Um, you can only define CREATE_TRACE_POINTS for a single instance.
> Otherwise you will be making duplicate functions with the same name and
> same variables.
>=20
> That is, you must either pick CREATE_TRACE_POINTS for ras_event.h in
> mm/memory-failure.c or drivers/ras/ras.c. Not both.

OK, so it seems that the root cause of the original error is a wrong
dependency among CONFIGs.
CONFIG_RAS should depend on CONFIG_MEMORY_FAILURE, but that is not true
(CONFIG_RAS=3Dn and CONFIG_MEMORY_FAILURE=3Dy in Randy's .config.)
This problem is visible when CONFIG_X86_64=3Dn and CONFIG_SPARSEMEM=3Dn (an=
d all
other dependencies of CONFIG_RAS from ACPI_EXTLOG/PCIEAER/EDAC are false).
I'll fix such dependency.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: by ug-out-1314.google.com with SMTP id c2so1084048ugf
        for <linux-mm@kvack.org>; Sun, 29 Jul 2007 08:20:50 -0700 (PDT)
Message-ID: <2c0942db0707290820r2e31f40flb51a43846169a752@mail.gmail.com>
Date: Sun, 29 Jul 2007 08:20:50 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
In-Reply-To: <46ACAB45.6080307@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46AAEDEB.7040003@gmail.com>
	 <Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm>
	 <46AB166A.2000300@gmail.com>
	 <20070728122139.3c7f4290@the-village.bc.nu>
	 <46AC4B97.5050708@gmail.com>
	 <20070729141215.08973d54@the-village.bc.nu>
	 <46AC9F2C.8090601@gmail.com>
	 <2c0942db0707290758p39fef2e8o68d67bec5c7ba6ab@mail.gmail.com>
	 <46ACAB45.6080307@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, david@lang.hm, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/29/07, Rene Herman <rene.herman@gmail.com> wrote:
> On 07/29/2007 04:58 PM, Ray Lee wrote:
> > On 7/29/07, Rene Herman <rene.herman@gmail.com> wrote:
> >> Right over my head. Why does log-structure help anything?
> >
> > Log structured disk layouts allow for better placement of writeout, so
> > that you cn eliminate most or all seeks. Seeks are the enemy when
> > trying to get full disk bandwidth.
> >
> > google on log structured disk layout, or somesuch, for details.
>
> I understand what log structure is generally, but how does it help swapin?

Look at the swap out case first.

Right now, when swapping out the kernel places whatever it can
wherever it can inside the swap space. The closer you are to filling
your swap space, the more likely that those swapped out blocks will be
all over place, rather than in one nice chunk. Contrast that with a
log structured scheme, where the writeout happens to sequential spaces
on the drive instead of scattered about.

So, at some point when the system needs to fault those blocks that
back in, it now has a linear span of sectors to read instead of asking
the drive to bounce over twenty tracks for a hundred blocks.

So, it eliminates the seeks. My laptop drive can read (huh, how odd,
it got slower, need to retest in single user mode), hmm, let's go with
about 25 MB/s. If we ask for a single block from each track, though,
that'll drop to 4k * (1 second / seek time) which is about a megabyte
a second if we're lucky enough to read from consecutive tracks. Even
worse if it's not.

Seeks are the enemy any time you need to hit the drive for anything,
be it swapping or optimizing a database.

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

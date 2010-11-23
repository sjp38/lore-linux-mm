Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 55BDE6B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 15:55:11 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id oANKt5pl026910
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 12:55:05 -0800
Received: from qyk34 (qyk34.prod.google.com [10.241.83.162])
	by kpbe14.cbf.corp.google.com with ESMTP id oANKsjSs009051
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 12:55:04 -0800
Received: by qyk34 with SMTP id 34so3196178qyk.17
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 12:55:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101122215746.e847742d.akpm@linux-foundation.org>
References: <20101123050052.GA24039@google.com>
	<20101122215746.e847742d.akpm@linux-foundation.org>
Date: Tue, 23 Nov 2010 12:55:01 -0800
Message-ID: <AANLkTi=dK9wQaHm=tXOCqN2BDw5jEtH5qfs9zRHbE0qT@mail.gmail.com>
Subject: Re: [RFC] mlock: release mmap_sem every 256 faulted pages
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 9:57 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 22 Nov 2010 21:00:52 -0800 Michel Lespinasse <walken@google.com> =
wrote:
>> I'd like to sollicit comments on this proposal:
>>
>> Currently mlock() holds mmap_sem in exclusive mode while the pages get
>> faulted in. In the case of a large mlock, this can potentially take a
>> very long time.
>
> A more compelling description of why this problem needs addressing
> would help things along.

Oh my. It's probably not too useful for desktops, where such large
mlocks are hopefully uncommon.

At google we have many applications that serve data from memory and
don't want to allow for disk latencies. Some of the simpler ones use
mlock (though there are other ways - anon memory running with swap
disabled is a surprisingly popular choice).

Kosaki is also showing interest in mlock, though I'm not sure what his
use case is.

Due to the large scope of mmap_sem, there are many things that may
block while mlock() runs. If there are other threads running (and most
of our programs are threaded from an early point in their execution),
the threads might block on a page fault that needs to acquire
mmap_sem. Also, various files such as /proc/pid/maps stop working.
This is a problem for us because our cluster software can't monitor
what's going on with that process - not by talking to it as the
required threads might block, nor by looking at it through /proc
files.

A separate, personal interest is that I'm still carrying the
(admittedly poor-taste) down_read_unfair() patches internally, and I
would be able to drop them if only long mmap_sem hold times could be
eliminated.

>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* Limit batch size to 256 pages in order to=
 reduce
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* mmap_sem hold time.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 nfault =3D nstart + 256 * PAGE_SIZE;
>
> It would be nicer if there was an rwsem API to ask if anyone is
> currently blocked in down_read() or down_write(). =A0That wouldn't be too
> hard to do. =A0It wouldn't detect people polling down_read_trylock() or
> down_write_trylock() though.

I can do that. I actually thought about it myself, but then dismissed
it as too fancy for version 1. Only problem is that this would go into
per-architecture files which I can't test. But I wouldn't have to
actually write asm, so this may be OK. down_read_trylock() is no
problem, as these calls will succeed unless there is a queued writer,
which we can easily detect. down_write_trylock() is seldom used, the
only caller I could find for mmap_sem is
drivers/infiniband/core/umem.c and it'll do a regular down_write()
soon enough if the initial try fails.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

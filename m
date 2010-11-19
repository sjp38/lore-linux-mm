Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2966B004A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 08:42:10 -0500 (EST)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id oAJDg8qk029310
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 05:42:08 -0800
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by hpaq5.eem.corp.google.com with ESMTP id oAJDg5Pq029909
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 05:42:06 -0800
Received: by pwj6 with SMTP id 6so1253437pwj.18
        for <linux-mm@kvack.org>; Fri, 19 Nov 2010 05:42:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101119072316.GA14388@google.com>
References: <1289996638-21439-1-git-send-email-walken@google.com>
	<1289996638-21439-4-git-send-email-walken@google.com>
	<20101117125756.GA5576@amd>
	<1290007734.2109.941.camel@laptop>
	<AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
	<20101117231143.GQ22876@dastard>
	<20101118133702.GA18834@infradead.org>
	<alpine.LSU.2.00.1011180934400.3210@tigran.mtv.corp.google.com>
	<20101119072316.GA14388@google.com>
Date: Fri, 19 Nov 2010 08:42:05 -0500
Message-ID: <AANLkTinzhsvx=fx8dPpnJD_P70HKDRK+tWgFyYEN2_Zm@mail.gmail.com>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering writeback
From: Theodore Tso <tytso@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 2:23 AM, Michel Lespinasse <walken@google.com> wrot=
e:
>
> Approaching the problem the other way - would there be any objection to
> adding code to do an fallocate() equivalent at the start of mlock ?
> This would be a no-op when the file is fully allocated on disk, and would
> allow mlock to return an error if the file can't get fully allocated
> (no idea what errno should be for such case, though).

My vote would be against. =A0 If you if you mmap a sparse file and then
try writing to it willy-nilly, bad things will happen. =A0This is true with=
out
a mlock(). =A0 Where is it written that mlock() has anything to do with
improving this situation?

If userspace wants to call fallocate() before it calls mlock(), it should
do that. =A0And in fact, in most cases, userspace should probably be
encouraged to do that. =A0 But having mlock() call fallocate() and
then return ENOSPC if there's no room?  Isn't it confusing that mlock()
call ENOSPC?  Doesn't that give you cognitive dissonance?  It should
because fundamentally mlock() has nothing to do with block allocation!!
Read the API spec!

Look, it was an accident / bug of the implementation that mlock()
magically dirtied all these pages. =A0It might have made some situations
better, but I very much doubt applications depended upon it, and I'd
really rather not perpetuate this particular magic side effect of the
previously buggy implementation of mlock().

-- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

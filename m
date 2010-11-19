Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 64DA96B004A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 08:39:05 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id oAJDd2gu000467
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 05:39:02 -0800
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by wpaz33.hot.corp.google.com with ESMTP id oAJDcuP4027915
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 05:39:00 -0800
Received: by pvg2 with SMTP id 2so1092352pvg.30
        for <linux-mm@kvack.org>; Fri, 19 Nov 2010 05:38:56 -0800 (PST)
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
Date: Fri, 19 Nov 2010 08:38:55 -0500
Message-ID: <AANLkTi=6CGH3opgyF452g_-FDJ0uHCaxqPqHsrXai02L@mail.gmail.com>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering writeback
From: Theodore Tso <tytso@google.com>
Content-Type: multipart/alternative; boundary=000e0cd2e0e626451d0495680769
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

--000e0cd2e0e626451d0495680769
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Nov 19, 2010 at 2:23 AM, Michel Lespinasse <walken@google.com>wrote:

> Approaching the problem the other way - would there be any objection to
> adding code to do an fallocate() equivalent at the start of mlock ?
> This would be a no-op when the file is fully allocated on disk, and would
> allow mlock to return an error if the file can't get fully allocated
> (no idea what errno should be for such case, though).
>

My vote would be against.   If you if you mmap a sparse file and then try
writing to it willy-nilly, bad things will happen.  This is true without a
mlock().   Where is it written that mlock() has anything to do with
improving this situation?

If userspace wants to call fallocate() before it calls mlock(), it should do
that.  And in fact, in most cases, userspace should be encouraged to do
that.   But having mlock() call fallocate() and then return ENOSPC if
there's no room?

That just makes me feel icky as all heck.

Look, it was an accident / bug of the implementation that mlock() magically
dirtied all these pages.  It might have made some situations better, but I
very much doubt applications depended upon it, and I'd really rather not
perpetuate this particular magic side effect of the buggy implementation of
mlock().

-- Ted

--000e0cd2e0e626451d0495680769
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Nov 19, 2010 at 2:23 AM, Michel =
Lespinasse <span dir=3D"ltr">&lt;<a href=3D"mailto:walken@google.com">walke=
n@google.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div id=3D":762">Approaching the problem the other way - would there be any=
 objection to<br>
adding code to do an fallocate() equivalent at the start of mlock ?<br>
This would be a no-op when the file is fully allocated on disk, and would<b=
r>
allow mlock to return an error if the file can&#39;t get fully allocated<br=
>
(no idea what errno should be for such case, though).</div></blockquote></d=
iv><br><div>My vote would be against. =A0 If you if you mmap a sparse file =
and then try writing to it willy-nilly, bad things will happen. =A0This is =
true without a mlock(). =A0 Where is it written that mlock() has anything t=
o do with improving this situation?</div>
<div><br></div><div>If userspace wants to call fallocate() before it calls =
mlock(), it should do that. =A0And in fact, in most cases, userspace should=
 be encouraged to do that. =A0 But having mlock() call fallocate() and then=
 return ENOSPC if there&#39;s no room?</div>
<div><br></div><div>That just makes me feel icky as all heck.</div><div><br=
></div><div>Look, it was an accident / bug of the implementation that mlock=
() magically dirtied all these pages. =A0It might have made some situations=
 better, but I very much doubt applications depended upon it, and I&#39;d r=
eally rather not perpetuate this particular magic side effect of the buggy =
implementation of mlock().</div>
<div><br></div><div>-- Ted</div><div><br></div>

--000e0cd2e0e626451d0495680769--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

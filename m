Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 3AD556B013B
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 22:22:52 -0400 (EDT)
Received: by wefh52 with SMTP id h52so1162822wef.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:22:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120621184536.6dd97746.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1206201758500.3068@chino.kir.corp.google.com>
 <20120621164606.4ae1a71d.akpm@linux-foundation.org> <CA+55aFzPXMD3N3Oy-om6utDCQYmrBDnDgdqpVC5cgKe-v6uZ3w@mail.gmail.com>
 <20120621184536.6dd97746.akpm@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 21 Jun 2012 19:22:30 -0700
Message-ID: <CA+55aFzioa__XftM7GOh2_iz0ukrTqx1QDaYV=DhiQC4f6nC_w@mail.gmail.com>
Subject: Re: [patch 3.5-rc3] mm, mempolicy: fix mbind() to do synchronous migration
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>

On Thu, Jun 21, 2012 at 6:45 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> And casts to/from bool, perhaps. =A0To squish the warning we'd do things
> like a_bool =3D !!a_int. =A0That generates extra code, but gcc internally
> generates extra code for a_bool =3D a_int anyway, and a quick test here
> indicates that the generated code is identical (testl/setne).

It *has* to generate extra code. A cast to Bool is very much not at
all like a normal cast. All the traditional C casts just do a pure bit
truncate (or zero/sign extension) keeping the same value.

A cast to bool is totally different. It is exactly the same as "test
against zero" - so it in no way acts like a traditional integer cast
to a one-bit integer.

I'm not 100% sure the use of "bool" is a great idea, and people who
use pointers to bools are crazy mf's (you can break the fundamental
property of bools by assigning random values through the pointer), but
_Bool certainly ahs the _potential_ to be a good thing. The reason I'm
nervous about it is exactly that people get it wrong so easily because
they do *not* act like any other C type (the whole pointer-to-bool
thing being one example of people doing bad things - I personally
would be much happier if _Bool acted more like a one-bit bitfield and
could not have its address taken).

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 50C266B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 17:47:31 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <3f8dfac9-2b92-442c-800a-f0bfef8a90cb@default>
Date: Tue, 7 Aug 2012 14:47:05 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <5021795A.5000509@linux.vnet.ibm.com>
In-Reply-To: <5021795A.5000509@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Kurt Hackel <kurt.hackel@oracle.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH 0/4] promote zcache from staging
>=20
> On 07/27/2012 01:18 PM, Seth Jennings wrote:
> > Some benchmarking numbers demonstrating the I/O saving that can be had
> > with zcache:
> >
> > https://lkml.org/lkml/2012/3/22/383
>=20
> There was concern that kernel changes external to zcache since v3.3 may
> have mitigated the benefit of zcache.  So I re-ran my kernel building
> benchmark and confirmed that zcache is still providing I/O and runtime
> savings.

Hi Seth --

Thanks for re-running your tests.  I have a couple of concerns and
hope that you, and other interested parties, will read all the
way through my lengthy response.

The zcache issues I have seen in recent kernels arise when zcache
gets "full".  I notice your original published benchmarks [1] include
N=3D24, N=3D28, and N=3D32, but these updated results do not.  Are you plan=
ning
on completing the runs?  Second, I now see the numbers I originally
published for what I thought was the same benchmark as yours are actually
an order of magnitude larger (in sec) than yours.  I didn't notice
this in March because we were focused on the percent improvement, not
the raw measurements.  Since the hardware is highly similar, I suspect
it is not a hardware difference but instead that you are compiling
a much smaller kernel.  In other words, your test case is much
smaller, and so exercises zcache much less.  My test case compiles
a full enterprise kernel... what is yours doing?

IMHO, any cache in computer science needs to be measured both
when it is not-yet-full and when it is full.  The "demo" zcache in
staging works very well before it is full and I think our benchmarking
in March and your re-run benchmarks demonstrate that.  At LSFMM, Andrea
Arcangeli pointed out that zcache, for frontswap pages, has no "writeback"
capabilities and, when it is full, it simply rejects further attempts
to put data in its cache.  He said this is unacceptable for KVM and I
agreed that it was a flaw that needed to be fixed before zcache should
be promoted.  When I tested zcache for this, I found that not only was
he right, but that zcache could not be fixed without a major rewrite.

This is one of the "fundamental flaws" of the "demo" zcache, but the new
code base allows for this to be fixed.

A second flaw is that the "demo" zcache has no concept of LRU for
either cleancache or frontswap pages, or ability to reclaim pageframes
at all for frontswap pages.  (And for cleancache, pageframe reclaim
is semi-random).  As I've noted in other threads, this may be impossible
to implement/fix with zsmalloc, and zsmalloc's author Nitin Gupta has
agreed, but the new code base implements all of this with zbud.  One
can argue that LRU is not a requirement for zcache, but a long history
of operating systems theory would suggest otherwise.

A third flaw is that the "demo" version has a very poor policy to
determine what pages are "admitted".  The demo policy does take into
account the total RAM in the system, but not current memory load
conditions.  The new code base IMHO does a better job but discussion
will be in a refereed presentation at the upcoming Plumber's meeting.
The fix for this flaw might be back-portable to the "demo" version
so is not a showstopper in the "demo" version, but fixing it is
not just a cosmetic fix.

I can add more issues to the list, but will stop here.  IMHO
the "demo" zcache is not suitable for promotion from staging,
which is why I spent over two months generating a new code base.
I, perhaps more than anyone else, would like to see zcache used,
by default, by real distros and customers, but I think it is
premature to promote it, especially the old "demo" code.

I do realize, however, that this decision is not mine alone so
defer to the community to decide.

Dan

[1] https://lkml.org/lkml/2012/3/22/383=20
[2] http://lkml.indiana.edu/hypermail/linux/kernel/1203.2/02842.html=20
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

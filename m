Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 448CD6B00A1
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 15:08:03 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <80f208d0-c0e9-4d38-9085-99866f7ee5d7@default>
Date: Mon, 25 Mar 2013 12:07:38 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 1/4] introduce zero filled pages handler
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363255697-19674-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130316130302.GA5987@konrad-lan.dumpdata.com>
 <6041f181-67b1-4f71-bd5c-cfb48f1ddfb0@default>
 <CAPbh3rvOW2hh0bMTY_FyYJPiyqS4a76pHgDYLGYvLKjEzfJoig@mail.gmail.com>
In-Reply-To: <CAPbh3rvOW2hh0bMTY_FyYJPiyqS4a76pHgDYLGYvLKjEzfJoig@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad@darnok.org, Konrad Wilk <konrad.wilk@oracle.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Konrad Rzeszutek Wilk [mailto:konrad@darnok.org]
> Sent: Tuesday, March 19, 2013 10:44 AM
> To: Dan Magenheimer
> Cc: Wanpeng Li; Greg Kroah-Hartman; Andrew Morton; Seth Jennings; Minchan=
 Kim; linux-mm@kvack.org;
> linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v2 1/4] introduce zero filled pages handler
>=20
> On Sat, Mar 16, 2013 at 2:24 PM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> >> From: Konrad Rzeszutek Wilk [mailto:konrad@darnok.org]
> >> Subject: Re: [PATCH v2 1/4] introduce zero filled pages handler
> >>
> >> > +
> >> > +   for (pos =3D 0; pos < PAGE_SIZE / sizeof(*page); pos++) {
> >> > +           if (page[pos])
> >> > +                   return false;
> >>
> >> Perhaps allocate a static page filled with zeros and just do memcmp?
> >
> > That seems like a bad idea.  Why compare two different
> > memory locations when comparing one memory location
> > to a register will do?
>=20
> Good point. I was hoping there was an fast memcmp that would
> do fancy SSE registers. But it is memory against memory instead of
> registers.
>=20
> Perhaps a cunning trick would be to check (as a shortcircuit)
> check against 'empty_zero_page' and if that check fails, then try
> to do the check for each byte in the code?

Curious about this, I added some code to check for this case.
In my test run, the conditional "if (page =3D=3D ZERO_PAGE(0))"
was never true, for >200000 pages passed through frontswap that
were zero-filled.  My test run is certainly not conclusive,
but perhaps some other code in the swap subsystem disqualifies
ZERO_PAGE as a candidate for swapping?  Or maybe it is accessed
frequently enough that it never falls out of the active-anonymous
page queue?

Dan

P.S. In arch/x86/include/asm/pgtable.h:

#define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

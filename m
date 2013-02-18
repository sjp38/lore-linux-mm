Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 32BDE6B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 13:08:30 -0500 (EST)
MIME-Version: 1.0
Message-ID: <5120c705-5fcf-4e33-8562-22e8ad4b6c54@default>
Date: Mon, 18 Feb 2013 10:07:59 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2] zsmalloc: Add Kconfig for enabling PTE method
References: <1360117028-5625-1-git-send-email-minchan@kernel.org>
 <51207655.5000209@gmail.com>
In-Reply-To: <51207655.5000209@gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>, Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>

> From: Ric Mason [mailto:ric.masonn@gmail.com]
> Sent: Saturday, February 16, 2013 11:19 PM
> To: Minchan Kim
> Cc: Greg Kroah-Hartman; linux-mm@kvack.org; linux-kernel@vger.kernel.org;=
 Andrew Morton; Seth
> Jennings; Nitin Gupta; Dan Magenheimer; Konrad Rzeszutek Wilk
> Subject: Re: [PATCH v2] zsmalloc: Add Kconfig for enabling PTE method
>=20
> On 02/06/2013 10:17 AM, Minchan Kim wrote:
> > Zsmalloc has two methods 1) copy-based and 2) pte-based to access
> > allocations that span two pages. You can see history why we supported
> > two approach from [1].
> >
> > In summary, copy-based method is 3 times fater in x86 while pte-based
> > is 6 times faster in ARM.
>=20
> Why in some arches copy-based method is better and in the other arches
> pte-based is better? What's the root reason?

Minchan, if you post another version, I think these precise numbers
(of "times faster") should be removed.  The speed is very data
dependent, because the copy-based method is copying a zpage which
may vary widely in size from ~100 bytes to nearly PAGE_SIZE bytes,
a factor of 40x or more.

Please at least say "up to 3 times" or "approximately 3x faster for
an average compressed page".

Ric, the copy-based method does an extra copy of N bytes (where
N is the compressed size of a page).  The pte-based method requires
extra TLB actions.  The relative speed of TLB operations vs
copying is very architecture-dependent.  It is also probably
dependent on the specific implementation of the architecture
(i.e x86 sandybridge is likely very different than x86
nehalem) and, as noted above, dependent on N which is
unpredictable.

So it makes sense to have both choices, but it's not at all clear
how to select which one to use!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

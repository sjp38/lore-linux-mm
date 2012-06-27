Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id A6A3D6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 11:13:36 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default>
Date: Wed, 27 Jun 2012 08:12:56 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <4FEA9FDD.6030102@kernel.org> <4FEAA4AA.3000406@intel.com>
 <4FEAA7A1.9020307@kernel.org>
In-Reply-To: <4FEAA7A1.9020307@kernel.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Alex Shi <alex.shi@intel.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
>=20
> Hello,
>=20
> On 06/27/2012 03:14 PM, Alex Shi wrote:
>=20
> > On 06/27/2012 01:53 PM, Minchan Kim wrote:
> >
> >> On 06/26/2012 01:14 AM, Seth Jennings wrote:
> >>
> >>> This patch adds support for a local_tlb_flush_kernel_range()
> >>> function for the x86 arch.  This function allows for CPU-local
> >>> TLB flushing, potentially using invlpg for single entry flushing,
> >>> using an arch independent function name.
> >>>
> >>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> >>
> >>
> >> Anyway, we don't matter INVLPG_BREAK_EVEN_PAGES's optimization point i=
s 8 or something.
> >
> >
> > Different CPU type has different balance point on the invlpg replacing
> > flush all. and some CPU never get benefit from invlpg, So, it's better
> > to use different value for different CPU, not a fixed
> > INVLPG_BREAK_EVEN_PAGES.
>=20
> I think it could be another patch as further step and someone who are
> very familiar with architecture could do better than.
> So I hope it could be merged if it doesn't have real big problem.
>=20
> Thanks for the comment, Alex.

Just my opinion, but I have to agree with Alex.  Hardcoding
behavior that is VERY processor-specific is a bad idea.  TLBs should
only be messed with when absolutely necessary, not for the
convenience of defending an abstraction that is nice-to-have
but, in current OS kernel code, unnecessary.

IIUC, zsmalloc only cares that the breakeven point is greater
than two.  An arch-specific choice of (A) two page flushes
vs (B) one all-TLB flush should be all that is necessary right
now.  (And, per separate discussion, even this isn't really
necessary either.)

If zsmalloc _ever_ gets extended to support items that might
span three or more pages, a more generic TLB flush-pages-vs-flush-all
approach may be warranted and, by then, may already exist in some
future kernel.  Until then, IMHO, keep it simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

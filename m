Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 051E96B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:16:00 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <80ad7298-23de-4c5e-9a8d-483198ae4ef1@default>
Date: Wed, 27 Jun 2012 14:15:25 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <4FEA9FDD.6030102@kernel.org> <4FEAA4AA.3000406@intel.com>
 <4FEAA7A1.9020307@kernel.org> <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default>
 <4FEB5204.3090707@linux.vnet.ibm.com>
In-Reply-To: <4FEB5204.3090707@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan@kernel.org>, Alex Shi <alex.shi@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Wednesday, June 27, 2012 12:34 PM
> To: Dan Magenheimer
> Cc: Minchan Kim; Alex Shi; Greg Kroah-Hartman; devel@driverdev.osuosl.org=
; Konrad Wilk; linux-
> kernel@vger.kernel.org; linux-mm@kvack.org; Andrew Morton; Robert Jenning=
s; Nitin Gupta
> Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
>=20
> On 06/27/2012 10:12 AM, Dan Magenheimer wrote:
> >> From: Minchan Kim [mailto:minchan@kernel.org]
> >> Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
> >>
> >> On 06/27/2012 03:14 PM, Alex Shi wrote:
> >>>
> >>> On 06/27/2012 01:53 PM, Minchan Kim wrote:
> >>> Different CPU type has different balance point on the invlpg replacin=
g
> >>> flush all. and some CPU never get benefit from invlpg, So, it's bette=
r
> >>> to use different value for different CPU, not a fixed
> >>> INVLPG_BREAK_EVEN_PAGES.
> >>
> >> I think it could be another patch as further step and someone who are
> >> very familiar with architecture could do better than.
> >> So I hope it could be merged if it doesn't have real big problem.
> >>
> >> Thanks for the comment, Alex.
> >
> > Just my opinion, but I have to agree with Alex.  Hardcoding
> > behavior that is VERY processor-specific is a bad idea.  TLBs should
> > only be messed with when absolutely necessary, not for the
> > convenience of defending an abstraction that is nice-to-have
> > but, in current OS kernel code, unnecessary.
>=20
> I agree that it's not optimal.  The selection based on CPUID
> is part of Alex's patchset, and I'll be glad to use that
> code when it gets integrated.
>=20
> But the real discussion is are we going to:
> 1) wait until Alex's patches to be integrated, degrading
> zsmalloc in the meantime or
> 2) put in some simple temporary logic that works well (not
> best) for most cases
>=20
> > IIUC, zsmalloc only cares that the breakeven point is greater
> > than two.  An arch-specific choice of (A) two page flushes
> > vs (B) one all-TLB flush should be all that is necessary right
> > now.  (And, per separate discussion, even this isn't really
> > necessary either.)
> >
> > If zsmalloc _ever_ gets extended to support items that might
> > span three or more pages, a more generic TLB flush-pages-vs-flush-all
> > approach may be warranted and, by then, may already exist in some
> > future kernel.  Until then, IMHO, keep it simple.
>=20
> I guess I'm not following.  Are you supporting the removal
> of the "break even" logic?  I added that logic as a
> compromise for Peter's feedback:
>=20
> http://lkml.org/lkml/2012/5/17/177

Yes, as long as I am correct that zsmalloc never has to map/flush
more than two pages at a time, I think dealing with the break-even
logic is overkill.  I see Peter isn't on this dist list... maybe
you should ask him if he agrees, as long as we are only always
talking about flush-two-TLB-pages vs flush-all.

(And, of course, per previous discussion, I think even mapping/flushing
two TLB pages is unnecessary and overkill required only for protecting an
abstraction, but will stop beating that dead horse. ;-)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

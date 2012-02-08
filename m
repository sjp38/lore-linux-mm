Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 1390F6B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 16:40:03 -0500 (EST)
MIME-Version: 1.0
Message-ID: <52f90b19-84b5-4e97-952a-373bdfeaa77d@default>
Date: Wed, 8 Feb 2012 13:39:52 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <4F21A5AF.6010605@linux.vnet.ibm.com> <4F300D41.5050105@linux.vnet.ibm.com>
 <4F32A55E.8010401@linux.vnet.ibm.com> <4F32B6A4.8030702@vflare.org>
 <4F32BEDC.6030502@linux.vnet.ibm.com> <4F32E1D2.4010809@vflare.org>
In-Reply-To: <4F32E1D2.4010809@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

(cc'ing the _real_ GregKH to avoid further bounces... Greg, if
you care, the whole thread is on the various lists)

> From: Nitin Gupta [mailto:ngupta@vflare.org]
> Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation li=
brary
>=20
> On 02/08/2012 01:28 PM, Dave Hansen wrote:
>=20
> > On 02/08/2012 09:53 AM, Nitin Gupta wrote:
> >> vmap() is not just slower but also does memory allocations at various
> >> places. Under memory pressure, this may cause failure in reading a
> >> stored object just because we failed to map it. Also, it allocates VA
> >> region each time its called which is a real big waste when we can simp=
ly
> >> pre-allocate 2 * PAGE_SIZE'ed VA regions (per-cpu).
> >
> > Yeah, vmap() is a bit heavy-handed.  I'm just loathe to go mucking
> > around in the low-level pagetables too much.  Just seems like there'll
> > be a ton of pitfalls, like arch-specific TLB flushing, and it _seems_
> > like one of the existing kernel mechanisms should work.
> >
> > I guess if you've exhaustively explored all of the existing kernel
> > mapping mechanisms and found none of them to work, and none of them to
> > be in any way suitably adaptable to your use, you should go ahead and
> > roll your own.  I guess you do at least use alloc_vm_area().  What made
> > map_vm_area() unsuitable for your needs?  If you're remapping, you
> > should at least be guaranteed not to have to allocate pte pages.
>=20
> map_vm_area() needs 'struct vm_struct' parameter but for mapping kernel
> allocated pages within kernel, what should we pass here?  I think we can
> instead use map_kernel_range_noflush() -- surprisingly
> unmap_kernel_range_noflush() is exported but this one is not.

Creating a dependency on a core kernel change (even just an EXPORT_SYMBOL)
is probably not a good idea.  Unless Dave vehemently objects, I'd suggest
implementing it both ways, leaving the method that relies on the
kernel change ifdef'd out, and add this to "the list of things that
need to be done before zcache can be promoted out of staging".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

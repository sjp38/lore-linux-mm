Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 2AD786B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 12:15:47 -0500 (EST)
MIME-Version: 1.0
Message-ID: <409797c4-a6e7-493d-9681-4166a9473ab8@default>
Date: Wed, 8 Feb 2012 09:15:36 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <4F21A5AF.6010605@linux.vnet.ibm.com> <4F300D41.5050105@linux.vnet.ibm.com>
 <4F32A55E.8010401@linux.vnet.ibm.com>
In-Reply-To: <4F32A55E.8010401@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Nitin Gupta <ngupta@vflare.org>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation li=
brary
>=20
> On 02/06/2012 09:26 AM, Seth Jennings wrote:
> > On 01/26/2012 01:12 PM, Dave Hansen wrote:
> >> void *kmap_atomic_prot(struct page *page, pgprot_t prot)
> >> {
> >> ...
> >>         type =3D kmap_atomic_idx_push();
> >>         idx =3D type + KM_TYPE_NR*smp_processor_id();
> >>         vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
> >>
> >> I think if you do a get_cpu()/put_cpu() or just a preempt_disable()
> >> across the operations you'll be guaranteed to get two contiguous addre=
sses.
> >
> > I'm not quite following here.  kmap_atomic() only does this for highmem=
 pages.
> > For normal pages (all pages for 64-bit), it doesn't do any mapping at a=
ll.  It
> > just returns the virtual address of the page since it is in the kernel'=
s address
> > space.
> >
> > For this design, the pages _must_ be mapped, even if the pages are dire=
ctly
> > reachable in the address space, because they must be virtually contiguo=
us.
>=20
> I guess you could use vmap() for that.  It's just going to be slower
> than kmap_atomic().  I'm really not sure it's worth all the trouble to
> avoid order-1 allocations, though.

Seth, Nitin, please correct me if I am wrong, but...

Dave, your comment makes me wonder if maybe you might be missing
the key value of the new allocator.  The zsmalloc allocator can grab
any random* page "A" with X unused bytes at the END of the page,
and any random page "B" with Y unused bytes at the BEGINNING of the page
and "coalesce" them to store any byte sequence with a length** Z
not exceeding X+Y.  Presumably this markedly increases
the density of compressed-pages-stored-per-physical-page***.  I don't=20
see how allowing order-1 allocations helps here but if I am missing
something clever, please explain further.

(If anyone missed Jonathan Corbet's nice lwn.net article, see:
https://lwn.net/Articles/477067/ )

* Not really ANY random page, just any random page that has been
  previously get_free_page'd by the allocator and hasn't been
  free'd yet.
** X, Y and Z are all rounded to a multiple of 16 so there
  is still some internal fragmentation cost.
*** Would be interesting to see some random and real workload data
  comparing density for zsmalloc and xvmalloc.  And also zbud
  too as a goal is to replace zbud with zsmalloc too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id F41616B0068
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 13:31:01 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <10ea9d19-bd24-400c-8131-49f0b4e9e5ae@default>
Date: Fri, 15 Jun 2012 10:29:46 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
 <1337133919-4182-3-git-send-email-minchan@kernel.org>
 <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins>
 <4FDB5107.3000308@linux.vnet.ibm.com>
 <7e925563-082b-468f-a7d8-829e819eeac0@default> <4FDB66B7.2010803@vflare.org>
In-Reply-To: <4FDB66B7.2010803@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

> From: Nitin Gupta [mailto:ngupta@vflare.org]
> Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
>=20
> On 06/15/2012 09:35 AM, Dan Magenheimer wrote:
> >> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> >> Sent: Friday, June 15, 2012 9:13 AM
> >> To: Peter Zijlstra
> >> Cc: Minchan Kim; Greg Kroah-Hartman; Nitin Gupta; Dan Magenheimer; lin=
ux-kernel@vger.kernel.org;
> >> linux-mm@kvack.org; Thomas Gleixner; Ingo Molnar; Tejun Heo; David How=
ells; x86@kernel.org; Nick
> >> Piggin
> >> Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
> >>
> >> On 05/17/2012 09:51 AM, Peter Zijlstra wrote:
> >>
> >>> On Thu, 2012-05-17 at 17:11 +0900, Minchan Kim wrote:
> >>>>> +++ b/arch/x86/include/asm/tlbflush.h
> >>>>> @@ -172,4 +172,16 @@ static inline void flush_tlb_kernel_range(unsi=
gned long start,
> >>>>>       flush_tlb_all();
> >>>>>  }
> >>>>>
> >>>>> +static inline void local_flush_tlb_kernel_range(unsigned long star=
t,
> >>>>> +             unsigned long end)
> >>>>> +{
> >>>>> +     if (cpu_has_invlpg) {
> >>>>> +             while (start < end) {
> >>>>> +                     __flush_tlb_single(start);
> >>>>> +                     start +=3D PAGE_SIZE;
> >>>>> +             }
> >>>>> +     } else
> >>>>> +             local_flush_tlb();
> >>>>> +}
> >>>
> >>> It would be much better if you wait for Alex Shi's patch to mature.
> >>> doing the invlpg thing for ranges is not an unconditional win.
> >>
> >> From what I can tell Alex's patches have stalled.  The last post was v=
6
> >> on 5/17 and there wasn't a single reply to them afaict.
> >>
> >> According to Alex's investigation of this "tipping point", it seems th=
at
> >> a good generic value is 8.  In other words, on most x86 hardware, it i=
s
> >> cheaper to flush up to 8 tlb entries one by one rather than doing a
> >> complete flush.
> >>
> >> So we can do something like:
> >>
> >>      if (cpu_has_invlpg && (end - start)/PAGE_SIZE <=3D 8) {
> >>              while (start < end) {
> >>
> >> Would this be acceptable?
> >
> > Hey Seth, Nitin --
> >
> > After more work digging around zsmalloc and zbud, I really think
> > this TLB flushing, as well as the "page pair mapping" code can be
> > completely eliminated IFF zsmalloc is limited to items PAGE_SIZE or
> > less.  Since this is already true of zram (and in-tree zcache), and
> > zsmalloc currently has no other users, I think you should seriously
> > consider limiting zsmalloc in that way, or possibly splitting out
> > one version of zsmalloc which handles items PAGE_SIZE or less,
> > and a second version that can handle larger items but has (AFAIK)
> > no users.
> >
> > If you consider it an option to have (a version of) zsmalloc
> > limited to items PAGE_SIZE or less, let me know and we can
> > get into the details.
>=20
> zsmalloc is already limited to objects of size PAGE_SIZE or less. This
> two-page splitting is for efficiently storing objects in range
> (PAGE_SIZE/2, PAGE_SIZE) which is very common in both zram and zcache.
>=20
> SLUB achieves this efficiency by allocating higher order pages but that
> is not an option for zsmalloc.

That's what I thought, but a separate thread about ensuring zsmalloc
was as generic as possible led me to believe that zsmalloc was moving
in the direction of larger sizes.

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>=20
> To add to what Nitin just sent, without the page mapping, zsmalloc and
> the late xvmalloc have the same issue.  Say you have a whole class of
> objects that are 3/4 of a page.  Without the mapping, you can't cross
> non-contiguous page boundaries and you'll have 25% fragmentation in the
> memory pool.  This is the whole point of zsmalloc.

Yes, understood.  This suggestion doesn't change any of that.
It only assumes that no more than one page boundary is crossed.

So, briefly, IIRC the "pair mapping" is what creates the necessity
to do special TLB stuff.  That pair mapping is necessary
to create the illusion to the compression/decompression code
(and one other memcpy) that no pageframe boundary is crossed.
Correct?

The compression code already compresses to a per-cpu page-pair
already and then that "zpage" is copied into the space allocated
for it by zsmalloc.  For that final copy, if the copy code knows
the target may cross a page boundary, has both target pages
kmap'ed, and is smart about doing the copy, the "pair mapping"
can be avoided for compression.

The decompression path calls lzo1x directly and it would be
a huge pain to make lzo1x smart about page boundaries.  BUT
since we know that the decompressed result will always fit
into a page (actually exactly a page), you COULD do an extra
copy to the end of the target page (using the same smart-
about-page-boundaries copying code from above) and then do
in-place decompression, knowing that the decompression will
not cross a page boundary.  So, with the extra copy, the "pair
mapping" can be avoided for decompression as well.

What about the horrible cost of that extra copy?  Well, much
of the cost of a large copy is due to cache effects.  Since
you are copying into a page that will immediately be overwritten
by the decompress, I'll bet that cost is much smaller.  And
compared to the cost of setting up and tearing down TLB
entries (especially on machines with no local_tlb_kernel_range),
I suspect that special copy may be a LOT cheaper.  And
with no special TLB code required, zsmalloc should be a lot
more portable.

Thoughts?
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

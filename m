Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 881A96B006C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 12:36:51 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <7e925563-082b-468f-a7d8-829e819eeac0@default>
Date: Fri, 15 Jun 2012 09:35:34 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
 <1337133919-4182-3-git-send-email-minchan@kernel.org>
 <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins>
 <4FDB5107.3000308@linux.vnet.ibm.com>
In-Reply-To: <4FDB5107.3000308@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Friday, June 15, 2012 9:13 AM
> To: Peter Zijlstra
> Cc: Minchan Kim; Greg Kroah-Hartman; Nitin Gupta; Dan Magenheimer; linux-=
kernel@vger.kernel.org;
> linux-mm@kvack.org; Thomas Gleixner; Ingo Molnar; Tejun Heo; David Howell=
s; x86@kernel.org; Nick
> Piggin
> Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
>=20
> On 05/17/2012 09:51 AM, Peter Zijlstra wrote:
>=20
> > On Thu, 2012-05-17 at 17:11 +0900, Minchan Kim wrote:
> >>> +++ b/arch/x86/include/asm/tlbflush.h
> >>> @@ -172,4 +172,16 @@ static inline void flush_tlb_kernel_range(unsign=
ed long start,
> >>>       flush_tlb_all();
> >>>  }
> >>>
> >>> +static inline void local_flush_tlb_kernel_range(unsigned long start,
> >>> +             unsigned long end)
> >>> +{
> >>> +     if (cpu_has_invlpg) {
> >>> +             while (start < end) {
> >>> +                     __flush_tlb_single(start);
> >>> +                     start +=3D PAGE_SIZE;
> >>> +             }
> >>> +     } else
> >>> +             local_flush_tlb();
> >>> +}
> >
> > It would be much better if you wait for Alex Shi's patch to mature.
> > doing the invlpg thing for ranges is not an unconditional win.
>=20
> From what I can tell Alex's patches have stalled.  The last post was v6
> on 5/17 and there wasn't a single reply to them afaict.
>=20
> According to Alex's investigation of this "tipping point", it seems that
> a good generic value is 8.  In other words, on most x86 hardware, it is
> cheaper to flush up to 8 tlb entries one by one rather than doing a
> complete flush.
>=20
> So we can do something like:
>=20
>      if (cpu_has_invlpg && (end - start)/PAGE_SIZE <=3D 8) {
>              while (start < end) {
>=20
> Would this be acceptable?

Hey Seth, Nitin --

After more work digging around zsmalloc and zbud, I really think
this TLB flushing, as well as the "page pair mapping" code can be
completely eliminated IFF zsmalloc is limited to items PAGE_SIZE or
less.  Since this is already true of zram (and in-tree zcache), and
zsmalloc currently has no other users, I think you should seriously
consider limiting zsmalloc in that way, or possibly splitting out
one version of zsmalloc which handles items PAGE_SIZE or less,
and a second version that can handle larger items but has (AFAIK)
no users.

If you consider it an option to have (a version of) zsmalloc
limited to items PAGE_SIZE or less, let me know and we can
get into the details.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 79BD96B0068
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 16:14:41 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <4ffbc3e8-900b-4669-b6ab-e8c066f28c63@default>
Date: Fri, 15 Jun 2012 13:13:29 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
 <1337133919-4182-3-git-send-email-minchan@kernel.org>
 <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins>
 <4FDB5107.3000308@linux.vnet.ibm.com>
 <7e925563-082b-468f-a7d8-829e819eeac0@default> <4FDB66B7.2010803@vflare.org>
 <10ea9d19-bd24-400c-8131-49f0b4e9e5ae@default>
 <4FDB8808.9010508@linux.vnet.ibm.com>
 <9c6c8ae0-0212-402d-a906-0d0c61e5e058@default> <4FDB92CF.1070603@vflare.org>
In-Reply-To: <4FDB92CF.1070603@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

> From: Nitin Gupta [mailto:ngupta@vflare.org]
> Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
>=20
> On 06/15/2012 12:39 PM, Dan Magenheimer wrote:
> >> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> >>> The decompression path calls lzo1x directly and it would be
> >>> a huge pain to make lzo1x smart about page boundaries.  BUT
> >>> since we know that the decompressed result will always fit
> >>> into a page (actually exactly a page), you COULD do an extra
> >>> copy to the end of the target page (using the same smart-
> >>> about-page-boundaries copying code from above) and then do
> >>> in-place decompression, knowing that the decompression will
> >>> not cross a page boundary.  So, with the extra copy, the "pair
> >>> mapping" can be avoided for decompression as well.
> >>
> >> This is an interesting thought.
> >>
> >> But this does result in a copy in the decompression (i.e. page fault)
> >> path, where right now, it is copy free.  The compressed data is
> >> decompressed directly from its zsmalloc allocation to the page allocat=
ed
> >> in the fault path.
> >
> > The page fault occurs as soon as the lzo1x compression code starts anyw=
ay,
> > as do all the cache faults... both just occur earlier, so the only
> > additional cost is the actual cpu instructions to move the sequence of
> > (compressed) bytes from the zsmalloc-allocated area to the end
> > of the target page.
> >
> > TLB operations can be very expensive, not to mention (as the
> > subject of this thread attests) non-portable.
>=20
> Even if you go for copying chunks followed by decompression, it still
> requires two kmaps and kunmaps. Each of these require one local TLB
> invlpg. So, a total of 2 local maps + unmaps even with this approach.

That may be true for i386, but on a modern (non-highmem) machine those
kmaps/kunmaps are free and "pair mappings" in the TLB are still expensive
and not very portable.  Doesn't make sense to me to design for better
performance on highmem and poorer performance on non-highmem.
=20
> The only additional requirement of zsmalloc is that it requires two
> mappings which are virtually contiguous. The cost is the same in both
> approaches but the current zsmalloc approach presents a much cleaner
> interface.

OK, it's your code and I'm just making a suggestion. I will shut up now ;-)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

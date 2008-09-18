Message-ID: <48D2D4AF.2050206@goop.org>
Date: Thu, 18 Sep 2008 15:22:39 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D2BFB8.6010503@redhat.com>	 <33307c790809181411j41a6fc4ev8560a13ed8661ec2@mail.gmail.com>	 <48D2C46A.5030702@linux-foundation.org>	 <33307c790809181421k52ed6a36h9d4ee40d5799a536@mail.gmail.com>	 <48D2C8DD.4040303@linux-foundation.org>	 <28c262360809181449v1050c1f7ndf17dadba9fac0bf@mail.gmail.com>	 <48D2CEF3.6060308@linux-foundation.org>	 <33307c790809181508v2e64c0a4j8f0e93df99673e63@mail.gmail.com>	 <48D2D22B.2070408@linux-foundation.org> <8f3aa8d60809181518r697b5d7cp9e154fe73f804cc7@mail.gmail.com>
In-Reply-To: <8f3aa8d60809181518r697b5d7cp9e154fe73f804cc7@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Martin Bligh <mbligh@google.com>, MinChan Kim <minchan.kim@gmail.com>, Chris Snook <csnook@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Martin Bligh wrote:
>>>> My patches were only for anonymous pages not for file backed because readahead
>>>> is available for file backed mappings.
>>>>         
>>> Do we populate the PTEs though? I didn't think that was batched, but I
>>> might well be wrong.
>>>       
>> We do not populate the PTEs and AFAICT PTE population was assumed not to be
>> performance critical since the backing media is comparatively slow.
>>     
>
> I think the times when this matters are things like glibc, which are
> heavily shared -
> we were only 'prefaulting' when the pagecache was already there. So it's a case
> for a "readahead like algorithm", not necessarily a direct hook.
>   

Yes.  My thought was that there should be very little cost to
opportunistically populating the pte for a page which is already
resident anyway.

> Anonymous pages seem much riskier, as presumably there's a no backing page
> except in the fork case.
>
> I presume the reason Jeremy is interested is because his pagefaults are more
> expensive than most (under virtualization), so he may well find a
> different tradeoff
> than I did (try running kernbench?)
>   

Right.  The faults themselves are more or less the same as the native
case, but setting a pte requires a hypercall compared to a memory write
in the native case.  But I can set any number of ptes in one hypercall,
so batching would amortize the cost.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

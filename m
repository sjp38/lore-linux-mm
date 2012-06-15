Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 4F5A36B0068
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 15:09:02 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 15:09:01 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3314038C809E
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 15:08:03 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5FJ801P157800
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 15:08:00 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5FJ80Og011367
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 15:08:00 -0400
Message-ID: <4FDB8808.9010508@linux.vnet.ibm.com>
Date: Fri, 15 Jun 2012 14:07:52 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org> <1337133919-4182-3-git-send-email-minchan@kernel.org> <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins> <4FDB5107.3000308@linux.vnet.ibm.com> <7e925563-082b-468f-a7d8-829e819eeac0@default> <4FDB66B7.2010803@vflare.org> <10ea9d19-bd24-400c-8131-49f0b4e9e5ae@default>
In-Reply-To: <10ea9d19-bd24-400c-8131-49f0b4e9e5ae@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]

>> To add to what Nitin just sent, without the page mapping, zsmalloc and
>> the late xvmalloc have the same issue.  Say you have a whole class of
>> objects that are 3/4 of a page.  Without the mapping, you can't cross
>> non-contiguous page boundaries and you'll have 25% fragmentation in the
>> memory pool.  This is the whole point of zsmalloc.
> 
> Yes, understood.  This suggestion doesn't change any of that.
> It only assumes that no more than one page boundary is crossed.
> 
> So, briefly, IIRC the "pair mapping" is what creates the necessity
> to do special TLB stuff.  That pair mapping is necessary
> to create the illusion to the compression/decompression code
> (and one other memcpy) that no pageframe boundary is crossed.
> Correct?


Yes.

> The compression code already compresses to a per-cpu page-pair
> already and then that "zpage" is copied into the space allocated
> for it by zsmalloc.  For that final copy, if the copy code knows
> the target may cross a page boundary, has both target pages
> kmap'ed, and is smart about doing the copy, the "pair mapping"
> can be avoided for compression.


The problem is that by "smart" you mean "has access to zsmalloc
internals".  zcache, or any user, would need the know the kmapped
address of the first page, the offset to start at within that page, and
the kmapped address of the second page in order to do the smart copy
you're talking about.  Then the complexity to do the smart copy that
would have to be implemented in each user.


> The decompression path calls lzo1x directly and it would be
> a huge pain to make lzo1x smart about page boundaries.  BUT
> since we know that the decompressed result will always fit
> into a page (actually exactly a page), you COULD do an extra
> copy to the end of the target page (using the same smart-
> about-page-boundaries copying code from above) and then do
> in-place decompression, knowing that the decompression will
> not cross a page boundary.  So, with the extra copy, the "pair
> mapping" can be avoided for decompression as well.


This is an interesting thought.

But this does result in a copy in the decompression (i.e. page fault)
path, where right now, it is copy free.  The compressed data is
decompressed directly from its zsmalloc allocation to the page allocated
in the fault path.

Doing this smart copy stuff would move most of the complexity out of
zsmalloc into the user which defeats the purpose of abstracting the
functionality out in the first place: so the each user that wants to do
something like this doesn't have to reinvent the wheel.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

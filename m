Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAUHh9iw014899
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 12:43:09 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAUHh94d131954
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 10:43:09 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAUHh8HE026985
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 10:43:08 -0700
Date: Fri, 30 Nov 2007 09:43:07 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] mm: fix confusing __GFP_REPEAT related comments
Message-ID: <20071130174307.GS13444@us.ibm.com>
References: <20071129214828.GD20882@us.ibm.com> <1196378080.18851.116.camel@localhost> <20071130041922.GQ13444@us.ibm.com> <1196447260.19681.8.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1196447260.19681.8.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, mel@skynet.ie, wli@holomorphy.com, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.11.2007 [10:27:40 -0800], Dave Hansen wrote:
> On Thu, 2007-11-29 at 20:19 -0800, Nishanth Aravamudan wrote: 
> > "In looking at the callers using __GFP_REPEAT, not all handle failure --
> > should they be using __NOFAIL?"
> > 
> > I *think* that all the current __GFP_REPEAT users are order <=
> > PAGE_ALLOC_CSOTLY_ORDER. Perhaps they all mean to use __GPF_NOFAIL? Some
> > don't handle failure immediately, but maybe their callers do, I haven't
> > had time to investigate fully.
> 
> I think we treat pagetable allocations just like normal ones with
> error handling.  If I saw a pte_alloc() in a patch that was used
> without checking for NULL, I'd certainly bitch about it.

Hrm, you may be right. And it appears the only non-pagetable callers of
__GFP_REPEAT allocations are:

drivers/mmc/host/wbsd.c::wbsd_request_dma()
drivers/net/ppp_deflate.c::z_decomp_alloc()
drivers/s390/char/vmcp.c::vmcp_write()
net/core/sock.c::sock_alloc_send_pskb()

But those are of course only the explicit callers -- there are
presumably many others that are getting the same effect by passing a low
order.

> In any case, if we want to nitpick, the *callers* haven't asked for
> __GFP_NOFAIL, so they shouldn't be depending on a lack of failures.

I agree.

> > And the whole gist, per the comments in mm/page_alloc.c, is that this is
> > all dependent upon this implementation of the VM. I think that means you
> > can't rely on those semantics being valid forever. So it's best for
> > callers to be as explicit as possible ... but in this case, I'm not sure
> > that the desired semantics actually exist.
> 
> I don't really buy this "in this implementation of the VM" crap.  When
> people go to figure out which functions and flags to use, they don't
> just go look at headers.  They look at and depend on the
> implementations.  If we change the implementations, we go change all
> the callers, too.

I agree here, as well. I think that's why I'm asking ... if the
implementation is changed to perhaps different semantics: first, do we
have a set of semantics that are more desirably? second, do I interpret
the current callers flags as is and risk breaking some mild assumption
somewhere (that, for instance, while __GFP_REPEAT might fail, it doesn't
currently, so callers, while handling errors, really don't expect to
ever hit that code path?)

> Your patch highlights an existing problem: we're not being very good
> with __GFP_REPEAT.  All of the pagetable users (on x86 at least) are
> using __GFP_REPEAT, but effectively getting __GFP_NOFAIL.  There are
> some other users around that might have larger buffers, but I think
> pagetable pages are pretty guaranteed to stay <= 1 page in size. :)

Indeed.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

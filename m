Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7906B0253
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 12:41:51 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i2so6060039pgq.8
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 09:41:51 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id c18si24900140plz.125.2017.12.28.09.41.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 09:41:50 -0800 (PST)
Message-ID: <1514482907.3040.15.camel@HansenPartnership.com>
Subject: Re: Hang with v4.15-rc trying to swap back in
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 28 Dec 2017 09:41:47 -0800
In-Reply-To: <20171227235643.GA10532@bbox>
References: <1514398340.3986.10.camel@HansenPartnership.com>
	 <1514407817.4169.4.camel@HansenPartnership.com>
	 <20171227232650.GA9702@bbox>
	 <1514417689.3083.1.camel@HansenPartnership.com>
	 <20171227235643.GA10532@bbox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On Thu, 2017-12-28 at 08:56 +0900, Minchan Kim wrote:
> On Wed, Dec 27, 2017 at 03:34:49PM -0800, James Bottomley wrote:
> > 
> > On Thu, 2017-12-28 at 08:26 +0900, Minchan Kim wrote:
> > > 
> > > Hello James,
> > > 
> > > On Wed, Dec 27, 2017 at 12:50:17PM -0800, James Bottomley wrote:
> > > > 
> > > > 
> > > > Reverting these three patches fixes the problem:
> > > > 
> > > > commit aa8d22a11da933dbf880b4933b58931f4aefe91c
> > > > Author: Minchan Kim <minchan@kernel.org>
> > > > Date:A A A Wed Nov 15 17:33:11 2017 -0800
> > > > 
> > > > A A A A mm: swap: SWP_SYNCHRONOUS_IO: skip swapcache only if
> > > > swapped page has no other reference
> > > > 
> > > > commit 0bcac06f27d7528591c27ac2b093ccd71c5d0168
> > > > Author: Minchan Kim <minchan@kernel.org>
> > > > Date:A A A Wed Nov 15 17:33:07 2017 -0800
> > > > 
> > > > A A A A mm, swap: skip swapcache for swapin of synchronous device
> > > > 
> > > > Also need to revert:
> > > > 
> > > > commit e9a6effa500526e2a19d5ad042cb758b55b1ef93
> > > > Author: Huang Ying <huang.ying.caritas@gmail.com>
> > > > Date:A A A Wed Nov 15 17:33:15 2017 -0800
> > > > 
> > > > A A A A mm, swap: fix false error message in __swp_swapcount()
> > > > 
> > > > (The latter is simply because it used a function that is
> > > > eliminated by one of the other reversions). A They came into the
> > > > merge window via the -mm tree as part of a 4 part series:
> > > > 
> > > > Subject:	[PATCH v2 0/4] skip swapcache for super fast
> > > > device
> > > > Message-Id:	<1505886205-9671-1-git-send-email-
> > > > minchan@kernel.org
> > > > > 
> > > > > 
> > > > > 
> > > > 
> > > > James
> > > 
> > > Thanks for the report.
> > > Patches are related to synchronous swap devices like brd, zram,
> > > nvdimm so
> > > 
> > > 1. What swap device do you use among them?
> > 
> > I've reproduced on nvme and sata spinning rust.
> > 
> > > 
> > > 2. Could you tell me how you can reproduce it?
> > 
> > The way to reproduce is to force something to swap and then get it
> > to try to touch the page again. A I do this on my systems by using a
> > large virtual machine, as I said in the email. A There isn't really
> > any definitive reproduction method beyond that.
> > 
> 
> Thanks for the information. It seems I made a bug on do_swap_page. I
> want to confirm before sending formal patch. Could you try on it?
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index ca5674cbaff2..240521f1322d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2889,9 +2889,12 @@ int do_swap_page(struct vm_fault *vmf)
> A 
> A 
> A 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> -	if (!page)
> +	if (!page) {
> A 		page = lookup_swap_cache(entry, vma_readahead ? vma
> : NULL,
> A 					A vmf->address);
> +		swapcache = page;
> +	}
> +

This hangs in precisely the same way first kworker then kswapd with the
same stack trace.

I'd guess that since they're both in io_schedule, the problem is that
the io_scheduler is taking far too long servicing the requests due to
some priority issue you've introduced.

Since we're at -rc5, soon to be -rc6, let's just revert the whole
series and you can retry it for 4.16. A The whole point seems to be for
zram, which isn't really a huge use case.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 821876B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 18:56:46 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id z3so22304674plh.18
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 15:56:46 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d23si25710948pfe.339.2017.12.27.15.56.44
        for <linux-mm@kvack.org>;
        Wed, 27 Dec 2017 15:56:45 -0800 (PST)
Date: Thu, 28 Dec 2017 08:56:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Hang with v4.15-rc trying to swap back in
Message-ID: <20171227235643.GA10532@bbox>
References: <1514398340.3986.10.camel@HansenPartnership.com>
 <1514407817.4169.4.camel@HansenPartnership.com>
 <20171227232650.GA9702@bbox>
 <1514417689.3083.1.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1514417689.3083.1.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Dec 27, 2017 at 03:34:49PM -0800, James Bottomley wrote:
> On Thu, 2017-12-28 at 08:26 +0900, Minchan Kim wrote:
> > Hello James,
> > 
> > On Wed, Dec 27, 2017 at 12:50:17PM -0800, James Bottomley wrote:
> > > 
> > > Reverting these three patches fixes the problem:
> > > 
> > > commit aa8d22a11da933dbf880b4933b58931f4aefe91c
> > > Author: Minchan Kim <minchan@kernel.org>
> > > Date:   Wed Nov 15 17:33:11 2017 -0800
> > > 
> > >     mm: swap: SWP_SYNCHRONOUS_IO: skip swapcache only if swapped
> > > page
> > > has no other reference
> > > 
> > > commit 0bcac06f27d7528591c27ac2b093ccd71c5d0168
> > > Author: Minchan Kim <minchan@kernel.org>
> > > Date:   Wed Nov 15 17:33:07 2017 -0800
> > > 
> > >     mm, swap: skip swapcache for swapin of synchronous device
> > > 
> > > Also need to revert:
> > > 
> > > commit e9a6effa500526e2a19d5ad042cb758b55b1ef93
> > > Author: Huang Ying <huang.ying.caritas@gmail.com>
> > > Date:   Wed Nov 15 17:33:15 2017 -0800
> > > 
> > >     mm, swap: fix false error message in __swp_swapcount()
> > > 
> > > (The latter is simply because it used a function that is eliminated
> > > by
> > > one of the other reversions).  They came into the merge window via
> > > the
> > > -mm tree as part of a 4 part series:
> > > 
> > > Subject:	[PATCH v2 0/4] skip swapcache for super fast device
> > > Message-Id:	<1505886205-9671-1-git-send-email-minchan@kernel
> > > .org
> > > > 
> > > > 
> > > 
> > > James
> > 
> > Thanks for the report.
> > Patches are related to synchronous swap devices like brd, zram,
> > nvdimm so
> > 
> > 1. What swap device do you use among them?
> 
> I've reproduced on nvme and sata spinning rust.
> 
> > 2. Could you tell me how you can reproduce it?
> 
> The way to reproduce is to force something to swap and then get it to
> try to touch the page again.  I do this on my systems by using a large
> virtual machine, as I said in the email.  There isn't really any
> definitive reproduction method beyond that.
> 

Thanks for the information.
It seems I made a bug on do_swap_page. I want to confirm before sending
formal patch.
Could you try on it?

diff --git a/mm/memory.c b/mm/memory.c
index ca5674cbaff2..240521f1322d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2889,9 +2889,12 @@ int do_swap_page(struct vm_fault *vmf)
 
 
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
-	if (!page)
+	if (!page) {
 		page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
 					 vmf->address);
+		swapcache = page;
+	}
+
 	if (!page) {
 		struct swap_info_struct *si = swp_swap_info(entry);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

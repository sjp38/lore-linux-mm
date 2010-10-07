Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 25AEE6B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 04:45:37 -0400 (EDT)
Date: Thu, 7 Oct 2010 10:45:29 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/4] HWPOISON: Report correct address granuality for AO
 huge page errors
Message-ID: <20101007084529.GH5010@basil.fritz.box>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
 <1286398141-13749-4-git-send-email-andi@firstfloor.org>
 <20101007003120.GB9891@spritzera.linux.bs1.fc.nec.co.jp>
 <20101007073848.GG5010@basil.fritz.box>
 <20101007084101.GE9891@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101007084101.GE9891@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 05:41:01PM +0900, Naoya Horiguchi wrote:
> On Thu, Oct 07, 2010 at 09:38:48AM +0200, Andi Kleen wrote:
> > On Thu, Oct 07, 2010 at 09:31:20AM +0900, Naoya Horiguchi wrote:
> > > > @@ -198,7 +199,8 @@ static int kill_proc_ao(struct task_struct *t, unsigned long addr, int trapno,
> > > >  #ifdef __ARCH_SI_TRAPNO
> > > >  	si.si_trapno = trapno;
> > > >  #endif
> > > > -	si.si_addr_lsb = PAGE_SHIFT;
> > > > +	order = PageCompound(page) ? huge_page_order(page) : PAGE_SHIFT;
> > >                                                      ^^^^
> > >                                      huge_page_order(page_hstate(page)) ?
> > 
> > Ok.
> 
> order seems to represent a least significant bit of corrupted address,
> so is huge_page_order() + PAGE_SHIFT or huge_page_shift() correct?

Both I guess.

> And since @page can be a tail page, compound_head() is needed as Wu-san pointed out.
> So huge_page_shift(page_hstate(compound_head(page))) looks good for me.

I used compound_order(compound_head(page)) + PAGE_SHIFT now.
This even works for non compound, so the special case check
can be dropped.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

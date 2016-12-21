Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0FA6B03E1
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 18:54:26 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so338341890pfx.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 15:54:26 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u6si15694301pgo.250.2016.12.21.15.54.24
        for <linux-mm@kvack.org>;
        Wed, 21 Dec 2016 15:54:25 -0800 (PST)
Date: Thu, 22 Dec 2016 08:54:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: jemalloc testsuite stalls in memset
Message-ID: <20161221235422.GA12727@bbox>
References: <mvmmvfy37g1.fsf@hawking.suse.de>
 <20161214235031.GA2912@bbox>
 <mvm4m2535pc.fsf@hawking.suse.de>
 <20161216063940.GA1334@bbox>
 <87d1gshscr.fsf@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d1gshscr.fsf@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Schwab <schwab@suse.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mbrugger@suse.de, linux-mm@kvack.org, Jason Evans <je@fb.com>

Hello, Andreas

Sorry for long delay. I was on vacation.

On Fri, Dec 16, 2016 at 03:16:20PM +0100, Andreas Schwab wrote:
> On Dez 16 2016, Minchan Kim <minchan@kernel.org> wrote:
> 
> > Below helps?
> >
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index e10a4fe..dc37c9a 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1611,6 +1611,7 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  			tlb->fullmm);
> >  		orig_pmd = pmd_mkold(orig_pmd);
> >  		orig_pmd = pmd_mkclean(orig_pmd);
> > +		orig_pmd = pmd_wrprotect(orig_pmd);
> >  
> >  		set_pmd_at(mm, addr, pmd, orig_pmd);
> >  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> 
> Thanks, this fixes the issue (tested with 4.9).

It was a quick hack to know what exact problem is there and your confirming
helped a lot to understand the problem clear.

More right approach is to support pmd dirty handling in general page fault
handler rather than tweaking MADV_FREE. I just sent a new patch with Ccing
you.

Could you test it, please?
Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

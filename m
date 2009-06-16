Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E12FD6B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 07:40:09 -0400 (EDT)
Date: Tue, 16 Jun 2009 19:40:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/22] HWPOISON: check and isolate corrupted free pages
	v2
Message-ID: <20090616114024.GA6185@localhost>
References: <20090615024520.786814520@intel.com> <20090615031253.715406280@intel.com> <20090615184112.ed8e2f03.kamezawa.hiroyu@jp.fujitsu.com> <20090615101620.GA7216@localhost> <20090616085222.1545cc05.kamezawa.hiroyu@jp.fujitsu.com> <20090616003440.GA7329@localhost> <Pine.LNX.4.64.0906161220070.31597@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906161220070.31597@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 07:29:45PM +0800, Hugh Dickins wrote:
> On Tue, 16 Jun 2009, Wu Fengguang wrote:
> > 
> > Right.  Then the original __ClearPageBuddy() call in bad_page() is
> > questionable, I guess this line was there just for the sake of safety
> > (ie. the buddy allocator itself goes wrong):
> > 
> > sound-2.6/mm/page_alloc.c
> > 
> >         @@ -269,7 +269,6 @@ static void bad_page(struct page *page)
> >                 dump_stack();
> >          out:
> >                 /* Leave bad fields for debug, except PageBuddy could make trouble */
> > ===>            __ClearPageBuddy(page);
> >                 add_taint(TAINT_BAD_PAGE);
> >          }
> 
> I didn't put that in for the case of the buddy allocator going wrong
> (not sure if there could be such a case - I don't mean that the buddy
> allocator is provably perfect! but how would it get here if it were
> wrong?).  No, I put that in for the case when the flag bits in struct
> page have themselves got corrupted somehow, and hence we arrive at
> bad_page(): most of the bits are best left as they are, to provide
> maximum debug info; but leaving PageBuddy set there might conceivably
> allow this corrupted struct page to get paired up with its buddy later,
> and so freed for reuse, when we're trying to make sure it's never reused.

Hugh, thank you for the detailed explanations!  You are always informative :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 906C76B0082
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 08:55:42 -0400 (EDT)
Date: Thu, 4 Jun 2009 15:02:55 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [6/16] HWPOISON: Add various poison checks in mm/memory.c
Message-ID: <20090604130255.GB1065@one.firstfloor.org>
References: <20090603846.816684333@firstfloor.org> <20090603184639.1933B1D028F@basil.firstfloor.org> <20090604042603.GA15682@localhost> <20090604051915.GN1065@one.firstfloor.org> <20090604115533.GB22118@localhost> <20090604125228.GZ1065@one.firstfloor.org> <20090604125026.GA29026@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604125026.GA29026@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 08:50:26PM +0800, Wu Fengguang wrote:
> On Thu, Jun 04, 2009 at 08:52:28PM +0800, Andi Kleen wrote:
> > On Thu, Jun 04, 2009 at 07:55:33PM +0800, Wu Fengguang wrote:
> > > On Thu, Jun 04, 2009 at 01:19:15PM +0800, Andi Kleen wrote:
> > > > On Thu, Jun 04, 2009 at 12:26:03PM +0800, Wu Fengguang wrote:
> > > > > On Thu, Jun 04, 2009 at 02:46:38AM +0800, Andi Kleen wrote:
> > > > > >
> > > > > > Bail out early when hardware poisoned pages are found in page fault handling.
> > > > >
> > > > > I suspect this patch is also not absolutely necessary: the poisoned
> > > > > page will normally have been isolated already.
> > > >
> > > > It's needed to prevent new pages comming in when there is a parallel
> > > > fault while the memory failure handling is in process.
> > > > Otherwise the pages could get remapped in that small window.
> > > 
> > > This patch makes no difference at least for file pages, including tmpfs.
> > 
> > I was more thinking of anonymous pages with multiple mappers (e.g.
> > COW after fork)
> 
> I guess they are handled by do_anonymous_page() or do_wp_page(),
> instead of do_linear_fault()/do_nonlinear_fault()?

You're right. Sorry was a little confused in my earlier reply.

I think what I meant is: what happens during the window
when the page has just the poison bit set, but is not isolated/unmapped yet.
During that window I want new mappers to not come in.
That is why that check is there.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00BB16B01EF
	for <linux-mm@kvack.org>; Wed, 12 May 2010 16:59:21 -0400 (EDT)
Date: Wed, 12 May 2010 13:58:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,migration: Avoid race between shift_arg_pages() and
 rmap_walk() during migration by not migrating temporary stacks
Message-Id: <20100512135846.4fb04190.akpm@linux-foundation.org>
In-Reply-To: <20100512205150.GL24989@csn.ul.ie>
References: <20100511085752.GM26611@csn.ul.ie>
	<20100512092239.2120.A69D9226@jp.fujitsu.com>
	<20100512125427.d1b170ba.akpm@linux-foundation.org>
	<20100512205150.GL24989@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 May 2010 21:51:50 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, May 12, 2010 at 12:54:27PM -0700, Andrew Morton wrote:
> > On Wed, 12 May 2010 09:23:44 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > > diff --git a/fs/exec.c b/fs/exec.c
> > > > index 725d7ef..13f8e7f 100644
> > > > --- a/fs/exec.c
> > > > +++ b/fs/exec.c
> > > > @@ -242,9 +242,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
> > > >  	 * use STACK_TOP because that can depend on attributes which aren't
> > > >  	 * configured yet.
> > > >  	 */
> > > > +	BUG_ON(VM_STACK_FLAGS & VM_STACK_INCOMPLETE_SETUP);
> > > 
> > > Can we use BUILD_BUG_ON()? 
> > 
> > That's vastly preferable - I made that change.
> > 
> 
> I will be surprised if it works. On x86, that is
> 
> #define VM_STACK_FLAGS  (VM_GROWSDOWN | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
> #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
> #define VM_DATA_DEFAULT_FLAGS \
>         (((current->personality & READ_IMPLIES_EXEC) ? VM_EXEC : 0 ) | \
>          VM_READ | VM_WRITE | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
> 
> so VM_STACK_FLAGS is depending on the value of current->personality
> which we don't know at build time.

argh.  So ytf is it in ALL_CAPS?

Geeze, kids these days...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

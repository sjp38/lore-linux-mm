Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B22636B01EF
	for <linux-mm@kvack.org>; Wed, 12 May 2010 19:06:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4CN6rsq018361
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 13 May 2010 08:06:53 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 70AAF45DE50
	for <linux-mm@kvack.org>; Thu, 13 May 2010 08:06:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 459F145DE51
	for <linux-mm@kvack.org>; Thu, 13 May 2010 08:06:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18CB71DB8054
	for <linux-mm@kvack.org>; Thu, 13 May 2010 08:06:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AE7A01DB8051
	for <linux-mm@kvack.org>; Thu, 13 May 2010 08:06:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm,migration: Avoid race between shift_arg_pages() and rmap_walk() during migration by not migrating temporary stacks
In-Reply-To: <20100512205150.GL24989@csn.ul.ie>
References: <20100512125427.d1b170ba.akpm@linux-foundation.org> <20100512205150.GL24989@csn.ul.ie>
Message-Id: <20100513080600.2139.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 13 May 2010 08:06:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

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

Argh, yes right you are.

sorry for the noise.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

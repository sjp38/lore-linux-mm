Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BB70D6B0248
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 05:51:30 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o689pOJB008803
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 8 Jul 2010 18:51:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C20EE45DE4E
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 18:51:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A04D145DE4F
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 18:51:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E9391DB8015
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 18:51:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F2A43E08003
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 18:51:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: FYI: mmap_sem OOM patch
In-Reply-To: <1278581717.1900.20.camel@laptop>
References: <20100708182134.CD3F.A69D9226@jp.fujitsu.com> <1278581717.1900.20.camel@laptop>
Message-Id: <20100708184341.CD42.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu,  8 Jul 2010 18:51:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 2010-07-08 at 18:24 +0900, KOSAKI Motohiro wrote:
> > > On Wed, 2010-07-07 at 16:11 -0700, Michel Lespinasse wrote:
> > > 
> > > > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > > > index f627779..4b3a1c7 100644
> > > > --- a/arch/x86/mm/fault.c
> > > > +++ b/arch/x86/mm/fault.c
> > > > @@ -1062,7 +1062,10 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
> > > >  			bad_area_nosemaphore(regs, error_code, address);
> > > >  			return;
> > > >  		}
> > > > -		down_read(&mm->mmap_sem);
> > > > +		if (test_thread_flag(TIF_MEMDIE))
> > > > +			down_read_unfair(&mm->mmap_sem);
> > > > +		else
> > > > +			down_read(&mm->mmap_sem);
> > > >  	} else {
> > > >  		/*
> > > >  		 * The above down_read_trylock() might have succeeded in
> > > 
> > > I still think adding that _unfair interface is asking for trouble.
> > 
> > Can you please explain trouble that you worry? Why do we need to keep
> > thread fairness when OOM case?
> 
> Just the whole concept of the unfair thing offends me ;-) I didn't
> really look at the particular application in this case.

I see. 
Yup, I agree unfair thing concept is a bit ugly. If anyone have 
alternative idea, I agree to choose that thing.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

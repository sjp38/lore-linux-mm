Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 520936B006A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 05:24:26 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o689ONO3018639
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 8 Jul 2010 18:24:23 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 45AAA45DE55
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 18:24:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2717245DE51
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 18:24:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAC7D1DB803A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 18:24:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62291E18001
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 18:24:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: FYI: mmap_sem OOM patch
In-Reply-To: <1278579768.1900.14.camel@laptop>
References: <20100707231134.GA26555@google.com> <1278579768.1900.14.camel@laptop>
Message-Id: <20100708182134.CD3F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu,  8 Jul 2010 18:24:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>
List-ID: <linux-mm.kvack.org>

> On Wed, 2010-07-07 at 16:11 -0700, Michel Lespinasse wrote:
> 
> > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > index f627779..4b3a1c7 100644
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -1062,7 +1062,10 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
> >  			bad_area_nosemaphore(regs, error_code, address);
> >  			return;
> >  		}
> > -		down_read(&mm->mmap_sem);
> > +		if (test_thread_flag(TIF_MEMDIE))
> > +			down_read_unfair(&mm->mmap_sem);
> > +		else
> > +			down_read(&mm->mmap_sem);
> >  	} else {
> >  		/*
> >  		 * The above down_read_trylock() might have succeeded in
> 
> I still think adding that _unfair interface is asking for trouble.

Can you please explain trouble that you worry? Why do we need to keep
thread fairness when OOM case?


btw, I also dislike unfair + /proc combination.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

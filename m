Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 91C036B0246
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 05:35:27 -0400 (EDT)
Subject: Re: FYI: mmap_sem OOM patch
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100708182134.CD3F.A69D9226@jp.fujitsu.com>
References: <20100707231134.GA26555@google.com>
	 <1278579768.1900.14.camel@laptop>
	 <20100708182134.CD3F.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Jul 2010 11:35:17 +0200
Message-ID: <1278581717.1900.20.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-08 at 18:24 +0900, KOSAKI Motohiro wrote:
> > On Wed, 2010-07-07 at 16:11 -0700, Michel Lespinasse wrote:
> >=20
> > > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > > index f627779..4b3a1c7 100644
> > > --- a/arch/x86/mm/fault.c
> > > +++ b/arch/x86/mm/fault.c
> > > @@ -1062,7 +1062,10 @@ do_page_fault(struct pt_regs *regs, unsigned l=
ong error_code)
> > >  			bad_area_nosemaphore(regs, error_code, address);
> > >  			return;
> > >  		}
> > > -		down_read(&mm->mmap_sem);
> > > +		if (test_thread_flag(TIF_MEMDIE))
> > > +			down_read_unfair(&mm->mmap_sem);
> > > +		else
> > > +			down_read(&mm->mmap_sem);
> > >  	} else {
> > >  		/*
> > >  		 * The above down_read_trylock() might have succeeded in
> >=20
> > I still think adding that _unfair interface is asking for trouble.
>=20
> Can you please explain trouble that you worry? Why do we need to keep
> thread fairness when OOM case?

Just the whole concept of the unfair thing offends me ;-) I didn't
really look at the particular application in this case.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

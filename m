Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id A2C068D0005
	for <linux-mm@kvack.org>; Thu, 17 May 2012 10:52:00 -0400 (EDT)
Message-ID: <1337266310.4281.30.camel@twins>
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 17 May 2012 16:51:50 +0200
In-Reply-To: <4FB4B29C.4010908@kernel.org>
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
	 <1337133919-4182-3-git-send-email-minchan@kernel.org>
	 <4FB4B29C.4010908@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>

On Thu, 2012-05-17 at 17:11 +0900, Minchan Kim wrote:
> > +++ b/arch/x86/include/asm/tlbflush.h
> > @@ -172,4 +172,16 @@ static inline void flush_tlb_kernel_range(unsigned=
 long start,
> >       flush_tlb_all();
> >  }
> > =20
> > +static inline void local_flush_tlb_kernel_range(unsigned long start,
> > +             unsigned long end)
> > +{
> > +     if (cpu_has_invlpg) {
> > +             while (start < end) {
> > +                     __flush_tlb_single(start);
> > +                     start +=3D PAGE_SIZE;
> > +             }
> > +     } else
> > +             local_flush_tlb();
> > +}


It would be much better if you wait for Alex Shi's patch to mature.
doing the invlpg thing for ranges is not an unconditional win.

Also, does it even work if the range happens to be backed by huge pages?
IIRC we try and do the identity map with large pages wherever possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

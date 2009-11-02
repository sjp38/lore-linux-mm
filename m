Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EC0A46B0062
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 11:04:24 -0500 (EST)
Date: Mon, 2 Nov 2009 18:04:10 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 02/11] Add "handle page fault" PV helper.
Message-ID: <20091102160410.GF27911@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
 <1257076590-29559-3-git-send-email-gleb@redhat.com>
 <20091102092214.GB8933@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091102092214.GB8933@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 02, 2009 at 10:22:14AM +0100, Ingo Molnar wrote:
> 
> * Gleb Natapov <gleb@redhat.com> wrote:
> 
> > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > index f4cee90..14707dc 100644
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -952,6 +952,9 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
> >  	int write;
> >  	int fault;
> >  
> > +	if (arch_handle_page_fault(regs, error_code))
> > +		return;
> > +
> 
> This patch is not acceptable unless it's done cleaner. Currently we 
> already have 3 callbacks in do_page_fault() (kmemcheck, mmiotrace, 
> notifier), and this adds a fourth one. Please consolidate them into a 
> single callback site, this is a hotpath on x86.
> 
This call is patched out by paravirt patching mechanism so overhead should be
zero for non paravirt cases. What do you want to achieve by consolidate
them into single callback? I mean the code will still exist and will have to be
executed on every #PF. Is the goal to move them out of line? 

> And please always Cc: the x86 maintainers to patches that touch x86 
> code.
> 
Will do.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
